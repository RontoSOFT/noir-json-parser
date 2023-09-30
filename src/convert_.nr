use dep::std::option::Option;

use crate::JSON;

use crate::globals::BYTE_NULL;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::eE;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;

use crate::utils::int127FromField;

unconstrained
pub fn asBool(bytes: [u8]) -> Option<bool>
{
    let mut i : &mut Field = &mut -1;
    let equal_value = |a| { *i += 1; bytes[*i] == a };
    let check_four_bytes = || -> bool
    {
        if      (bytes[0] == LITERALS_TRUE[0]) { LITERALS_TRUE.all(equal_value) }
        else if (bytes[0] == LITERALS_NULL[0]) { LITERALS_NULL.all(equal_value) }
        else                                   { false }
    };

    let N = bytes.len();
    let mut valid = false;
    if      (N == 4) { valid = check_four_bytes(); }
    else if (N == 5)
    {
        if (bytes[4] == BYTE_NULL) { valid = check_four_bytes(); }
        else                       { valid = LITERALS_FALSE.all(equal_value); }
    }

    if (valid) { Option::some(bytes[0] == LITERALS_TRUE[0]) } else { Option::none() }
}

unconstrained
pub fn asField(bytes: [u8]) -> Option<Field>
{
    let N = bytes.len() as u64;

    let mut valid = // ensure at least one digit is valid
    (N < 78) &
    if (N == 1) { (bytes[0] != BYTE_NULL) & (bytes[0] != MINUS) & (bytes[0] != PLUS) }
    else        { ((bytes[0] != BYTE_NULL) & (bytes[0] != PLUS)) | ((bytes[0] == MINUS) & (bytes[1] != BYTE_NULL) & (bytes[1] != PLUS)) };

    if (valid)
    {
        let mut value : Field = 0;
        let mut units : Field = 1;
        let mut exponent : Field = -1;
        let mut checked_exponent = false;
        let mut has_exponent = false;

        for i in 0..N
        {
            if (valid)
            {
                let index = (N - 1 - i); // walking property value bytes in reverse
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
                        valid = ((N >= 3) & (units != 1)); // 0e-0 or 0e+0 or 0e0 and value is at least 0

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
    else { Option::none() }
}

unconstrained
pub fn asInteger(bytes: [u8]) -> Option<i127>
{
    let value = asField(bytes);

    if (value.is_some())
    {
        let value_field = value.unwrap_unchecked();
        let value_i127 =
        if (bytes[0] == MINUS) { (-(-value_field) as u126) as i127}
        else                   { int127FromField(value_field) };
                               // { -int127FromUnsigned((-value_field) as u126)} // works
                               // { (-int127FromField(-value_field) as u126) as i127 } // works
                               // { -int127FromField(-value_field) } // TODO: this line fails

        { Option::some(value_i127) }
    }
    else { Option::none() }
}

impl JSON
{
    // linear search of json keys to return an Option slice of the key's value bytes
    unconstrained
    pub fn bytesOf<KEY_SIZE>(self, key : str<KEY_SIZE>) -> Option<[u8]>
    {
        let key_bytes = key.as_bytes();
        let mut result : Option<[u8]> = Option::none();
        let mut found = false;
        for kvp in self.doc
        {
            found = (kvp.key.len() == KEY_SIZE);
            if (found)
            {
                for i in 0..KEY_SIZE { found &= (key_bytes[i] == kvp.key[i]); }

                if (found)
                {
                    let mut value_bytes : [u8] = [];
                    for i in 0..kvp.value.len() { value_bytes = value_bytes.push_back(kvp.value[i]); }
                    result = Option::some(value_bytes);
                }
            }
        }

        result
    }

    unconstrained
    pub fn getBool<N>(self, key : str<N>) -> Option<bool>
    {
        let option = self.bytesOf(key);

        if (option.is_some()) { asBool(option.unwrap_unchecked()) } else { Option::none() }
    }

    unconstrained
    pub fn getField<N>(self, key : str<N>) -> Option<Field>
    {
        let option = self.bytesOf(key);

        if (option.is_some()) { asField(option.unwrap_unchecked()) } else { Option::none() }
    }

    unconstrained
    pub fn getInteger<N>(self, key : str<N>) -> Option<i127>
    {
        let option = self.bytesOf(key);

        if (option.is_some()) { asInteger(option.unwrap_unchecked()) } else { Option::none() }
    }
}

    // let v : [u8] = option.unwrap_unchecked();
    // for i in 0..v.len() { dep::std::println(v[i]); }

    // unconstrained fn asUnsigned<N>(propName : str<N>) -> u54
    // unconstrained fn asSigned<N>(propName : str<N>) -> i54

    // for i in 0..bytes.len() { dep::std::println(bytes[i]); }
