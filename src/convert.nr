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
use crate::globals::FIELD_true;
use crate::globals::FIELD_null;
use crate::globals::FIELD_false;

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
    fn as_object(self) -> JSON;
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
        let size : Field = self.len();
        if (size == 0) { [0; 5] }
        else
        {
            let start : Field = ((self[0] == MINUS) as Field);
            let mut result : [Field; 5] = [start, size, 0, 0, 0];
            let mut decimal_point : Field = 0;
            for i in start..size
            {
                if (result[0] != result[1])
                {
                    let byte = self[i];

                    if (byte == POINT)
                    {
                        result[1] = i;       // end of whole bytes
                        result[2] = (i + 1); // start of fraction bytes

                        decimal_point = 1;
                    }
                    else if ((byte == CHAR_e) | (byte == CHAR_E))
                    {
                        result[1 + (decimal_point * 2)] = i; // 1 - end of whole bytes, 3 - end of fraction bytes
                        result[4] = (i + 1); // start of exponent bytes
                    }
                    else if ((byte == MINUS) | (byte == PLUS))
                    {
                        result[4] = (i + 1); // start of exponent bytes
                    }
                    else if ((byte - ZERO) > 9) { result = [0; 5]; }
                }
            }

            result
        }
    }
}

impl<N> ByteArrayConversions for [u8; N]
{
    unconstrained
    pub fn as_bool(self) -> Option<bool>
    {
        let size = self.len();

        if (size == 0) { Option::none() }
        else
        {
            let mut result : Option<bool> = Option::none();

            if (self[0] == QUOTATION_MARK)
            {
                let json = self.parse(&mut 1, (size - 1), -1);
                if (json.doc.len() != 0)
                {
                    if (json.doc[0].value.len() != 0)
                    {
                        let byte : u8 = json.doc[0].value[0];
                        let OK = ((byte == CHAR_t) | (byte == CHAR_n) | (byte == CHAR_f));
                        if (OK) { result = Option::some(byte == CHAR_t); }
                    }
                }
            }
            else
            {
                let mut literal_field = (self[0] as Field);
                for i in 1..size
                {
                    literal_field *= 256;
                    literal_field += (self[i] as Field);
                }

                let OK = ((literal_field == FIELD_true) | (literal_field == FIELD_null) | (literal_field == FIELD_false));
                if (OK) { result = Option::some(literal_field == FIELD_true); }
            }

            result
        }
    }

    unconstrained
    pub fn as_field(self) -> Option<Field>
    {
        let size = self.len();

        let mut offset = 0;
        let mut offsets : [Field; 5] = [0; 5];

        if (size != 0)
        {
            if (self[0] == QUOTATION_MARK)
            {
                let json = self.parse(&mut 1, (size - 1), -1);
                if (json.doc.len() != 0)
                {
                    offsets = json.doc[0].value.get_offsets();
                    offset = 1;
                }
            }
            else { offsets = self.get_offsets(); }
        }

        let first : Field = offsets[0] + offset;
        let second : Field = offsets[1] + offset;
        let last : Field = offsets[4] + offset;

        let mut result : Option<Field> = Option::none();

        // expect whole to have at least one digit and decimal point to be missing
        if ((first != second) & (offsets[2] == offsets[3]))
        {
            let mut whole : Field = self.get_whole(first, second);
            if (first == (1 + offset)) { whole = -whole; }

            if (last != offset) // apply exponent
            {
                let power : Field = self.get_whole(last, size - offset);

                let mut exponent : Field = 1;
                for _ in 0..power { exponent *= 10; }

                if (self[last - 1] == MINUS) { whole /= exponent; } else { whole *= exponent; }
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
        let size = self.len();

        if      (size == 0) { [] }
        else if (self[0] == QUOTATION_MARK)
        {
            let json = self.parse(&mut 1, (size - 1), -1);
            if (json.doc.len() != 0) { json.doc[0].value.parse_list() } else { [] }
        }
        else { self.parse_list() }
    }

    unconstrained
    pub fn as_object(self) -> JSON
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
    unconstrained pub fn as_bool(self) -> Option<bool>   { self.as_bytes().as_bool() }
    unconstrained pub fn as_field(self) -> Option<Field> { self.as_bytes().as_field() }
    unconstrained pub fn as_string(self) -> [u8]         { self.as_bytes().as_slice() }
    unconstrained pub fn as_list(self) -> [[u8]]         { self.as_bytes().as_list() }
    unconstrained pub fn as_object(self) -> JSON         { self.as_bytes().as_object() }
}

impl JSON
{
    unconstrained pub fn get_bool<N>  (self, key : str<N>) -> Option<bool>  { self.doc.get(key).as_bool() }
    unconstrained pub fn get_field<N> (self, key : str<N>) -> Option<Field> { self.doc.get(key).as_field() }
    unconstrained pub fn get_string<N>(self, key : str<N>) -> [u8]          { self.doc.get(key).as_string() }
    unconstrained pub fn get_array<N> (self, key : str<N>) -> [[u8]]        { self.doc.get(key).as_list() }

    unconstrained
    pub fn get_object<N>(self, key : str<N>) -> JSON
    {
        let bytes = self.doc.get(key);

        let size : Field = bytes.len();
        if (size == 0) { JSON::none() }
        {
            if (bytes[0] == QUOTATION_MARK) { bytes.parse(&mut 1, (size - 1), -1) }
            else
            {
                let mut result : JSON = JSON::none();

                let OK = ((bytes[0] == BEGIN_OBJECT) & (bytes[size - 1] == END_OBJECT));
                if (OK & (size == 3))
                {
                    let index : u8 = bytes[1];
                    if (index < (self.children.len() as u8)) { result = self.child(index); }
                }
                else if (OK & (size != 1)) { result.doc = [crate::Property::none()]; }

                result
            }
        }
    }
}
