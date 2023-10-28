use crate::JSON;
use crate::Property;

use crate::globals::BYTE_NULL;
use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::BEGIN_OBJECT;
use crate::globals::END_OBJECT;
use crate::globals::KEY_DELIMITER;
use crate::globals::VALUE_DELIMITER;
use crate::globals::QUOTATION_MARK;
use crate::globals::BACKSLASH;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;
use crate::globals::MINUS;
use crate::globals::ZERO;
use crate::globals::DECIMAL_POINT;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;
use crate::globals::PLUS;

impl JSON
{
    unconstrained
    fn literal_parsable(value : [u8]) -> bool
    {
        if      (value[0] == LITERALS_TRUE[0])  { value.eq_array(LITERALS_TRUE) }
        else if (value[0] == LITERALS_NULL[0])  { value.eq_array(LITERALS_NULL) }
        else if (value[0] == LITERALS_FALSE[0]) { value.eq_array(LITERALS_FALSE) }
        else                                    { false }
    }

    unconstrained
    fn store_value(mut self, prop : Property) -> Self
    {
        // prop.print();

        let len : u64 = (self.doc.len() as u64);
        let mut index : u64 = (0-1);
        for i in 0..len { if (index == -1) { if (prop.key.eq(self.doc[i].key)) { index = i; } } }

        if (index == -1) { self.doc = self.doc.push_back(prop); }
        else             { self.doc[index].value = prop.value; }

        self
    }

    unconstrained
    pub fn parse<SIZE>(string : str<SIZE>) -> JSON
    {
    //     dep::std::println("");
    //     dep::std::println(string);
    //     dep::std::println("");

        let bytes = string.as_bytes();

        let mut json = JSON { doc: [] };
        let mut prop = Property::none();

        let mut key_delimiters : Field = 0;
        let mut value_delimiters : Field = 0;
        let mut objects : Field = 0;
        let mut arrays : Field = 0;

        let mut byte_prev : u8 = 0;

        let mut OK = true;
        let mut expect_value = true;
        let mut string = false;
        let mut number = false;
        let mut literal = false;
        let mut whitespace = false;
        let mut array = false;
        let mut array_value = false;
        let mut parse_complete = false;
        let mut was_array = false;
        let mut minus = false;
        let mut digit_0 = false;
        let mut digit_1_9 = false;
        let mut e_E = false;
        let mut fraction = false;
        let mut fraction_digit = false;
        let mut e_minus = false;
        let mut e_plus = false;
        let mut e_digit = false;

        for byte in bytes
        {
            if (OK)
            {
                if (string)
                {
                    string = ((byte != QUOTATION_MARK) | (expect_value & (byte_prev == BACKSLASH)));

                    if      (expect_value)                 { prop.value = prop.value.push_back(byte); array_value = true; }
                    else if (string & (byte != BACKSLASH)) { prop.key = prop.key.push_back(byte);}
                }
                else if ((byte == BEGIN_OBJECT) | (byte == BEGIN_ARRAY))
                {
                    let begin_array = (byte == BEGIN_ARRAY);

                    if (array | begin_array)
                    {
                        prop.value = prop.value.push_back(byte);
                        array_value = array;
                    }

                    if (begin_array)
                    {
                        OK |= ((objects != 0) & expect_value);

                        arrays += 1;
                        array = true;
                        value_delimiters = 0;
                        expect_value = true;
                    }
                    else
                    {
                        OK = ((objects == 0) | was_array | array);

                        objects += 1;
                        expect_value = array;
                    }
                }
                else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                {
                    let end_array = (byte == END_ARRAY);

                    if (end_array)
                    {
                        let has_key = (prop.key.len() != 0);
                        OK  = (has_key | (objects == 0) | (!has_key & (objects == 1)));
                        OK &= (array & ((value_delimiters == 0) | array_value));

                        arrays -= 1;
                        array = (arrays != 0);
                        was_array = true;
                    }
                    else
                    {
                        OK = ((objects != 0) & (was_array | (prop.value.len() != 0)));

                        objects -= 1;
                        was_array = false;
                    }

                    if (array | end_array)
                    {
                        prop.value = prop.value.push_back(byte);
                        array_value = true;
                    }

                    parse_complete = (OK & !array & (byte_prev != BACKSLASH));
                }
                else if (byte == QUOTATION_MARK)
                {
                    OK = (!(number | literal) | array);

                    string = true;

                    if (expect_value)
                    {
                        prop.value = prop.value.push_back(byte);
                        array_value = true;
                    }
                }
                else if (byte == KEY_DELIMITER)
                {
                    OK = (!expect_value | (array & (objects != 0)));

                    key_delimiters += ((true ^ string) as Field);
                    expect_value = (byte_prev != BACKSLASH);

                    if (array)
                    {
                        prop.value = prop.value.push_back(byte);
                        array_value = true;
                    }
                }
                else if (byte == VALUE_DELIMITER)
                {
                    OK = (((objects != 0) | array) & array_value & expect_value);

                    value_delimiters += 1;
                    array_value = false;
                    parse_complete = (OK & !array & (byte_prev != BACKSLASH));

                    if (!parse_complete)
                    {
                        prop.value = prop.value.push_back(byte);

                        literal = false;
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
                        whitespace = false;
                    }
                }
                else if ((byte != 0x09) & (byte != 0x0A) & (byte != 0x0D) & (byte != 0x20) & (byte != BACKSLASH))
                {
                    if ((byte - ZERO) < 10)
                    {
                        OK  = (!digit_0 | (digit_0 & (fraction | e_E)));
                        OK &= ((objects == 0) | (prop.key.len() != 0) | (array & (objects != 0)));

                        number = true;
                        digit_0 |= ((byte == ZERO) & !digit_1_9);
                        digit_1_9 |= !digit_0;
                        fraction_digit = fraction;
                        e_digit = e_E;
                    }
                    else if (byte == DECIMAL_POINT)
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
                        literal = (!number & (((byte - 0x72) < 4) | (byte == 0x61) | (byte == 0x65) | (byte == 0x66) | (byte == 0x6C) | (byte == 0x6E)));
                        OK = (literal | array);
                    }

                    OK &= !whitespace;

                    prop.value = prop.value.push_back(byte);
                    array_value = true;
                }
                else { whitespace = (number | literal); }

                if (parse_complete)
                {
                    if (!was_array)
                    {
                        if      (number)  { OK = ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)); }
                        else if (literal) { OK = JSON::literal_parsable(prop.value); }
                    }

                    if (OK)
                    {
                        expect_value = false;
                        literal = false;
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
                        whitespace = false;
                        parse_complete = false;

                        json = json.store_value(prop);
                        prop = Property::none();
                    }
                }

                byte_prev = byte;

                // if (faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
            }
        }

        OK &= ((objects == 0) & (arrays == 0));

        if (OK)
        {
            if (prop.value.len() != 0)
            {
                if      (number)  { OK = ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)); }
                else if (literal) { OK = JSON::literal_parsable(prop.value); }

                if (OK) { json.doc = [prop]; }
            }

            json
        }
        else { JSON { doc: [] } }
    }
}
