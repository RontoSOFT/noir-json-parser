use crate::JSON;
use crate::Property;

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

global FIELD_t     : Field = 0x74;
global FIELD_tr    : Field = 0x7472;
global FIELD_tru   : Field = 0x747275;
global FIELD_true  : Field = 0x74727565;
global FIELD_n     : Field = 0x6E;
global FIELD_nu    : Field = 0x6E75;
global FIELD_nul   : Field = 0x6E756C;
global FIELD_null  : Field = 0x6E756C6C;
global FIELD_f     : Field = 0x66;
global FIELD_fa    : Field = 0x6661;
global FIELD_fal   : Field = 0x66616C;
global FIELD_fals  : Field = 0x66616C73;
global FIELD_false : Field = 0x66616C7365;

impl JSON
{
    unconstrained
    pub fn parse<SIZE>(string : str<SIZE>) -> JSON
    {
    //     dep::std::println("");
    //     dep::std::println(string);
    //     dep::std::println("");
        JSON::parse_bytes(string.as_bytes(), 0, SIZE, -1)
    }

    unconstrained
    fn parse_bytes<SIZE>(bytes : [u8; SIZE], begin : Field, end : Field, offset : Field) -> JSON
    {
        let mut json = JSON::none();
        let mut prop = Property::none();

        let mut arrays : Field = 0;
        let mut literal_field : Field = 0;
        let mut index : Field = begin;

        let mut byte_prev : u8 = 0;

        let mut OK = true;
        let mut expect_value = true;
        let mut key_delimiter = false;
        let mut value_delimiter = false;
        let mut object = false;
        let mut array = false;
        let mut string = false;
        let mut number = false;
        let mut literal = false;
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
        let mut whitespace = false;
        let mut parse_complete = false;

        for _ in begin..end
        {
            if (OK & (index != end))
            {
                let byte = bytes[index];

                if (string)
                {
                    string = ((byte != QUOTATION_MARK) | (expect_value & (byte_prev == BACKSLASH)));

                    if (expect_value)
                    {
                        prop.value = prop.value.push_back(byte);
                        array_value = true;
                    }
                    else
                    {
                        if (string & (byte != BACKSLASH)) { prop.key = prop.key.push_back(byte); }
                        OK &= (prop.key.len() != 0);
                    }
                }
                else if ((byte == BEGIN_OBJECT) | (byte == BEGIN_ARRAY))
                {
                    if (byte == BEGIN_ARRAY)
                    {
                        prop.value = prop.value.push_back(byte);
                        array_value = array;

                        arrays += 1;
                        array = true;
                    }
                    else if (object | array)
                    {
                        prop.value = prop.value.push_back(byte);
                        array_value = true;

                        let mut child_objects : Field = 1;
                        let mut child_end_index : Field = 0;

                        for i in (index + 1)..end
                        {
                            if      (child_objects != 0)   { child_objects += (((bytes[i] == BEGIN_OBJECT) as Field) - ((bytes[i] == END_OBJECT) as Field)); }
                            else if (child_end_index == 0) { child_end_index = i; }
                        }

                        OK = (child_end_index != 0);
                        if (OK)
                        {
                            let len : Field = (json.children.len() + offset + 1);
                            let child_json = JSON::parse_bytes(bytes, index, child_end_index, len);

                            OK = (child_json.doc.len() != 0);
                            if (OK)
                            {
                                prop.value = prop.value.push_back(len as u8);
                                prop.value = prop.value.push_back(END_OBJECT);

                                json.children = json.children.push_back(child_json.doc);
                                for child in child_json.children { json.children = json.children.push_back(child); }

                                parse_complete = !array;
                                index = (child_end_index - 1);
                            }
                        }
                    }
                    else
                    {
                        object = true;
                        expect_value = false;
                    }
                }
                else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                {
                    let has_value = (prop.value.len() != 0);

                    OK = (!value_delimiter | (value_delimiter & array_value));

                    if (byte == END_ARRAY)
                    {
                        prop.value = prop.value.push_back(byte);

                        arrays -= 1;
                        array = (arrays != 0);
                    }
                    else
                    {
                        OK &= (object & ((prop.key.len() != 0) == has_value));
                        object = false;
                    }

                    parse_complete = (OK & !array & has_value);
                }
                else if (byte == QUOTATION_MARK)
                {
                    OK = (array | !(number | literal));

                    string = true;

                    if (expect_value) { prop.value = prop.value.push_back(byte); }
                }
                else if (byte == KEY_DELIMITER)
                {
                    OK = (object & !key_delimiter & (prop.key.len() != 0));

                    key_delimiter = true;
                    expect_value = (byte_prev != BACKSLASH);

                    if (array) { prop.value = prop.value.push_back(byte); }
                }
                else if (byte == VALUE_DELIMITER)
                {
                    OK = ((object | array) & array_value); // ((object & (prop.key.len() != 0) & !array) | array_value);

                    array_value = false;
                    key_delimiter = false;
                    value_delimiter = true;
                    parse_complete = (OK & !array & (prop.key.len() != 0));

                    if (array)
                    {
                        prop.value = prop.value.push_back(byte);

                        literal_field = 0;
                        number = false;
                        literal = false;
                        minus = false;
                        digit_0 = false;
                        digit_1_9 = false;
                        fraction = false;
                        fraction_digit = false;
                        e_E = false;
                        e_minus = false;
                        e_plus = false;
                        e_digit = false;
                        whitespace = false;
                    }
                }
                else if ((byte == TAB) | (byte == NEWLINE) | (byte == RETURN) | (byte == SPACE) | (byte == BACKSLASH)) { whitespace = (number | literal); }
                else if (byte == 0x00) { OK = !(object | array | (index == begin)); }
                else
                {
                    if ((byte - ZERO) < 10)
                    {
                        OK  = (!digit_0 | (digit_0 & (fraction | e_E)));
                        OK &= (!object | (prop.key.len() != 0));

                        number = true;
                        digit_0 |= ((byte == ZERO) & !digit_1_9);
                        digit_1_9 |= !digit_0;
                        fraction_digit = fraction;
                        e_digit = e_E;
                    }
                    else if (byte == POINT)
                    {
                        OK = (number & !fraction);
                        fraction = true;
                    }
                    else if (((byte == CHAR_e) | (byte == CHAR_E)) & !literal)
                    {
                        OK = (number & !e_E);
                        e_E = true;
                    }
                    else if (byte == MINUS)
                    {
                        OK = (!(minus | digit_0 | digit_1_9) | (e_E & !(e_minus | e_digit)));

                        number = true;
                        minus = true;
                        e_minus = e_E;
                    }
                    else if (byte == PLUS)
                    {
                        OK = (e_E & !e_plus & !e_digit);
                        e_plus = true;
                    }
                    else
                    {
                        literal_field *= 256;
                        literal_field += (byte as Field);

                        literal  = (literal_field == FIELD_t);
                        literal |= (literal_field == FIELD_tr);
                        literal |= (literal_field == FIELD_tru);
                        literal |= (literal_field == FIELD_true);
                        literal |= (literal_field == FIELD_n);
                        literal |= (literal_field == FIELD_nu);
                        literal |= (literal_field == FIELD_nul);
                        literal |= (literal_field == FIELD_null);
                        literal |= (literal_field == FIELD_f);
                        literal |= (literal_field == FIELD_fa);
                        literal |= (literal_field == FIELD_fal);
                        literal |= (literal_field == FIELD_fals);
                        literal |= (literal_field == FIELD_false);

                        OK = (!number & literal);
                    }

                    OK &= !whitespace;

                    prop.value = prop.value.push_back(byte);
                    array_value = true;
                }

                if (parse_complete)
                {
                    if      (number)  { OK = ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)); }
                    else if (literal) { OK = ((literal_field == FIELD_true) | (literal_field == FIELD_null) | (literal_field == FIELD_false)); }

                    if (OK)
                    {
                        literal_field = 0;
                        number = false;
                        literal = false;
                        minus = false;
                        digit_0 = false;
                        digit_1_9 = false;
                        fraction = false;
                        fraction_digit = false;
                        e_E = false;
                        e_minus = false;
                        e_plus = false;
                        e_digit = false;
                        whitespace = false;
                        parse_complete = false;
                        expect_value = false;

                        let len : u64 = (json.doc.len() as u64);
                        let mut found = false;
                        for i in 0..len { if (!found) { if (prop.key.eq(json.doc[i].key)) { json.doc[i].value = prop.value; found = true; } } }

                        if (!found) { json.doc = json.doc.push_back(prop); }

                        // prop.print();
                        prop = Property::none();
                    }
                }

                byte_prev = byte;
                index += 1;
            }
        }

        OK &= !(object | array);

        if (OK)
        {
            if (json.doc.len() == 0)
            {
                if      (number)  { OK = ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)); }
                else if (literal) { OK = ((literal_field == FIELD_true) | (literal_field == FIELD_null) | (literal_field == FIELD_false)); }

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
