use dep::std::option::Option;

use crate::JSON;
use crate::Object;

use crate::globals::BYTE_NULL;
use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::BEGIN_OBJECT;
use crate::globals::END_OBJECT;
use crate::globals::VALUE_DELIMITER;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::POINT;
use crate::globals::ZERO;
use crate::globals::CHAR_a;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;
use crate::globals::CHAR_f;
use crate::globals::CHAR_l;
use crate::globals::CHAR_n;
use crate::globals::CHAR_r;
use crate::globals::CHAR_s;
use crate::globals::CHAR_t;
use crate::globals::CHAR_u;

unconstrained
fn get_whole(bytes: [u8], start : u64, end : u64) -> Field
{
    let mut it : u64 = (end - 1); // walking in reverse
    let mut whole : Field = ((bytes[it] as u4) as Field); // first digit is last in array
    let mut units : Field = 10;

    for _ in start..it
    {
        it -= 1;
        whole += (((bytes[it] as u4) as Field) * units); // cast ASCII byte to integer digit number
        units *= 10;
    }

    whole
}

unconstrained
fn get_offsets(bytes: [u8]) -> Option<[u64; 5]>
{
    let mut result : Option<[u64; 5]> = Option::none();

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

                if (byte == POINT)
                {
                    offsets[1] = i;       // end of whole bytes
                    offsets[2] = (i + 1); // start of fraction bytes

                    valid = !(decimal_point | exponent);
                    decimal_point = true;
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

                    exponent_minus = (byte == MINUS);
                    exponent_plus = !exponent_minus;
                }
                else { valid = ((byte - ZERO) < 10); }
            }
        }

        if (valid) { result = Option::some(offsets); }
    }

    result
}

trait ByteArrayConversions
{
    fn as_bool(self : [u8]) -> Option<bool>;
    fn as_field(self : [u8]) -> Option<Field>;
    fn as_array(self : [u8]) -> Option<[[u8]]>;
    fn as_object(self : [u8], json : JSON) -> Option<Object>;
}

impl ByteArrayConversions for [u8]
{
    unconstrained
    pub fn as_bool(self) -> Option<bool>
    {
        let mut OK = false;
        let len : Field = self.len();

        let len_4 = (len == 4);
        let t = (self[0] == CHAR_t);

        if      (len_4 & t)                        { OK = ((self[1] == CHAR_r) & (self[2] == CHAR_u) & (self[3] == CHAR_e)); }
        else if (len_4 & (self[0] == CHAR_n))      { OK = ((self[1] == CHAR_u) & (self[2] == CHAR_l) & (self[3] == CHAR_l)); }
        else if ((len == 5) & (self[0] == CHAR_f)) { OK = ((self[1] == CHAR_a) & (self[2] == CHAR_l) & (self[3] == CHAR_s) & (self[4] == CHAR_e)); }

        if (OK) { Option::some(t) } else { Option::none() }
    }

    unconstrained
    pub fn as_field(self: [u8]) -> Option<Field>
    {
        let mut result : Option<Field> = Option::none();

        let option = get_offsets(self);

        if (option.is_some())
        {
            let offsets : [u64; 5] = option.unwrap_unchecked();

            // expect whole to have at least one digit, and decimal point to be missing
            if ((offsets[0] < offsets[1]) & (offsets[2] == offsets[3]))
            {
                let mut whole : Field = get_whole(self, offsets[0], offsets[1]);
                if (offsets[0] == 1) { whole = -whole; }

                if (offsets[4] != 0)
                {
                    let mut power : Field = 0;
                    let mut exponent : Field = 1;

                    power = get_whole(self, offsets[4], (self.len() as u64));

                    for _ in 0..power { exponent *= 10; }

                    if (self[offsets[4] - 1] == MINUS) { whole /= exponent; } else { whole *= exponent; }
                }

                result = Option::some(whole);
            }
        }

        result
    }

    unconstrained
    pub fn as_array(self) -> Option<[[u8]]>
    {
        let mut result : [[u8]] = [];
        let mut value : [u8] = [];

        let len : u64 = ((self.len() - 1) as u64);
        let mut objects : u8 = 0;
        let mut arrays : u8 = 0;

        for i in 1..len // 1st byte is '[', last byte is ']'
        {
            let byte = self[i];

            arrays  += (((byte == BEGIN_ARRAY) as u8)  - ((byte == END_ARRAY) as u8));
            objects += (((byte == BEGIN_OBJECT) as u8) - ((byte == END_OBJECT) as u8));

            if ((byte == VALUE_DELIMITER) & (arrays == 0) & (objects == 0))
            {
                result = result.push_back(value);
                value = [];
            }
            else { value = value.push_back(byte); }
        }

        result = result.push_back(value);

        Option::some(result)
    }

    unconstrained
    pub fn as_object(self, parent : JSON) -> Option<Object>
    {
        let mut result : Option<Object> = Option::none();

        if (self.len() == 3)
        {
            let index : u8 = self[1];
            let OK = (self[0] == BEGIN_OBJECT) & (self[2] == END_OBJECT) & (index < (parent.children.len() as u8));
            if (OK) { result = Option::some(parent.children[index]); }
        }

        result
    }
}

trait PropertyConversions
{
    // linear search keys to return an Option slice containing associated value's bytes
    fn get<N>(self, key : str<N>) -> Option<[u8]>;

    fn get_bool<N>(self, key : str<N>) -> Option<bool>
    {
        let mut result : Option<bool> = Option::none();

        let option = self.get(key);
        if (option.is_some())
        {
            // a literal was parsed correctly if set as property value;
            // need to check only the first byte to match t, n or f
            let byte : u8 = option.unwrap_unchecked()[0];
            if ((byte == CHAR_t) | (byte == CHAR_n) | (byte == CHAR_f)) { result = Option::some(byte == CHAR_t); }
        }

        result
    }

    fn get_field<N>(self, key : str<N>) -> Option<Field>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_field() } else { Option::none() }
    }

    fn get_slice<N>(self, key : str<N>) -> Option<[[u8]]>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_array() } else { Option::none() }
    }
}

impl PropertyConversions for Object
{
    unconstrained
    pub fn get<N>(self, key : str<N>) -> Option<[u8]>
    {
        let mut result : Option<[u8]> = Option::none();

        let len = (self.len() as u64);
        let key_bytes = key.as_bytes();
        for i in 0..len { if (result.is_none()) { if (self[i].key.eq_array(key_bytes)) { result = Option::some(self[i].value); } } }

        result
    }
}

impl PropertyConversions for JSON
{
    unconstrained
    pub fn get<N>(self, key : str<N>) -> Option<[u8]> { self.doc.get(key) }
}
