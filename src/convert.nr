use dep::std::option::Option;

use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::BEGIN_OBJECT;
use crate::globals::END_OBJECT;
use crate::globals::VALUE_DELIMITER;
use crate::globals::QUOTATION_MARK;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::POINT;
use crate::globals::ZERO;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;
use crate::globals::CHAR_f;
use crate::globals::CHAR_n;
use crate::globals::CHAR_t;

use crate::JSON;
use crate::Object;

trait FieldConversion
{
    fn get_whole(self, begin : Field, end : Field) -> Field;
    fn get_offsets(self) -> [Field; 5];
}

trait ByteArrayConversions
{
    fn as_bool(self) -> Option<bool>;
    fn as_field(self) -> Option<Field>;
    fn as_string(self) -> [u8];
    fn as_list(self) -> [[u8]];
    fn as_object(self, parent : JSON) -> JSON;
    fn as_json(self) -> JSON;
}

impl<N> FieldConversion for [u8; N]
{
    unconstrained
    fn get_whole(self, begin : Field, end : Field) -> Field
    {
        let mut it : Field = (end - 1); // walking in reverse
        let mut whole : Field = ((self[it] as u4) as Field); // first digit is last in array
        let mut units : Field = 10;

        for _ in begin..it
        {
            it -= 1;
            whole += (((self[it] as u4) as Field) * units); // cast ASCII byte to integer digit number
            units *= 10;
        }

        whole
    }

    unconstrained
    fn get_offsets(self) -> [Field; 5]
    {
        let mut result : [Field; 5] = [0; 5];

        let size : Field = self.len();
        if (size != 0)
        {
            let start : Field = ((self[0] == MINUS) as Field);

            // ensure at least one digit
            let mut valid = if (size != 1) { (self[start] - ZERO) < 10 } else { (self[0] - ZERO) < 10 };

            if (valid)
            {
                result[0] = start;
                result[1] = size;

                let mut decimal_point = false;
                for i in start..size
                {
                    if (valid)
                    {
                        let byte = self[i];

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
        }

        result
    }
}

impl<N> ByteArrayConversions for [u8; N]
{
    unconstrained
    pub fn as_bool(self) -> Option<bool>
    {
        let bytes : [u8] = self.parse_value();

        if (bytes.len() == 0) { Option::none() }
        else
        {
            let byte = bytes[0];
            let OK = ((byte == CHAR_t) | (byte == CHAR_n) | (byte == CHAR_f));
            if (OK) { Option::some(byte == CHAR_t) } else { Option::none() }
        }
    }

    unconstrained
    pub fn as_field(self) -> Option<Field>
    {
        let bytes : [u8] = self.parse_value();

        let mut offsets : [Field; 5] = bytes.get_offsets();

        let first : Field = offsets[0];
        let second : Field = offsets[1];
        let last : Field = offsets[4];

        let mut result : Option<Field> = Option::none();

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
    pub fn as_string(self) -> [u8]
    {
        let mut bytes : [u8] = [];

        let mut size : Field = self.len();
        if (size != 0)
        {
            size -= 1;
            if (self[0] == QUOTATION_MARK) & (self[size] == QUOTATION_MARK)
            {
                for i in 1..size { bytes = bytes.push_back(self[i]); }
            }
        }

        bytes
    }

    unconstrained
    pub fn as_list(self) -> [[u8]]
    {
        let bytes : [u8] = self.parse_value();

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
    pub fn as_object(self, parent : JSON) -> JSON
    {
        let mut result : JSON = JSON::none();

        let size : Field = self.len();
        if (size != 0)
        {
            if (self[0] == QUOTATION_MARK)
            {
                result = self.parse(&mut 1, (self.len() - 1), -1);
            }
            else
            {
                let OK = ((self[0] == BEGIN_OBJECT) & (self[size - 1] == END_OBJECT));

                if (OK & (size == 3))
                {
                    let index : u8 = self[1];
                    if (index < (parent.children.len() as u8)) { result = parent.child(index); }
                }
                else if (OK & (size != 1)) { result.doc = [crate::Property::none()]; }
            }
        }

        result
    }

    unconstrained
    pub fn as_json(self) -> JSON
    {
        let mut size : Field = self.len();
        if (size == 0) { JSON::none() }
        else
        {
            let mut offset : Field = ((self[0] == QUOTATION_MARK) as Field);
            self.parse(&mut offset, (size - offset), -1)
        }
    }
}

impl<N> ByteArrayConversions for str<N>
{
    unconstrained
    pub fn as_bool(self) -> Option<bool> { self.as_bytes().as_bool() }

    unconstrained
    pub fn as_field(self) -> Option<Field> { self.as_bytes().as_field() }

    unconstrained
    pub fn as_list(self) -> [[u8]] { self.as_bytes().as_list() }

    unconstrained
    pub fn as_string(self) -> [u8] { self.as_bytes().as_slice() }

    unconstrained
    pub fn as_object(self, parent : JSON) -> JSON { self.as_bytes().as_object(parent) }

    unconstrained
    pub fn as_json(self) -> JSON { self.as_bytes().as_json() }
}

impl JSON
{
    unconstrained
    pub fn get_bool<N>  (self, key : str<N>) -> Option<bool>  { self.doc.get(key).as_bool() }

    unconstrained
    pub fn get_field<N> (self, key : str<N>) -> Option<Field> { self.doc.get(key).as_field() }

    unconstrained
    pub fn get_string<N>(self, key : str<N>) -> [u8]          { self.doc.get(key).as_string() }

    unconstrained
    pub fn get_array<N> (self, key : str<N>) -> [[u8]]        { self.doc.get(key).as_list() }

    unconstrained
    pub fn get_object<N>(self, key : str<N>) -> JSON          { self.doc.get(key).as_object(self) }
}
