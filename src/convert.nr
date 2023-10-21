use dep::std::option::Option;

use crate::JSON;

use crate::globals::BYTE_NULL;
use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::VALUE_DELIMITER;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_FALSE;
use crate::globals::MINUS;
use crate::globals::DECIMAL_POINT;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;
use crate::globals::PLUS;

unconstrained
fn getWhole(bytes: [u8], start : u64, end : u64) -> Field
{
    let mut it : u64 = (end - 1); // walking in reverse
    let mut whole : Field = ((bytes[it] - 0x30) as Field); // first digit is last in array
    let mut units : Field = 10;

    for _ in start..it
    {
        it -= 1;
        whole += (((bytes[it] - 0x30) as Field) * units); // convert ASCII byte to integer digit number
        units *= 10;
    }

    whole
}

unconstrained
fn getOffsets(bytes: [u8]) -> Option<[u64; 5]>
{
    let mut result = Option::none();

    let N : u64 = (bytes.len() as u64);
    let first : u8 = bytes[0];

    let minus = (first == MINUS);

    let mut valid =
    (N < 78) & // ensure at least one digit is valid
    if (N == 1) { (first != BYTE_NULL) & !minus & (first != PLUS) }
    else        { ((first != BYTE_NULL) & (first != PLUS)) | (minus & (bytes[1] != BYTE_NULL) & (bytes[1] != PLUS)) };

    if (valid)
    {
        let mut offsets : [u64; 5] = [(minus as u64), N, 0, 0, 0];

        let mut decimal_point = false;
        let mut exponent = false;
        let mut exponent_minus = false;
        let mut exponent_plus = false;
        for i in offsets[0]..N
        {
            if (valid)
            {
                let byte = bytes[i];

                if (byte == DECIMAL_POINT)
                {
                    valid = !(decimal_point | exponent);
                    decimal_point = true;

                    offsets[1] = i;       // end of whole bytes
                    offsets[2] = (i + 1); // start of fraction bytes
                }
                else if ((byte == CHAR_e) | (byte == CHAR_E))
                {
                    if (decimal_point) { offsets[3] = i; } // end of fraction bytes
                    else               { offsets[1] = i; } // end of whole bytes

                    offsets[4] = (i + 1); // start of exponent bytes

                    valid = !exponent;
                    exponent = true;
                }
                else if ((byte == MINUS) | (byte == PLUS))
                {
                    offsets[4] = (i + 1); // start of exponent bytes
                    valid = (exponent & !(exponent_minus | exponent_plus));
                    exponent_plus = (byte == MINUS);
                    exponent_minus = (byte == PLUS);
                }
                else { valid = ((byte > 0x2F) & (byte < 0x3A)); }
            }
        }

        if (valid) { result = Option::some(offsets); }
    }

    result
}

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
    pub fn asField(self: [u8]) -> Option<Field>
    {
        let mut result = Option::none();

        let option = getOffsets(self);

        if (option.is_some())
        {
            let offsets : [u64; 5] = option.unwrap_unchecked();

            // expect whole to have at least one digit, and decimal point to be missing
            if ((offsets[0] < offsets[1]) & (offsets[2] == offsets[3]))
            {
                let mut whole : Field = 0;
                whole = getWhole(self, offsets[0], offsets[1]);
                if (offsets[0] == 1) { whole = -whole; }

                if (offsets[4] != 0)
                {
                    let mut power : Field = 0;
                    let mut exponent : Field = 1;

                    power = getWhole(self, offsets[4], (self.len() as u64));

                    for _ in 0..power { exponent *= 10; }

                    if (self[offsets[4] - 1] == MINUS) { whole /= exponent; } else { whole *= exponent; }
                }

                result = Option::some(whole);
            }
        }

        result
    }

    unconstrained
    pub fn asSlice(self) -> Option<[[u8]]>
    {
        let mut result : [[u8]] = [];
        let mut value : [u8] = [];

        let len : u64 = ((self.len() - 1) as u64);
        let mut count : u8 = 0;

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
        let key_bytes = key.as_bytes();
        let len : u64 = (self.doc.len() as u64);
        let mut index = -1;
        for i in 0..len { if (index == -1) { if (self.doc[i].key.eq_array(key_bytes)) { index = i; } } }

        if (index != -1) { Option::some(self.doc[index].value) } else { Option::none() }
    }

    unconstrained
    pub fn getBool<N>(self, key : str<N>) -> Option<bool>
    {
        let option = self.bytesOf(key);

        if (option.is_some()) { self.bytesOf(key).unwrap().asBool() } else { Option::none() }
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
