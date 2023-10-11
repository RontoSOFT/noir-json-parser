struct Float32Fields
{
    whole: u24
,   fraction: u23
,   leading_zeros: u8
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
        let mut result = Float32 { sign: 0, exponent: 0, mantissa: 0 };

        // extract sign
        result.sign = ((self.whole / two_raised_to_precision_minus_one as u24) as u1);

        // encode whole part in mantissa and complement when signed
        result.mantissa = (self.whole as u23);
        if (result.sign == 1) { result.mantissa = (!result.mantissa + 1); }

        // count binary digits in whole part: divide by two until reaching zero
        let mut size_exponent = -1; // due to normalization, a whole part with a value of zero implies exponent = -1
        let mut w = result.mantissa;
        for _ in 0..precision { if (w != 0) { w /= 2; size_exponent += 1; } }

        // add bias for signed values and store exponent
        result.exponent = (size_exponent + bias);

        // count of bits available for fraction is precision less exponent bit count (+1 when exponent is 0)
        let iterations = (precision - size_exponent);

        // remove trailing zeros from fraction -- 2^23 - 1 (max) has 7 digits, at most 6 zeros can be removed
        let mut quotient : u127 = (self.fraction as u127);
        for _ in 0..6 { if ((quotient % 10) == 0) { quotient /= 10; } }

        // deduce denominator by counting the decimal digits of fraction
        let mut index : u8 = 1 + self.leading_zeros;
        for _ in index..iterations { if (quotient >= 10) { quotient /= 10; index += 1; } }
        let denominator : u127 = powers_of_ten[index];

        // encode binary digits of fractional part to mantissa
        quotient = (self.fraction as u127);
        for _ in 0..iterations
        {
            quotient *= 2;
            result.mantissa *= 2;          // inject a zero bit

            if (quotient >= denominator)
            {
                quotient -= denominator;
                result.mantissa |= 1;       // change it to one
            }
        }

        // normalize mantissa by left-shifting until first non-zero binary digit is found (inclusive)
        if ((self.whole == 0) & (self.leading_zeros != 0))
        {
            let mut done = false;
            let mut found = false;

            for _ in 0..iterations
            {
                if (!done)
                {
                    done = found; // done only AFTER finding first non-zero binary digit

                    quotient *= 2;
                    result.mantissa *= 2;          // inject a zero bit
                    result.exponent -= 1;

                    if (quotient >= denominator)
                    {
                        quotient -= denominator;
                        result.mantissa |= 1;       // change it to one
                    }

                    // since we multipled by 2, take the second digit instead
                    found = ((result.mantissa / two_raised_to_precision_minus_one) == 1);
                }
            }
        }

        // let mut m = result.mantissa;
        // for _ in 0..precision { if ((m & 1) == 1) { dep::std::println("1"); } else { dep::std::println("0"); } m >>= 1; }

        result
    }
}

impl Float32
{
    unconstrained
    pub fn toFields(self, output_precision : u4) -> Float32Fields
    {
        // dep::std::println("");
        // dep::std::println(self);

        // fraction part can be computed using "powers-of-five-over-ten" trick
        //
        // 2 ** (-1) = 1 / 2 =   0.5 =   5 / 10   = (5 / 10) ** 1
        // 2 ** (-2) = 1 / 4 =  0.25 =  25 / 100  = (5 / 10) ** 2
        // 2 ** (-3) = 1 / 8 = 0.125 = 625 / 1000 = (5 / 10) ** 3
        // ...
        // 2 ** (-precision) = (5 / 10) ** precision

        // calculate numerator of fraction
        let mut numerator : u127 = 0;
        let mut five_times_ten = five_raised_to_precision;
        let mut mantissa = self.mantissa;
        for _ in 0..precision
        {
            if (mantissa != 0)
            {
                if ((mantissa & 1) == 1) { numerator += five_times_ten; }
                mantissa /= 2;

                // multiplying each coefficient by (10**i / 5**(precision-i)) means to repeatedly divide the initial value by two
                five_times_ten *= 2;
            }
        }

        // truncate numerator trailing zeros, iterating (precision - magnitude_difference) times
        let mut iterations = precision;
        for _ in 0..precision { if ((numerator != 0) & ((numerator % 10) == 0)) { numerator /= 10; iterations -= 1; } }

        // add one (adjusted per denominator, which is 10**(precision - magnitude_difference))
        let mut ten = powers_of_ten[iterations];
        numerator += ten;

        // compute value of exponent
        let value_exponent = (self.exponent - bias) as u8;

        // count leading zeros
        let mut leading_zeros : u8 = 0;
        if (value_exponent < bias) // exponent is positive or zero
        {
            // multiply by 2**exponent
            for _ in 0..value_exponent { numerator *= 2; }

            // the numerator is abc.(0)?xyz..
            let mut ten = powers_of_ten[iterations - 1];
            let mut numerator = numerator;
            let mut done = false;
            for _ in 1..iterations
            {
                if (!done)
                {
                    if (((numerator / ten) % 10) == 0) { leading_zeros += 1; ten /= 10; }
                    else                               { done = true; }
                }
            }
        }
        else // exponent is negative
        {
            // divide by 2**complement
            for _ in 0..(!value_exponent + 1) { numerator /= 2; }

            // the numerator is 0.(0)?xyz..
            let mut numerator = numerator;
            for _ in 0..iterations
            {
                if (numerator != 0) { numerator /= 10; }
                else                { leading_zeros += 1; }
            }
        }

        // extract whole and fraction parts
        let mut whole = (numerator / ten);
        let mut fraction = (numerator - (whole * ten));

        // complement whole when signed
        if (self.sign == 1) { whole = (!whole + 1); }
        let whole = (whole as u24);

        // round up fraction part to specified output precision
        let output_precision = powers_of_ten[output_precision];
        for _ in 0..iterations
        {
            let digit = (fraction % 10);

            // round up
            if (fraction > output_precision)
            {
                if (digit > 4) { fraction += 10; }
                fraction /= 10;
            }
            // truncate trailing zeros
            else if (digit == 0) { fraction /= 10; }
        }
        let fraction = (fraction as u23);

        Float32Fields { whole, fraction, leading_zeros }
    }
}

unconstrained
pub fn toFloat32(whole: u24, fraction: u23, leading_zeros: u8) -> Float32
{
    Float32Fields { whole, fraction, leading_zeros }.toFloat32()
}

unconstrained
pub fn toFields(sign: u1, exponent: u8, mantissa: u23, output_precision : u4) -> Float32Fields
{
    Float32 { sign, exponent, mantissa }.toFields(output_precision)
}

global size      : u8 = 32;
global precision : u8 = 23;
global bias      : u8 = 127;

// fn bias() -> u8 { ((1 << (size - precision - 2)) - 1) }

global two_raised_to_precision_minus_one = 4194304;
global five_raised_to_precision : u127 = 11920928955078125; // 5 ** 23

// global powers_of_five : [u127; 24] =
// [
//     1
// ,   5
// ,   25
// ,   125
// ,   625
// ,   3125
// ,   15625
// ,   78125
// ,   390625
// ,   1953125
// ,   9765625
// ,   48828125
// ,   244140625
// ,   1220703125
// ,   6103515625
// ,   30517578125
// ,   152587890625
// ,   762939453125
// ,   3814697265625
// ,   19073486328125
// ,   95367431640625
// ,   476837158203125
// ,   2384185791015625
// ,   11920928955078125
// ];

global powers_of_ten : [u127; 24] =
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
