struct Float32Fields
{
    whole: u127
,   fraction: u23
,   leading_zeros: u4
}

struct Float32
{
    sign: u1
,   exponent: u8
,   mantissa: u23
}

impl Float32Fields
{
    unconstrained
    pub fn toFloat32(self) -> Float32
    {
        // extract sign
        let sign : u127 = (self.whole / TWO_POWER_127);

        let mut result = Float32 { sign: sign as u1, exponent: 0, mantissa: 0 };

        // a whole part of zero implies exponent is less than zero
        let mut size_exponent = (-1 as u8);

        if ((self.whole != 0) | (self.fraction != 0))
        {
            // count binary digits in (complemented) whole part
            let mut w = ((self.whole ^ -sign) + sign);
            for _ in 0..127 { if (w != 0) { w /= 2; size_exponent += 1; } }

            // add bias for signed values
            result.exponent = (size_exponent + EXPONENT_BIAS);
        }

        if ((size_exponent > PRECISION) & (size_exponent < BIAS_PLUS_ONE))
        {
            // truncate bytes on the right: left-shift whole part exponent value delta times
            let mut delta_exponent : u127 = ((size_exponent - PRECISION) as u127);
            let mut w : u127 = self.whole;
            for _ in 0..delta_exponent { w /= 2; }

            result.mantissa = (w as u23); // truncate 1 bit left (MSB)
        }
        else
        {
            result.mantissa = (self.whole as u23);

            // truncate trailing zeros from fraction -- 2^23 - 1 (max) has 7 digits, at most 6 zeros can be removed
            let mut quotient : u127 = (self.fraction as u127);
            for _ in 0..6 { if ((quotient % 10) == 0) { quotient /= 10; } }

            // deduce denominator by counting the decimal digits of fraction
            let mut index : u8 = (self.leading_zeros as u8);
            for _ in 1..PRECISION { if (quotient != 0) { quotient /= 10; index += 1; } }
            let denominator : u127 = POWERS_OF_TEN[index];

            // encode binary digits of fractional part to mantissa
            quotient = (self.fraction as u127);
            let iterations : u8 = (PRECISION - size_exponent); // bits available for fraction (PRECISION+1 when whole is zero)
            for _ in 0..iterations
            {
                quotient *= 2;
                result.mantissa *= 2; // insert a zero bit as LSB

                if (quotient >= denominator)
                {
                    quotient -= denominator;
                    result.mantissa |= 1; // change bit to one
                }
            }

            // normalize mantissa by left-shifting until first non-zero bit (inclusive)
            if ((self.whole == 0) & (self.leading_zeros != 0))
            {
                let mut done = 0;
                let mut found = 0;
                for _ in 0..iterations
                {
                    if (done == 0)
                    {
                        // done AFTER finding first non-zero bit
                        done = found;

                        result.exponent -= 1;

                        quotient *= 2;
                        result.mantissa *= 2; // insert a zero bit as LSB

                        if (quotient >= denominator)
                        {
                            quotient -= denominator;
                            result.mantissa |= 1; // change bit to one
                        }

                        // found first non-zero bit?
                        found = (result.mantissa / TWO_POWER_PRECISION_MINUS_ONE);
                    }
                }
            }
        }

        // let mut m = result.mantissa;
        // for _ in 0..PRECISION { if ((m & 1) == 1) { dep::std::println("1"); } else { dep::std::println("0"); } m >>= 1; }

        result
    }
}

impl Float32
{
    // floating-point number calculation formula:
    //
    // 1.mantissa * 2^exponent = (mantissa + 1) * 2^exponent
    //
    // mantissa is computed by summing bits (MSB to LSB) multiplied by inverse powers of two (up to PRECISION)
    // with only integers available the values can be represented using "powers-of-five-over-ten" trick
    //
    // instead of 2^negative as coefficient, use (5/10)^positive and divide the sum by 10^PRECISION
    //
    // the numerator bit coefficients can equivalently be re-written as:
    //
    // 2^(-1) = 1 / 2 =   0.5 =   5 / 10   = (5 / 10)^1 +
    // 2^(-2) = 1 / 4 =  0.25 =  25 / 100  = (5 / 10)^2 +
    // 2^(-3) = 1 / 8 = 0.125 = 625 / 1000 = (5 / 10)^3 +
    //                      ...                         +
    // 2^(-PRECISION) = 0.00000011920928955078125 = (5 / 10)^PRECISION
    //
    // truncate trailing zeros to reduce magnitude, increasing performance of iterations
    //
    // denominator is 10^(PRECISION - magnitude_difference)

    unconstrained
    pub fn toFields(self, output_precision : u4) -> Float32Fields
    {
        let mut result = Float32Fields { whole : 0, fraction : 0, leading_zeros : 0 };

        // compute numerator by expanding mantissa
        let mut coefficient = FIVE_POWER_PRECISION;
        let mut mantissa = self.mantissa;
        let mut numerator : u127 = 0;
        for _ in 0..PRECISION
        {
            if (mantissa != 0)
            {
                numerator += (((mantissa & 1) as u127) * coefficient);
                mantissa /= 2;
                coefficient *= 2; // multiply each bit by (10^i / 5^(PRECISION-i)) <=> divide value by two
            }
        }

        // extract value of exponent to multiply/divide numerator by
        let value_exponent = ((self.exponent - EXPONENT_BIAS) as u8);

        // set the denominator magnitude order (a power of 10)
        let mut magnitude_order = PRECISION;
        if ((value_exponent > BIAS_MINUS_PRECISION) & (value_exponent < BIAS_PLUS_PRECISION)) { magnitude_order = 0; }

        // TODO: create a test for this
        // truncate numerator trailing zeros ((numerator / TWO_POWER_PRECISION_MINUS_ONE as u127) == 1)
        // if (numerator != 0) { for _ in 1..PRECISION { if ((numerator % 10) == 10) { dep::std::println("asdf"); numerator /= 10; magnitude_order -= 1; } } }

        // add one (adjusted to denominator magnitude) to numerator
        let mut ten = POWERS_OF_TEN[magnitude_order];
        numerator += ten;

        if (value_exponent > EXPONENT_BIAS) { for _ in 0..(!value_exponent + 1) { numerator /= 2; } } // divide by 2^complement
        else /* exponent is positive */     { for _ in 0..value_exponent        { numerator *= 2; } } // multiply by 2^exponent

        // extract whole part and complement when signed
        result.whole = (numerator / ten);
        if (self.sign == 1) { result.whole = (!result.whole + 1); }

        // dep::std::println(f"numerator: {numerator}");
        // dep::std::println(f"ten: {ten}");
        // dep::std::println(f"whole: {whole}");
        // dep::std::println(f"value_exponent: {value_exponent}");
        // dep::std::println(f"fraction: {fraction}");
        // dep::std::println(f"magnitude_order: {magnitude_order}");

        // extract fraction part
        let mut fraction : u127 = (numerator % ten);
        if (fraction != 0)
        {
            let ten_o = POWERS_OF_TEN[output_precision];
            let mut done = false;
            for _ in 0..magnitude_order
            {
                let digit = (fraction % 10);
                if (fraction > ten_o)
                {
                    // count leading zeros
                    if (done == false)
                    {
                        ten /= 10;                                  // max fraction digit count is one less magnitude_order
                        done = ((fraction % ten) != fraction);      // when remainder equas fraction there is a leading zero
                        result.leading_zeros += (1 ^ (done as u4)); // add one (or zero when done)
                    }

                    // round up to specified output precision
                    if (digit > 4) { fraction += 10; }
                    fraction /= 10;
                    ten /= 10;
                }
                // truncate trailing zeros
                else if (digit == 0) { fraction /= 10; }
            }

            result.fraction = (fraction as u23);
        }

        // dep::std::println("");
        // dep::std::println(self);
        // dep::std::println(result);

        result
    }
}

unconstrained
pub fn toFloat32(whole: u127, fraction: u23, leading_zeros: u4) -> Float32
{
    Float32Fields { whole, fraction, leading_zeros }.toFloat32()
}

unconstrained
pub fn toFields(sign: u1, exponent: u8, mantissa: u23, output_precision : u4) -> Float32Fields
{
    Float32 { sign, exponent, mantissa }.toFields(output_precision)
}

global PRECISION : u8 = 23;
global PRECISION_PLUS_ONE : u8 = 24;
global EXPONENT_BIAS : u8 = 127;
global BIAS_PLUS_ONE : u8 = 128;

global BIAS_PLUS_PRECISION : u8 = 140;
global BIAS_MINUS_PRECISION : u8 = 104;

global TWO_POWER_PRECISION_MINUS_ONE : u23 = 4194304;
global TWO_POWER_PRECISION_PLUS_ONE : u127 = 16777216;
global TWO_POWER_127 : u127 = 85070591730234615865843651857942052864;
global FIVE_POWER_PRECISION : u127 = 11920928955078125; // 5^23

global POWERS_OF_TEN : [u127; 24] =
[
    1
,   10
,   100
,   1000
,   10000
,   100000
,   1000000
,   10000000
,   100000000
,   1000000000
,   10000000000
,   100000000000
,   1000000000000
,   10000000000000
,   100000000000000
,   1000000000000000
,   10000000000000000
,   100000000000000000
,   1000000000000000000
,   10000000000000000000
,   100000000000000000000
,   1000000000000000000000
,   10000000000000000000000
,   100000000000000000000000
];
