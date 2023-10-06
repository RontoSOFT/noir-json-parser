use dep::std::option::Option;

use crate::JSON;

use crate::globals::BYTE_NULL;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::eE;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;
use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::VALUE_DELIMITER;

trait Conversions
{
    fn asBool(self) -> Option<bool>;
    fn asField(self) -> Option<Field>;
    fn asSlice(self) -> Option<[[u8]]>;
}

impl Conversions for [u8]
{
    unconstrained
    pub fn asBool(self) -> Option<bool>
    {
        let mut i : &mut Field = &mut -1;
        let equal_value = |a| { *i += 1; self[*i] == a };
        let check_four_bytes = || -> bool
        {
            if      (self[0] == LITERALS_TRUE[0]) { LITERALS_TRUE.all(equal_value) }
            else if (self[0] == LITERALS_NULL[0]) { LITERALS_NULL.all(equal_value) }
            else                                   { false }
        };

        let N = self.len();
        let mut valid = false;
        if      (N == 4) { valid = check_four_bytes(); }
        else if (N == 5)
        {
            if (self[4] == BYTE_NULL) { valid = check_four_bytes(); }
            else                       { valid = LITERALS_FALSE.all(equal_value); }
        }

        if (valid) { Option::some(self[0] == LITERALS_TRUE[0]) } else { Option::none() }
    }

    unconstrained
    pub fn asField(self) -> Option<Field>
    {
        let N = self.len() as u64;

        let mut valid = // ensure at least one digit is valid
        (N < 78) &
        if (N == 1) { (self[0] != BYTE_NULL) & (self[0] != MINUS) & (self[0] != PLUS) }
        else        { ((self[0] != BYTE_NULL) & (self[0] != PLUS)) | ((self[0] == MINUS) & (self[1] != BYTE_NULL) & (self[1] != PLUS)) };

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
                    let index = (N - 1 - i); // walking property value self in reverse
                    let byte = self[index];

                    if ((byte >= 0x30) & (byte <= 0x39))
                    {
                        value += ((byte - 0x30) as Field) * units; // convert ASCII byte to integer digit number
                        units *= 10;
                    }
                    else if ((byte == MINUS) | (byte == PLUS) | eE.any(|e| byte == e))
                    {
                        if (!checked_exponent)
                        {
                            for j in 0..index { if (!has_exponent) { has_exponent = eE.any(|e| self[index - j] == e); } }
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
                if (self[0] == MINUS) { value = -value; }
                Option::some(value)
            }
            else { Option::none() }
        }
        else { Option::none() }
    }

    unconstrained
    pub fn asSlice(self) -> Option<[ [u8] ]>
    {
        let mut result : [ [u8] ] = [];
        let mut current_value : [u8] = [];

        let mut count_inner_arrays : Field = 0;

        for i in 1..(self.len() - 1) // 1st byte is '[', last byte is ']'
        {
            if      (self[i] == BEGIN_ARRAY) { count_inner_arrays += 1; }
            else if ((self[i] == END_ARRAY)) { count_inner_arrays -= 1; }

            if ((self[i] == VALUE_DELIMITER) & (count_inner_arrays == 0))
            {
                result = result.push_back(current_value);
                current_value = [];
            }
            else { current_value = current_value.push_back(self[i]); }
        }

        result = result.push_back(current_value);

        Option::some(result)
    }
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

        if (option.is_some()) { option.unwrap_unchecked().asBool() } else { Option::none() }
    }

    unconstrained
    pub fn getInteger<N>(self, key : str<N>) -> Option<i54>
    {
        let mut result : Option<i54> = Option::none();
        let option = self.bytesOf(key);
        if (option.is_some())
        {
            let bytes : [u8] = option.unwrap_unchecked();
            let value = bytes.asField();
            if (value.is_some())
            {
                let value_field = value.unwrap_unchecked();
                let value_i54 = if (bytes[0] == MINUS) { -((-value_field) as i54) } else { value_field as i54 };

                result = Option::some(value_i54);
            }
        }

        result
    }

    unconstrained
    pub fn getSlice<N>(self, key : str<N>) -> Option<[[u8]]>
    {
        if (N == 0) { if (self.doc.len() == 1) { self.doc[0].value.asSlice() } else { Option::none() } }
        else
        {
            let option = self.bytesOf(key);

            if (option.is_some()) { option.unwrap_unchecked().asSlice() } else { Option::none() }
        }
    }
}
