use dep::std::option::Option;

use crate::globals::BYTE_NULL;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::eE;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;

use crate::utils::int127FromField;

unconstrained pub fn asBool<N>(bytes: [u8; N]) -> Option<bool>
{
    let mut i : &mut Field = &mut -1;
    let equal_value = |a| { *i += 1; bytes[*i] == a };

    let mut valid = false;

    if ((N == 4) | ((N == 5) & (bytes[4] == BYTE_NULL)))
    {
        if      (bytes[0] == LITERALS_NULL[0]) { valid = LITERALS_NULL.all(equal_value); }
        else if (bytes[0] == LITERALS_TRUE[0]) { valid = LITERALS_TRUE.all(equal_value); }
    }
    else if (N == 5) { valid = LITERALS_FALSE.all(equal_value); }

    if (valid) { Option::some(bytes[0] == LITERALS_TRUE[0]) } else { Option::none() }
}

unconstrained pub fn asField<N>(bytes: [u8; N]) -> Option<Field>
{
    let mut valid = // ensure at least one digit is valid
    if (N == 1)
    {
        (bytes[0] != BYTE_NULL) & (bytes[0] != MINUS)
    }
    else if (N != 0)
    {
        (bytes[0] != BYTE_NULL) | ((bytes[0] == MINUS) & (bytes[1] != BYTE_NULL))
    }
    else { false };

    let mut value    : Field = 0;
    let mut units    : Field = 1;
    let mut exponent : Field = -1;
    let mut checked_exponent = false;
    let mut has_exponent = false;
    for i in 0..N
    {
        if (valid)
        {
            let index : Field = (N - 1 - i); // walking property value bytes in reverse
            let byte = bytes[index];

            if ((byte >= 0x30) & (byte <= 0x39))
            {
                value += ((byte - 0x30) as Field) * units; // convert ASCII byte to integer digit number
                units *= 10;
            }
            else if ((byte == MINUS) | (byte == PLUS) | eE.any(|e| byte == e))
            {
                if (!checked_exponent)
                {
                    for j in 0..index { if (!has_exponent) { has_exponent = eE.any(|e| bytes[index - j] == e); } }
                    checked_exponent = true;
                }

                if (has_exponent & (exponent == -1))
                {
                    valid = (N as u64 >= 3) & (units != 1); // 0e-0 or 0e+0 or 0e0 and value is at least 0

                    if (valid)
                    {
                        exponent = 10.pow_32(value);
                        if (byte == MINUS) { exponent = (1 / exponent); }
                        // TODO: why does the line below fail a test asField::property_number_minus_three_zero_e_minus_one_as_field ?
                        // exponent = if (byte == MINUS) { 10.pow_32(-value) } else { 10.pow_32(value) };
                    }

                    value = 0;
                    units = 1;
                }
            }
            else
            {
                valid  = eE.any(|e| byte == e);
                valid |= ((value == 0) & (byte == BYTE_NULL));  // nulls accepted only at the end of array
                valid |= ((index == 0) & (byte == MINUS));      // minus accepted only at the start of the array when exponent is missing
            }
        }
    }

    if (valid)
    {
        if (exponent != -1) { value *= exponent; }

        if (bytes[0] == MINUS) { value = -value; }

        Option::some(value)
    }
    else { Option::none() }
}

unconstrained pub fn asInteger<N>(bytes: [u8; N]) -> Option<i127>
{
    let value = asField(bytes);

    if (value.is_some())
    {
        let value_field = value.unwrap_unchecked();
        let value_i127 =
        if (bytes[0] == MINUS) { (-(-value_field) as u126) as i127}
        else                        { int127FromField(value_field) };
                                    // { -int127FromUnsigned((-value_field) as u126)} // works
                                    // { (-int127FromField(-value_field) as u126) as i127 } // works
                                    // { -int127FromField(-value_field) } // TODO: this line fails

        { Option::some(value_i127) }
    }
    else { Option::none() }
}
