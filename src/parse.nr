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
use crate::globals::WHITESPACES;
use crate::globals::LITERALS;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;
use crate::globals::MINUS;
use crate::globals::DIGITS_0_9;
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
        let mut OK = false;

        if      (value[0] == LITERALS_TRUE[0])  { OK = value.eq_array(LITERALS_TRUE); }
        else if (value[0] == LITERALS_NULL[0])  { OK = value.eq_array(LITERALS_NULL); }
        else if (value[0] == LITERALS_FALSE[0]) { OK = value.eq_array(LITERALS_FALSE); }

        OK
    }

    unconstrained
    fn store_value(mut self, prop : Property) -> Self
    {
        // prop.print();

        let len : u64 = (self.doc.len() as u64);
        let mut index = -1;
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

        let mut byte : u8 = 0;
        let mut byte_prev : u8 = 0;

        let mut OK = true;
        let mut string = false;
        let mut number = false;
        let mut literal = false;
        let mut whitespace = false;
        let mut was_array = false;
        let mut was_object = false;
        let mut has_value = false;
        let mut has_array_value = false;
        let mut expect_value = false;
        let mut minus = false;
        let mut digit_0 = false;
        let mut digit_1_9 = false;
        let mut e_E = false;
        let mut fraction = false;
        let mut fraction_digit = false;
        let mut e_minus = false;
        let mut e_plus = false;
        let mut e_digit = false;

        for i in 0..SIZE
        {
            if (OK)
            {
                byte = bytes[i];

                let equals_byte = |x| { byte == x };

                if (!WHITESPACES.any(equals_byte))
                {
                    if (string)
                    {
                        string = ((byte != QUOTATION_MARK) | (expect_value & (byte_prev == BACKSLASH)));

                        if      (expect_value)                 { prop.value = prop.value.push_back(byte); has_value = true; has_array_value = true; }
                        else if (string & (byte != BACKSLASH)) { prop.key = prop.key.push_back(byte); }
                    }
                    else
                    {
                        if      ((byte == BEGIN_OBJECT) | (byte == BEGIN_ARRAY))
                        {
                            let begin_array = (byte == BEGIN_ARRAY);

                            OK = !(number & literal & (arrays == 0));

                            if ((arrays != 0) | begin_array)
                            {
                                prop.value = prop.value.push_back(byte);
                                has_value = true;
                                has_array_value = (arrays != 0);
                            }

                            if (begin_array)
                            {
                                OK |= ((objects != 0) & expect_value);

                                arrays += 1;
                                value_delimiters = 0;
                                expect_value = true;
                            }
                            else
                            {
                                OK &= ((objects == 0) | was_object | was_array);
                                objects += 1;
                            }
                        }
                        else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                        {
                            let end_array = (byte == END_ARRAY);

                            OK = has_value;

                            if (end_array)
                            {
                                OK &= ((arrays != 0) & ((value_delimiters == 0) | has_array_value));
                                OK &= ((objects == 0) | (prop.key.len() != 0));

                                arrays -= 1;
                                was_array = true;
                                has_array_value = OK;
                                was_object = false;
                            }
                            else
                            {
                                OK |= was_array;
                                OK &= (objects != 0);

                                objects -= 1;
                                was_array = false;
                                was_object = (arrays == 0);
                            }

                            if ((arrays != 0) | end_array)
                            {
                                prop.value = prop.value.push_back(byte);
                                has_value = true;
                                has_array_value = (arrays != 0);
                            }

                            if (OK & has_value & (arrays == 0) & (byte_prev != BACKSLASH))
                            {
                                if      (number)  { OK = ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)); }
                                else if (literal) { OK = JSON::literal_parsable(prop.value); }
                                OK |= was_array;

                                if (OK)
                                {
                                    has_value = false;
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

                                    json = json.store_value(prop);
                                    prop = Property::none();
                                }
                            }
                        }
                        else if (byte == QUOTATION_MARK)
                        {
                            OK = !((number | literal) & (arrays == 0));
                            string = true;

                            if (expect_value)
                            {
                                prop.value = prop.value.push_back(byte);
                                has_value = true;
                                has_array_value = (arrays == 0);
                            }
                        }
                        else if (byte == KEY_DELIMITER)
                        {
                            OK = !expect_value;

                            key_delimiters += ((true ^ string) as Field);
                            expect_value = (byte_prev != BACKSLASH);
                        }
                        else if (byte == VALUE_DELIMITER)
                        {
                            OK = (expect_value & has_array_value);

                            value_delimiters += 1;
                            has_array_value = false;

                            if (OK & has_value & (arrays == 0) & (byte_prev != BACKSLASH))
                            {
                                if      (number)  { OK = ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)); }
                                else if (literal) { OK = JSON::literal_parsable(prop.value); }
                                OK |= was_array;

                                if (OK)
                                {
                                    has_value = false;
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

                                    json = json.store_value(prop);
                                    prop = Property::none();
                                }
                            }
                            else if (expect_value)
                            {
                                prop.value = prop.value.push_back(byte);
                                has_value = true;
                            }
                        }
                        else if (expect_value)
                        {
                            OK = !whitespace;

                            if (DIGITS_0_9.any(equals_byte))
                            {
                                OK &= (!digit_0 | (digit_0 & (fraction | e_E)));

                                digit_0 |= ((byte == ZERO) & !digit_1_9);
                                digit_1_9 |= !digit_0;
                                fraction_digit = fraction;
                                e_digit = e_E;
                            }
                            else if (byte == DECIMAL_POINT)
                            {
                                OK &= (digit_0 | digit_1_9);
                                fraction = true;
                            }
                            else if (((byte == CHAR_e) | (byte == CHAR_E)) & !literal)
                            {
                                OK &= !e_E;
                                e_E = true;
                            }
                            else if (byte == MINUS)
                            {
                                OK &= (!(minus | digit_0 | digit_1_9) | (e_E & !(e_minus | e_digit)));

                                minus = true;
                                e_minus = e_E;
                            }
                            else if (byte == PLUS)
                            {
                                OK &= (e_E & !e_plus & !e_digit);
                                e_plus = true;
                            }
                            else
                            {
                                literal = (LITERALS.any(equals_byte) & !(digit_0 | digit_1_9 | whitespace));
                                OK &= (literal | (arrays != 0));
                            }

                            number = !(literal | (byte_prev == BACKSLASH));
                            OK &= (number | literal);

                            prop.value = prop.value.push_back(byte);
                            has_value = true;
                            has_array_value = true;
                        }
                        else { OK = (byte == BACKSLASH); }
                    }
                }
                else if (string)
                {
                    if (expect_value) { prop.value = prop.value.push_back(byte); has_value = true; has_array_value = true; }
                    else              { prop.key = prop.key.push_back(byte); }
                }
                else { whitespace = has_value; }

                byte_prev = byte;

                // if (faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
            }
        }

        if (OK) { json } else { JSON { doc: [] } }
    }
}
