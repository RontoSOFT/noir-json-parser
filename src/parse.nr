use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::BEGIN_OBJECT;
use crate::globals::END_OBJECT;
use crate::globals::KEY_DELIMITER;
use crate::globals::VALUE_DELIMITER;
use crate::globals::QUOTATION_MARK;
use crate::globals::BACKSLASH;
use crate::globals::TAB;
use crate::globals::NEWLINE;
use crate::globals::RETURN;
use crate::globals::SPACE;
use crate::globals::MINUS;
use crate::globals::PLUS;
use crate::globals::ZERO;
use crate::globals::POINT;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;
use crate::globals::FIELD_true;
use crate::globals::FIELD_null;
use crate::globals::FIELD_false;

use crate::JSON;
use crate::Object;
use crate::Property;

trait PropertyLookup
{
    fn get<N> (self, key : str<N>) -> [u8];

    fn linear_search<N>(self, key : [u8; N], index : Field) -> [u8];
    fn binary_search<N>(self, key : [u8; N], begin : Field, end : Field) -> [u8];
}

trait ByteArrayParser
{
    fn parse_list(self) -> [[u8]];
    fn eat_whitespace(self, index : Field, end : Field) -> Field;
    fn eat_literal(self, result : [u8], index : Field, end: Field, literal_field : Field) -> ([u8], Field, Field);
    fn parse(self, begin : &mut Field, end : Field, child_index : Field) -> JSON;
}

impl JSON
{
    unconstrained
    pub fn parse<SIZE>(string : str<SIZE>) -> Self { string.as_bytes().parse(&mut 0, SIZE, -1) }

    unconstrained
    fn store(self, prop : Property) -> Object
    {
        let mut copy : Object = [];

        // linear insert
        for current in self.doc { if (!prop.key.eq(current.key)) { copy = copy.push_back(current); } }
        copy.push_back(prop)

        // // sorted insert
        // let mut inserted = false;
        // for current in self.doc
        // {
        //     if (inserted) { copy = copy.push_back(current); }
        //     else
        //     {
        //         let (less_than, equal) = prop.key.less_than_or_eq(current.key);
        //         if (less_than | equal)
        //         {
        //             copy = copy.push_back(prop);
        //             inserted = true;
        //         }

        //         if (!equal) { copy = copy.push_back(current); }
        //     }
        // }
        // if (inserted) { copy } else { copy.push_back(prop) }
    }

    unconstrained
    pub fn len(self) -> Field { self.doc.len() }

    unconstrained
    pub fn get<N> (self, key : str<N>) -> [u8] { self.doc.get(key) }
}

impl PropertyLookup for Object
{
    unconstrained
    pub fn get<N> (self, key : str<N>) -> [u8] { self.linear_search(key.as_bytes(), (self.len() - 1)) }
    // pub fn get<N> (self, key : str<N>) -> [u8] { self.binary_search(key.as_bytes(), 0, (self.len() - 1)) }

    unconstrained
    pub fn linear_search<N>(self, key : [u8; N], index : Field) -> [u8]
    {
        if      (index == -1)             { [] }
        else if (key.eq(self[index].key)) { self[index].value }
        else                              { self.linear_search(key, (index - 1)) }
    }

    unconstrained
    pub fn binary_search<N>(self, key : [u8; N], begin : Field, end : Field) -> [u8]
    {
        if (begin == (end + 1)) { [] }
        else
        {
            let middle : Field = ((((begin + end) as u64) / 2) as Field);
            let (less_than, equal) = key.less_than_or_eq(self[middle].key);

            if      (equal)     { self[middle].value }
            else if (less_than) { self.binary_search(key, begin, (middle - 1)) }
            else                { self.binary_search(key, (middle + 1), end) }
        }
    }
}

impl<N> ByteArrayParser for [u8; N]
{
    unconstrained
    fn parse_list(self) -> [[u8]]
    {
        let mut size : Field = self.len();
        if (size == 0) | (size == 1) { [] }
        else
        {
            size -= 1;
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

                result.push_back(value)
            }
            else { [] }
        }
    }

    unconstrained
    fn eat_whitespace(self, index : Field, end : Field) -> Field
    {
        if ((index == end) | (self[index] > SPACE)) { index } else { self.eat_whitespace((index + 1), end) }
    }

    unconstrained
    fn eat_literal(self, result : [u8], index : Field, end: Field, literal_field : Field) -> ([u8], Field, Field)
    {
        if (index == end) { (result, index, literal_field) }
        else
        {
            let byte = self[index];
            let OK = (byte == 0x61) | (byte == 0x6C) | ((byte - 0x65) < 2) | ((byte - 0x72) < 4);

            if (OK) { self.eat_literal(result.push_back(byte), (index + 1), end, ((literal_field * 256) + (byte as Field))) }
            else    { (result, index, literal_field) }
        }
    }

    unconstrained
    fn parse(self, mut begin : &mut Field, end : Field, child_index : Field) -> JSON
    {
        let mut json = JSON::none();
        let mut prop = Property::none();

        let mut arrays : Field = 0;
        let mut index : Field = *begin;

        let mut byte_prev : u8 = 0;

        let child = !((index == 0) | (self[index] == crate::globals::QUOTATION_MARK));
        let mut OK = (index != end);
        let mut value = true;
        let mut done = false;
        let mut escaped = false;
        let mut has_key = false;
        let mut key_delimiter = false;
        let mut value_delimiter = false;
        let mut object = false;
        let mut array = false;
        let mut string = false;
        let mut number = false;
        let mut array_value = false;
        let mut minus = false;
        let mut digit_0 = false;
        let mut digit_1_9 = false;
        let mut e_E = false;
        let mut fraction = false;
        let mut fraction_digit = false;
        let mut e_minus = false;
        let mut e_plus = false;
        let mut e_digit = false;

        for _ in index..end
        {
            if (OK & (index != end))
            {
                let byte = self[index];
                index += 1;

                if (string)
                {
                    string  = (byte != QUOTATION_MARK);
                    string |= ((byte == QUOTATION_MARK) & (byte_prev == BACKSLASH) & !escaped);

                    let safe = !((byte == BACKSLASH) & escaped);
                    if      (safe & value)  { prop.value = prop.value.push_back(byte); done = !(string | array); }
                    else if (safe & string) { prop.key = prop.key.push_back(byte); has_key = true; }
                    else if (safe)          { OK = (object & has_key); }
                }
                else if ((byte == BEGIN_OBJECT) | (byte == BEGIN_ARRAY))
                {
                    OK = value;

                    if (byte == BEGIN_ARRAY)
                    {
                        OK &= (!array_value | (array_value & value_delimiter));

                        prop.value = prop.value.push_back(byte);
                        array_value = array;

                        arrays += 1;
                        array = true;
                    }
                    else if (object | array)
                    {
                        let mut index_local : Field = (index - 1); // will be overwritten to store child object's end index
                        let child_index : Field = (json.children.len() + child_index + 1);

                        let child_json = self.parse(&mut index_local, (end - 1), child_index);

                        OK = (child_json.doc.len() != 0);
                        if (OK)
                        {
                            prop.value = prop.value.push_back(BEGIN_OBJECT);
                            prop.value = prop.value.push_back(child_index as u8);
                            prop.value = prop.value.push_back(END_OBJECT);

                            json.children = json.children.push_back(child_json.doc);
                            for child in child_json.children { json.children = json.children.push_back(child); }

                            index = index_local;
                            array_value = true;
                        }
                    }
                    else
                    {
                        object = true;
                        value = false;
                        has_key = false;
                    }
                }
                else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                {
                    OK = (!value_delimiter | (value_delimiter & array_value));

                    if (byte == END_ARRAY)
                    {
                        prop.value = prop.value.push_back(byte);

                        arrays -= 1;
                        array = (arrays != 0);
                        done = (OK & !array);
                    }
                    else
                    {
                        object = false;
                        done = OK;

                        if (child)
                        {
                            *begin = index; // return child object's end index
                            index = end;
                        }
                    }
                }
                else if (byte == QUOTATION_MARK)
                {
                    OK = (array | !number);

                    string = true;
                    escaped = (byte_prev == BACKSLASH);

                    if (value)
                    {
                        OK &= (!array_value | (array_value & value_delimiter));

                        prop.value = prop.value.push_back(byte);
                        array_value = true;
                    }
                }
                else if (byte == KEY_DELIMITER)
                {
                    OK = (object & has_key & !key_delimiter);

                    key_delimiter = true;
                    value = true;

                    if (array) { prop.value = prop.value.push_back(byte); }
                }
                else if (byte == VALUE_DELIMITER)
                {
                    OK = ((object | array) & array_value);

                    array_value = false;
                    key_delimiter = false;
                    value_delimiter = true;
                    done = (OK & !array);

                    if (array)
                    {
                        prop.value = prop.value.push_back(byte);

                        number = false;
                        minus = false;
                        digit_0 = false;
                        digit_1_9 = false;
                        fraction = false;
                        fraction_digit = false;
                        e_E = false;
                        e_minus = false;
                        e_plus = false;
                        e_digit = false;
                    }
                }
                else if ((byte > SPACE) & (byte != BACKSLASH))
                {
                    prop.value = prop.value.push_back(byte);
                    array_value = true;

                    if ((byte - ZERO) < 10)
                    {
                        OK  = (value & (!digit_0 | (digit_0 & (fraction | e_E))));
                        OK &= (!object | has_key);

                        number = true;
                        digit_0 |= ((byte == ZERO) & !digit_1_9);
                        digit_1_9 |= !digit_0;
                        fraction_digit = fraction;
                        e_digit = e_E;
                    }
                    else if (byte == POINT)
                    {
                        OK = (number & !(fraction | e_E));
                        fraction = true;
                    }
                    else if ((byte == CHAR_e) | (byte == CHAR_E))
                    {
                        OK = (number & !e_E);
                        e_E = true;
                    }
                    else if (byte == MINUS)
                    {
                        OK = (!(minus | digit_0 | digit_1_9) | (e_E & !(e_minus | e_plus | e_digit)));

                        number = true;
                        minus = true;
                        e_minus = e_E;
                    }
                    else if (byte == PLUS)
                    {
                        OK = (e_E & !(e_plus | e_digit | e_minus));
                        e_plus = true;
                    }
                    else
                    {
                        let (result, index_, literal_field) = self.eat_literal(prop.value, index, end, (byte as Field));
                        index = index_;
                        prop.value = result;

                        OK = (!number & ((literal_field == FIELD_true) | (literal_field == FIELD_null) | (literal_field == FIELD_false)));
                    }
                }
                else
                {
                    OK = (byte != 0x00) | ((byte == 0x00) & (!(object | array) & (index == end)));
                    done = (number & !array);

                    // if (OK & !done) { index = self.eat_whitespace(index, end); }
                }

                if (done)
                {
                    OK = (!number | (digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit));

                    if (OK & value)
                    {
                        json.doc = json.store(prop);
                        prop = Property::none();
                    }

                    done = false;
                    value = false;
                    number = false;
                    minus = false;
                    digit_0 = false;
                    digit_1_9 = false;
                    fraction = false;
                    fraction_digit = false;
                    e_E = false;
                    e_minus = false;
                    e_plus = false;
                    e_digit = false;
                }

                byte_prev = byte;
            }
        }

        if (OK & !(object | array | string))
        {
            if (json.is_none())
            {
                OK = (!(number & value) | ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)));

                if (OK) { json.doc = [prop]; }
            }

            json
        }
        else
        {
            // dep::std::println(f"Unexpected character at position {index}");
            JSON::none()
        }
    }
}
