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

trait ByteSliceConversions
{
    fn get_whole(bytes : [u8], begin : Field, end : Field) -> Field;
    fn get_offsets(bytes : [u8]) -> [Field; 5];

    fn as_bool(self : [u8]) -> Option<bool>;
    fn as_field(self : [u8]) -> Option<Field>;
    fn as_array(self : [u8]) -> [[u8]];
    fn as_object(self : [u8], parent : JSON) -> Object;
}

trait PropertyConversions
{
    // linear search keys to return an Option slice containing associated value's bytes
    fn get<N>(self, key : str<N>) -> [u8];

    fn get_bool<N>(self, key : str<N>) -> Option<bool>;
    fn get_field<N>(self, key : str<N>) -> Option<Field>;
    fn get_array<N>(self, key : str<N>) -> [[u8]];
    fn get_object<N>(self, key : str<N>) -> Object;
}

impl ByteSliceConversions for [u8]
{
    unconstrained
    fn get_whole(bytes : [u8], begin : Field, end : Field) -> Field
    {
        let mut it : Field = (end - 1); // walking in reverse
        let mut whole : Field = ((bytes[it] as u4) as Field); // first digit is last in array
        let mut units : Field = 10;

        for _ in begin..it
        {
            it -= 1;
            whole += (((bytes[it] as u4) as Field) * units); // cast ASCII byte to integer digit number
            units *= 10;
        }

        whole
    }

    unconstrained
    fn get_offsets(bytes : [u8]) -> [Field; 5]
    {
        let size : Field = bytes.len();
        if (size == 0) { [0; 5] }
        else
        {
            let mut result : [Field; 5] = [0; 5];
            let start : Field = ((bytes[0] == MINUS) as Field);

            // ensure at least one digit
            let mut valid = if (size != 1) { (bytes[start] - ZERO) < 10 } else { (bytes[0] - ZERO) < 10 };

            if (valid)
            {
                result[0] = start;
                result[1] = size;

                let mut decimal_point = false;
                for i in result[0]..size
                {
                    if (valid)
                    {
                        let byte = bytes[i];

                        if (byte == POINT)
                        {
                            result[1] = i;       // end of whole bytes
                            result[2] = (i + 1); // start of fraction bytes

                            decimal_point = true;
                        }
                        else if ((byte == CHAR_e) | (byte == CHAR_E))
                        {
                            if (decimal_point) { result[3] = i; } // end of fraction bytes
                            else               { result[1] = i; } // end of whole bytes

                            result[4] = (i + 1); // start of exponent bytes
                        }
                        else if ((byte == MINUS) | (byte == PLUS))
                        {
                            result[4] = (i + 1); // start of exponent bytes
                        }
                        else { valid = ((byte - ZERO) < 10); }
                    }
                }

                if (!valid) { result = [0; 5]; }
            }

            result
        }
    }

    unconstrained
    pub fn as_bool(self : [u8]) -> Option<bool>
    {
        let bytes : [u8] = self.parse_string();
        if (bytes.len() == 0) { Option::none() }
        else
        {
            let byte = bytes[0];
            let OK = ((byte == CHAR_t) | (byte == CHAR_n) | (byte == CHAR_f));
            if (OK) { Option::some(byte == CHAR_t) } else { Option::none() }
        }
    }

    unconstrained
    pub fn as_field(self : [u8]) -> Option<Field>
    {
        let mut result : Option<Field> = Option::none();

        let bytes : [u8] = self.parse_string();
        let mut offsets : [Field; 5] = bytes.get_offsets();

        let first : Field = offsets[0];
        let second : Field = offsets[1];
        let last : Field = offsets[4];

        // expect whole to have at least one digit and decimal point to be missing
        if ((first != second) & (offsets[2] == offsets[3]))
        {
            let mut whole : Field = bytes.get_whole(first, second);
            if (first == 1) { whole = -whole; }

            if (last != 0) // apply exponent
            {
                let power : Field = bytes.get_whole(last, bytes.len());

                let mut exponent : Field = 1;
                for _ in 0..power { exponent *= 10; }

                if (bytes[last - 1] == MINUS) { whole /= exponent; } else { whole *= exponent; }
            }

            result = Option::some(whole);
        }

        result
    }

    unconstrained
    pub fn as_array(self : [u8]) -> [[u8]]
    {
        let bytes : [u8] = self.parse_string();

        let mut size : Field = bytes.len();
        if (size == 0) | (size == 1) { [] }
        else
        {
            size -= 1;
            if ((bytes[0] == BEGIN_ARRAY) & (bytes[size] == END_ARRAY))
            {
                let mut result : [[u8]] = [];
                let mut value : [u8] = [];
                let mut objects : Field = 0;
                let mut arrays : Field = 0;
                for i in 1..size
                {
                    let byte = bytes[i];

                    arrays  += (((byte == BEGIN_ARRAY) as Field)  - ((byte == END_ARRAY) as Field));
                    objects += (((byte == BEGIN_OBJECT) as Field) - ((byte == END_OBJECT) as Field));

                    if ((byte == VALUE_DELIMITER) & (arrays == 0) & (objects == 0))
                    {
                        result = result.push_back(value);
                        value = [];
                    }
                    else { value = value.push_back(byte); }
                }

                result.push_back(value)
            }
            else { [] }
        }
    }

    unconstrained
    pub fn as_object(self : [u8], parent : JSON) -> Object
    {
        let mut result : Object = Object::none();

        let bytes : [u8] = self.parse_string();
        let size : Field = bytes.len();

        if      ((size == 0) & (self.len() as u64) > 2) { result = Object { parent, doc: [crate::Property::none()] }; }
        else if (size == 3)
        {
            let index : u8 = bytes[1];
            let OK = (bytes[0] == BEGIN_OBJECT) & (bytes[2] == END_OBJECT) & (index < (parent.children.len() as u8));
            if (OK) { result = Object { parent, doc: parent.children[index] }; }
        }

        result
    }
}

impl PropertyConversions for Object
{
    unconstrained
    pub fn get<N>(self : Object, key : str<N>) -> [u8]
    {
        let mut result : [u8] = [];

        let key_bytes : [u8; N] = key.as_bytes();
        let size : Field = self.doc.len();
        for i in 0..size { if (result.len() == 0) { if (self.doc[i].key.eq_array(key_bytes)) { result = self.doc[i].value; } } }

        result
    }

    unconstrained
    pub fn get_bool<N>(self : Object, key : str<N>) -> Option<bool> { self.get(key).as_bool() }

    unconstrained
    pub fn get_field<N>(self : Object, key : str<N>) -> Option<Field> { self.get(key).as_field() }

    unconstrained
    pub fn get_array<N>(self : Object, key : str<N>) -> [[u8]] { self.get(key).as_array() }

    unconstrained
    pub fn get_object<N>(self : Object, key : str<N>) -> Object { self.get(key).as_object(self.parent) }
}

impl PropertyConversions for JSON
{
    unconstrained
    pub fn get<N>(self : JSON, key : str<N>) -> [u8]
    {
        let mut result : [u8] = [];

        let key_bytes : [u8; N] = key.as_bytes();
        let size : Field = self.doc.len();
        for i in 0..size { if (result.len() == 0) { if (self.doc[i].key.eq_array(key_bytes)) { result = self.doc[i].value; } } }

        result
    }

    unconstrained
    pub fn get_bool<N>(self : JSON, key : str<N>) -> Option<bool> { self.get(key).as_bool() }

    unconstrained
    pub fn get_field<N>(self : JSON, key : str<N>) -> Option<Field> { self.get(key).as_field() }

    unconstrained
    pub fn get_array<N>(self : JSON, key : str<N>) -> [[u8]] { self.get(key).as_array() }

    unconstrained
    pub fn get_object<N>(self : JSON, key : str<N>) -> Object
    {
        let k = self.get(key);
        // dep::std::println("KKK");
        // k.print();
        k.as_object(self) }
}
