struct Float32Fields
{
    whole: u127
,   fraction: u127
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
    // truncate trailing zeros from fraction
    unconstrained
    fn truncate(self) -> u127
    {
        // 2^128 - 1 (max) has 39 digits, at most 38 zeros can be removed
        let mut quotient = self.fraction;
        for _ in 0..38 { if ((quotient % 10) == 0) { quotient /= 10; } }

        quotient
    }

    // deduce denominator by counting the decimal digits of fraction
    unconstrained
    fn getDenominator(self) -> u127
    {
        // TODO: is this necessary, or should the input be expected not to contain trailing zeros ?
        // let fraction = self.truncate();

        let mut quotient = self.fraction;
        let mut index : u8 = (self.leading_zeros as u8);
        for _ in 0..MAGNITUDE_ORDER_MAX { if (quotient != 0) { quotient /= 10; index += 1; } }

        POWERS_OF_TEN[index]
    }

    unconstrained
    pub fn toFloat32(self) -> Float32
    {
        let mut result = Float32 { sign: ((self.whole & TWO_POWER_126) != 0) as u1, exponent: 0, mantissa: 0 };

        if ((self.whole == 0) & (self.fraction != 0)) // **negative** exponent value (zero excluded)
        {
            // compute exponent knowing `fraction >= denominator / by 2^abs(exponent + 1)`
            let denominator : u127 = self.getDenominator();
            let mut numerator : u127 = self.fraction * 2;
            let mut exponent : u8 = 1; // whole part is zero <=> abs(exponent) is strictly greater than zero
            for _ in 0..127 { if (numerator < denominator) { numerator *= 2; exponent += 1; } }
            result.exponent = (BIAS - exponent); // actual value is negative, substract it from bias (add -exponent)

            result.mantissa = ((((numerator - denominator) * TWO_POWER_PRECISION) / denominator) as u23);
        }
        else if (self.whole != 0) // **positive** exponent value (zero included)
        {
            // compute exponent value by counting binary digits in complemented whole part
            let mut whole : u127 = if (result.sign == 1) { !self.whole + 1 } else { self.whole };
            let mut exponent : u8 = 0;
            for _ in 0..127 { if (whole != 1) { whole /= 2; exponent += 1; } }
            result.exponent = (BIAS + exponent);

            whole = self.whole; // reusing whole variable to encode mantissa in

            if (exponent < PRECISION) // fraction representation boundary
            {
                // encode binary digits of fraction to mantissa
                let denominator : u127 = self.getDenominator();
                let mut quotient : u127 = self.fraction;
                for _ in exponent..PRECISION // PRECISION less exponent bits available for fraction
                {
                    quotient *= 2;
                    whole *= 2; // insert a zero bit as LSB

                    // dep::std::println(f"{_} - quot : {quotient}");
                    if (quotient >= denominator)
                    {
                        quotient -= denominator;
                        whole |= 1; // change bit to one
                    }
                }

                // round up based on hidden bit
                if ((quotient * 2) > denominator)
                {
                    whole += 1;

                    if ((whole as u23) == 0) { result.exponent += 1; }
                    // result.exponent += 0 ^ (((whole as u23) == 0) as u8);
                }
            }
            // truncate whole exponent delta bytes to (aproximately) fit in mantissa
            else { for _ in PRECISION..exponent { whole /= 2; } }

            result.mantissa = (whole as u23);
        }

        dep::std::println(result);

        // let mut m = result.mantissa;
        // for _ in 0..PRECISION { if ((m & 1) == 1) { dep::std::println("1"); } else { dep::std::println("0"); } m >>= 1; }

        result
    }
}

        // dep::std::println(f"magnitude_order: {magnitude_order}");
        // dep::std::println(f"exponent: {exponent}");
        // dep::std::println(f"whole: {whole}");
        // dep::std::println(f"quotient: {quotient}");
        // dep::std::println(f"fraction: {fraction}");
        // dep::std::println(f"numerator: {numerator}");
        // dep::std::println(f"denominator: {denominator}");

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
        let mut coefficient : u127 = FIVE_POWER_PRECISION;
        let mut numerator : u127 = 0;
        let mut mantissa : u23 = self.mantissa;
        for _ in 0..PRECISION
        {
            if (mantissa != 0)
            {
                numerator += (((mantissa & 1) as u127) * coefficient);
                mantissa /= 2;
                coefficient *= 2; // multiply each bit by (10^i / 5^(PRECISION-i)) <=> multiply initial value by 2
            }
        }

        // compute value of exponent to multiply/divide numerator by
        let exponent : u8 = ((self.exponent - BIAS) as u8);

        // set the denominator magnitude order (a power of 10)
        let mut denominator : u127 = 1;
        if ((exponent < BIAS_MINUS_PRECISION_PLUS_ONE) | (exponent > BIAS_PLUS_PRECISION_MINUS_ONE))
        {
            // TODO: create a test for this
            // truncate numerator trailing zeros
            // let mut magnitude_order : u8 = PRECISION;
            // if (numerator != 0) { for _ in 1..PRECISION { if ((numerator % 10) == 10) { numerator /= 10; magnitude_order -= 1; } } }

            denominator = POWERS_OF_TEN[PRECISION]; // magnitude_order
        }

        // add one (adjusted to denominator magnitude) to numerator
        numerator += denominator;

        if (exponent > BIAS) { for _ in 0..(!exponent + 1) { numerator /= 2; } } // negative exponent, divide by 2^complement
        else                 { for _ in 0..exponent        { numerator *= 2; } } // positive exponent, multiply by 2^exponent

        // denominator is one <=> fraction part is missing; skip the division and return a whole number
        result.whole = numerator;

        if (denominator != 1)
        {
            // divide whole part by denominator to finish formula calculation, and complement when signed
            result.whole /= denominator;
            if (self.sign == 1) { result.whole = (!result.whole + 1); }

            // compute fraction part
            let mut fraction : u127 = (numerator % denominator);
            if (fraction != 0)
            {
                let ten_o : u127 = POWERS_OF_TEN[output_precision];
                let mut is_counting = true;
                for _ in 0..PRECISION // magnitude_order
                {
                    // count leading zeros
                    if (is_counting)
                    {
                        denominator /= 10;                                    // max fraction digit count is one less denominator magnitude order
                        is_counting = ((fraction % denominator) == fraction); // remainder equals fraction <=> a leading zero
                        if (is_counting) { result.leading_zeros += 1; }
                        // result.leading_zeros += (0 ^ (is_counting as u4)); // add one (or zero when done)
                    }

                    // round up to specified output precision
                    let digit : u127 = (fraction % 10);
                    if (fraction > ten_o)
                    {
                        if (digit > 4) { fraction += 10; }
                        fraction /= 10;
                        denominator /= 10;
                    }
                    // truncate trailing zeros
                    else if (digit == 0) { fraction /= 10; denominator /= 10; }
                }

                result.fraction = fraction;
            }
        }

        dep::std::println(result);

        result
    }
}

unconstrained
pub fn toFloat32(whole: u127, fraction: u127, leading_zeros: u4) -> Float32
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
global BIAS : u8 = 127;
global BIAS_PLUS_ONE : u8 = 128;

global BIAS_PLUS_PRECISION_MINUS_ONE : u8 = 139;
global BIAS_MINUS_PRECISION_PLUS_ONE : u8 = 105;

global TWO_POWER_PRECISION_MINUS_ONE : u23 = 4194304;
global TWO_POWER_PRECISION : u127 = 8388608;
global TWO_POWER_126 : u127 = 85070591730234615865843651857942052864;
global FIVE_POWER_PRECISION : u127 = 11920928955078125;
global MAGNITUDE_ORDER_MAX = 45;
global POWERS_OF_TEN : [u127; MAGNITUDE_ORDER_MAX] =
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
,   1000000000000000000000000
,   10000000000000000000000000
,   100000000000000000000000000
,   1000000000000000000000000000
,   10000000000000000000000000000
,   100000000000000000000000000000
,   1000000000000000000000000000000
,   10000000000000000000000000000000
,   100000000000000000000000000000000
,   1000000000000000000000000000000000
,   10000000000000000000000000000000000
,   100000000000000000000000000000000000
,   1000000000000000000000000000000000000
,   10000000000000000000000000000000000000
,   100000000000000000000000000000000000000
,   1000000000000000000000000000000000000000
,   10000000000000000000000000000000000000000
,   100000000000000000000000000000000000000000
,   1000000000000000000000000000000000000000000
,   10000000000000000000000000000000000000000000
,   100000000000000000000000000000000000000000000
// ,   1000000000000000000000000000000000000000000000
];
