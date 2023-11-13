use dep::std::option::Option;

use crate::JSON;
use crate::Object;

use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::BEGIN_OBJECT;
use crate::globals::END_OBJECT;
use crate::globals::VALUE_DELIMITER;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::POINT;
use crate::globals::ZERO;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;
use crate::globals::CHAR_f;
use crate::globals::CHAR_n;
use crate::globals::CHAR_t;

trait ByteArrayConversions
{
    fn as_bool(self : [u8]) -> Option<bool>;
    fn as_field(self : [u8]) -> Option<Field>;
    fn as_array(self : [u8]) -> Option<[[u8]]>;
    fn as_object(self : [u8], parent : JSON) -> Option<Object>;
}

trait PropertyConversions
{
    // linear search keys to return an Option slice containing associated value's bytes
    fn get<N>(self, key : str<N>) -> Option<[u8]>;

    fn get_bool<N>(self, key : str<N>) -> Option<bool>;
    fn get_field<N>(self, key : str<N>) -> Option<Field>;
    fn get_array<N>(self, key : str<N>) -> Option<[[u8]]>;
    fn get_object<N>(self, key : str<N>) -> Option<Object>;
}

unconstrained
fn get_whole(bytes : [u8], start : Field, end : Field) -> Field
{
    let mut it : Field = (end - 1); // walking in reverse
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
fn get_offsets(bytes : [u8]) -> Option<[Field; 5]>
{
    let mut result : Option<[Field; 5]> = Option::none();

    let size : Field = bytes.len(); // at least 1
    let first : u8 = bytes[0];
    let minus = (first == MINUS);

    // ensure at least one valid digit
    let mut valid =
    if (size == 1) { !minus }
    else        { (!((bytes[0] < 0x30) | (bytes[0] > 0x39)) | (minus & !(bytes[1] < 0x30) | (bytes[1] > 0x39))) };

    if (valid)
    {
        let mut offsets : [Field; 5] = [(minus as Field), size, 0, 0, 0];
        let mut decimal_point = false;
        for i in offsets[0]..size
        {
            if (valid)
            {
                let byte = bytes[i];

                if (byte == POINT)
                {
                    offsets[1] = i;       // end of whole bytes
                    offsets[2] = (i + 1); // start of fraction bytes

                    decimal_point = true;
                }
                else if ((byte == CHAR_e) | (byte == CHAR_E))
                {
                    if (decimal_point) { offsets[3] = i; } // end of fraction bytes
                    else               { offsets[1] = i; } // end of whole bytes

                    offsets[4] = (i + 1); // start of exponent bytes
                }
                else if ((byte == MINUS) | (byte == PLUS))
                {
                    offsets[4] = (i + 1); // start of exponent bytes
                }
                else { valid = ((byte - ZERO) < 10); }
            }
        }

        if (valid) { result = Option::some(offsets); }
    }

    result
}

impl ByteArrayConversions for [u8]
{
    unconstrained
    pub fn as_bool(self) -> Option<bool>
    {
        let mut result : Option<bool> = Option::none();

        if (self.len() != 0)
        {
            let OK = ((self[0] == CHAR_t) | (self[0] == CHAR_n) | (self[0] == CHAR_f));
            if (OK) { result = Option::some(self[0] == CHAR_t); }
        }

        result
    }

    unconstrained
    pub fn as_field(self) -> Option<Field>
    {
        let mut result : Option<Field> = Option::none();

        let option = get_offsets(self);
        if (option.is_some())
        {
            let offsets : [Field; 5] = option.unwrap_unchecked();

            // expect whole to have at least one digit, and decimal point to be missing
            if ((offsets[0] != offsets[1]) & (offsets[2] == offsets[3]))
            {
                let mut whole : Field = get_whole(self, offsets[0], offsets[1]);
                if (offsets[0] == 1) { whole = -whole; }
                if (offsets[4] != 0)
                {
                    let mut power : Field = 0;
                    let mut exponent : Field = 1;

                    power = get_whole(self, offsets[4], self.len());
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
        let size : Field = (self.len() - 1);

        if ((self[0] == BEGIN_ARRAY) & (self[size] == END_ARRAY))
        {
            let mut result : [[u8]] = [];
            let mut value : [u8] = [];
            let mut objects : Field = 0;
            let mut arrays : Field = 0;
            for i in 1..size
            {
                let byte = self[i];

                arrays  += (((byte == BEGIN_ARRAY) as Field)  - ((byte == END_ARRAY) as Field));
                objects += (((byte == BEGIN_OBJECT) as Field) - ((byte == END_OBJECT) as Field));

                if ((byte == VALUE_DELIMITER) & (arrays == 0) & (objects == 0))
                {
                    result = result.push_back(value);
                    value = [];
                }
                else { value = value.push_back(byte); }
            }

            Option::some(result.push_back(value))
        }
        else { Option::none() }
    }

    unconstrained
    pub fn as_object(self, parent : JSON) -> Option<Object>
    {
        let mut result : Option<Object> = Option::none();

        if (self.len() == 3)
        {
            let index : u8 = self[1];
            let OK = (self[0] == BEGIN_OBJECT) & (self[2] == END_OBJECT) & (index < (parent.children.len() as u8));
            if (OK) { result = Option::some(Object { parent, doc: parent.children[index] }); }
        }

        result
    }
}

impl PropertyConversions for Object
{
    unconstrained
    pub fn get<N>(self, key : str<N>) -> Option<[u8]>
    {
        let mut result : Option<[u8]> = Option::none();

        let size : Field = self.doc.len();
        let key_bytes : [u8; N] = key.as_bytes();
        for i in 0..size { if (result.is_none()) { if (self.doc[i].key.eq_array(key_bytes)) { result = Option::some(self.doc[i].value); } } }

        result
    }

    unconstrained
    pub fn get_bool<N>(self, key : str<N>) -> Option<bool>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_bool() } else { Option::none() }
    }

    unconstrained
    pub fn get_field<N>(self, key : str<N>) -> Option<Field>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_field() } else { Option::none() }
    }

    unconstrained
    pub fn get_array<N>(self, key : str<N>) -> Option<[[u8]]>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_array() } else { Option::none() }
    }

    unconstrained
    pub fn get_object<N>(self, key : str<N>) -> Option<Object>
    {
        let value = self.get(key);

        if (value.is_some()) { value.unwrap_unchecked().as_object(self.parent) } else { Option::none() }
    }
}

impl PropertyConversions for JSON
{
    unconstrained
    pub fn get<N>(self, key : str<N>) -> Option<[u8]>
    {
        let mut result : Option<[u8]> = Option::none();

        let size : Field = self.doc.len();
        let key_bytes : [u8; N] = key.as_bytes();
        for i in 0..size { if (result.is_none()) { if (self.doc[i].key.eq_array(key_bytes)) { result = Option::some(self.doc[i].value); } } }

        result
    }

    unconstrained
    pub fn get_bool<N>(self, key : str<N>) -> Option<bool>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_bool() } else { Option::none() }
    }

    unconstrained
    pub fn get_field<N>(self, key : str<N>) -> Option<Field>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_field() } else { Option::none() }
    }

    unconstrained
    pub fn get_array<N>(self, key : str<N>) -> Option<[[u8]]>
    {
        let option = self.get(key);

        if (option.is_some()) { option.unwrap_unchecked().as_array() } else { Option::none() }
    }

    unconstrained
    pub fn get_object<N>(self, key : str<N>) -> Option<Object>
    {
        let value = self.get(key);

        if (value.is_some()) { value.unwrap_unchecked().as_object(self) } else { Option::none() }
    }
}
