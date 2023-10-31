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
    fn store_value(mut self, prop : Property, index : u64) -> Self
    {
        // prop.print();

        let len : u64 = (self.doc[index].len() as u64);
        let mut found = false;
        for i in 0..len { if (!found) { if (prop.key.eq(self.doc[index][i].key)) { self.doc[index][i].value = prop.value; found = true; } } }

        if (!found) { self.doc[index] = self.doc[index].push_back(prop); }

        self
    }

    unconstrained
    pub fn parse<SIZE>(string : str<SIZE>) -> JSON
    {
    //     dep::std::println("");
    //     dep::std::println(string);
    //     dep::std::println("");

        let bytes = string.as_bytes();

        let mut json = JSON { doc: [[]] };
        let mut prop = Property::none();

        let mut objects : Field = 0;
        let mut arrays : Field = 0;
        let mut literal_field : Field = 0;

        let mut index : u64 = 0;
        let mut byte_prev : u8 = 0;

        let mut OK = true;
        let mut expect_key = false;
        let mut expect_value = true;
        let mut string = false;
        let mut number = false;
        let mut literal = false;
        let mut object = false;
        let mut array = false;
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
                        arrays += 1;
                        array = true;
                    }
                    else
                    {
                        objects += 1;
                        object = true;
                        expect_value = array;
                        expect_key = true;
                    }
                }
                else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                {
                    OK = (byte_prev != VALUE_DELIMITER);

                    if (array) { prop.value = prop.value.push_back(byte); }

                    let has_value = (prop.value.len() != 0);

                    if (byte == END_ARRAY)
                    {
                        let has_key = (prop.key.len() != 0);
                        OK &= (has_key | !object | (!has_key & object)); // == 1
                        OK &= array;

                        arrays -= 1;
                        array = (arrays != 0);
                    }
                    else
                    {
                        objects -= 1;
                        object = (objects != 0);
                    }

                    parse_complete = (OK & !array & (byte_prev != BACKSLASH) & has_value);
                }
                else if (byte == QUOTATION_MARK)
                {
                    OK = (array | !(number | literal));

                    string = true;

                    if (expect_value) { prop.value = prop.value.push_back(byte); }
                }
                else if (byte == KEY_DELIMITER)
                {
                    OK = ((object & array & expect_key) | !expect_value);

                    expect_key = false;
                    expect_value = (byte_prev != BACKSLASH);

                    if (array) { prop.value = prop.value.push_back(byte); }
                }
                else if (byte == VALUE_DELIMITER)
                {
                    OK = ((object | array) & array_value & expect_value);

                    array_value = false;
                    expect_key = object;

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
                    else { parse_complete = (OK & (byte_prev != BACKSLASH)); }
                }
                else if ((byte == TAB) | (byte == NEWLINE) | (byte == RETURN) | (byte == SPACE) | (byte == BACKSLASH)) { whitespace = (number | literal); }
                else
                {
                    if ((byte - ZERO) < 10)
                    {
                        OK  = (!digit_0 | (digit_0 & (fraction | e_E)));
                        OK &= (!object | (prop.key.len() != 0) | (object & array));

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
                        expect_value = false;
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

                        json = json.store_value(prop, index);
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
                else if (literal) { OK = ((literal_field == FIELD_true) | (literal_field == FIELD_null) | (literal_field == FIELD_false)); }

                if (OK) { json.doc[0] = [prop]; }
            }

            json
        }
        else { JSON { doc: [[]] } }
    }
}
