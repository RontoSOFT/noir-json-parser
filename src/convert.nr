use dep::std::option::Option;

use crate::JSON;

use crate::globals::BYTE_NULL;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;
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
        if      (self.eq_array(LITERALS_TRUE))  { Option::some(true) }
        else if (self.eq_array(LITERALS_NULL))  { Option::some(false) }
        else if (self.eq_array(LITERALS_FALSE)) { Option::some(false) }
        else                                    { Option::none() }
    }

    unconstrained
    pub fn asField(self) -> Option<Field>
    {
        let mut result = Option::none();

        let N : u64 = (self.len() as u64);
        let mut valid = // ensure at least one digit is valid
        (N < 78) &
        if (N == 1) { (self[0] != BYTE_NULL) & (self[0] != MINUS) & (self[0] != PLUS) }
        else        { ((self[0] != BYTE_NULL) & (self[0] != PLUS)) | ((self[0] == MINUS) & (self[1] != BYTE_NULL) & (self[1] != PLUS)) };

        if (!valid) { result } // early return guard

        let mut value : Field = 0;
        let mut units : Field = 1;
        let mut exponent : Field = 0;
        let mut checked_exponent = false;
        let mut has_exponent = false;

        for i in 0..N
        {
            if (valid)
            {
                let index : u64 = (N - 1 - i); // walking property value self in reverse
                let byte : u8 = self[index];

                if ((byte > 0x2F) & (byte < 0x3A))
                {
                    value += (((byte - 0x30) as Field) * units); // convert ASCII byte to integer digit number
                    units *= 10;
                }
                else if ((byte == MINUS) | (byte == PLUS) | (byte == CHAR_e) | (byte == CHAR_E))
                {
                    if (!checked_exponent)
                    {
                        for j in 0..index { if (!has_exponent) { has_exponent = ((self[index - j] == CHAR_e) | (self[index - j] == CHAR_E)); } }
                        checked_exponent = true;
                    }

                    if (has_exponent & (exponent == 0))
                    {
                        valid = ((N > 2) & (units != 1)); // 0e-0 or 0e+0 or 0e0 and value is at least 0

                        if (valid)
                        {
                            exponent = 1;
                            for _ in 0..value { exponent *= 10; }
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
                    valid  = ((byte == CHAR_e) | (byte == CHAR_E));
                    valid |= ((value == 0) & (byte == BYTE_NULL));  // nulls accepted only at the end of array
                    valid |= ((index == 0) & (byte == MINUS));      // minus accepted only at the start of the array when exponent is missing
                }
            }
        }

        if (valid)
        {
            if (exponent != 0)    { value *= exponent; }
            if (self[0] == MINUS) { value = -value; }

            result = Option::some(value);
        }

        result
    }

    unconstrained
    pub fn asSlice(self) -> Option<[[u8]]>
    {
        let mut result : [[u8]] = [];
        let mut value : [u8] = [];
        let mut count : u8 = 0;

        let len : u64 = ((self.len() - 1) as u64);
        for i in 1..len // 1st byte is '[', last byte is ']'
        {
            let byte = self[i];
            count += (0 ^ ((byte == BEGIN_ARRAY) as u8));
            count -= (0 ^ ((byte == END_ARRAY) as u8));

            if ((byte == VALUE_DELIMITER) & (count == 0))
            {
                result = result.push_back(value);
                value = [];
            }
            else { value = value.push_back(byte); }
        }

        result = result.push_back(value);

        Option::some(result)
    }
}

impl JSON
{
    // linear search of json keys to return an Option slice of the key's value bytes
    unconstrained
    pub fn bytesOf<N>(self, key : str<N>) -> Option<[u8]>
    {
        let len : u64 = (self.doc.len() as u64);
        let mut index = -1;
        for i in 0..len { if (index == -1) { if (self.doc[i].key.eq_string(key)) { index = i; } } }

        if (index != -1) { Option::some(self.doc[index].value) } else { Option::none() }
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
                let value_field : Field = value.unwrap_unchecked();
                let value_i54 : i54 = if (bytes[0] == MINUS) { -((-value_field) as i54) } else { value_field as i54 };

                result = Option::some(value_i54);
            }
        }

        result
    }

    unconstrained
    pub fn getSlice<N>(self, key : str<N>) -> Option<[[u8]]>
    {
        let option = self.bytesOf(key);

        if (option.is_some()) { option.unwrap_unchecked().asSlice() } else { Option::none() }
    }

    unconstrained
    pub fn asSlice(self) -> Option<[[u8]]> { if (self.doc.len() == 1) { self.doc[0].value.asSlice() } else { Option::none() } }
}
