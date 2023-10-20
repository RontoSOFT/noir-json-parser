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
    fn value_parsable
    (
        value : [u8]
    ,   was_array : bool
    ,   literal : bool
    ,   number : bool
    ,   minus : bool
    ,   digit_0 : bool
    ,   digit_1_9 : bool
    ,   fraction : bool
    ,   fraction_digit : bool
    ,   e_E : bool
    ,   e_digit : bool
    ) -> bool
    {
        let mut faulty = false;

        if (number & !was_array)
        {
            faulty  = (e_E & !e_digit);
            faulty |= (fraction & !fraction_digit);
            faulty |= (minus & !(digit_0 | digit_1_9));
        }
        else if (literal & !was_array)
        {
            faulty = !(value.eq_array(LITERALS_TRUE));

            if      (faulty & value.eq_array(LITERALS_NULL))  { faulty = false; }
            else if (faulty & value.eq_array(LITERALS_FALSE)) { faulty = false; }
        }

        !faulty
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

    unconstrained pub fn parse<SIZE>(string : str<SIZE>) -> JSON
    {
    //     dep::std::println("");
    //     dep::std::println(string);
    //     dep::std::println("");

        let bytes = string.as_bytes();

        let mut json = JSON { doc: [] };
        let mut prop = Property::none();

        let mut key_delimiters : Field = 0;
        let mut objects : Field = 0;
        let mut arrays : Field = 0;

        let mut byte : u8 = 0;
        let mut byte_prev : u8 = 0;

        let mut faulty = false;
        let mut string = false;
        let mut number = false;
        let mut literal = false;
        let mut whitespace = false;
        let mut array = false;
        let mut was_array = false;
        let mut was_object = false;
        let mut has_value = false;
        let mut expect_value = false;
        let mut minus = false;
        let mut digit_0 = false;
        let mut digit_1_9 = false;
        let mut e_E = false;
        let mut e_minus = false;
        let mut e_plus = false;
        let mut e_digit = false;
        let mut fraction = false;
        let mut fraction_digit = false;

        for i in 0..SIZE
        {
            if (!faulty)
            {
                byte = bytes[i];

                let equals_byte = |x| { byte == x };

                if (!WHITESPACES.any(equals_byte))
                {
                    if (!string)
                    {
                        if      ((byte == BEGIN_OBJECT) | (byte == BEGIN_ARRAY))
                        {
                            faulty = (number | literal);// & (!was_array & !was_object);

                            if (byte == BEGIN_OBJECT)
                            {
                                faulty |= ((objects != 0) & !was_object);
                                objects += 1;
                            }
                            else
                            {
                                expect_value = true;
                                faulty &= (!was_array & (arrays == 0));
                                arrays += 1;
                                array = true;

                                prop.value = prop.value.push_back(byte); has_value = true;
                            }
                        }
                        else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                        {
                            faulty = (!has_value & (json.doc.len() == key_delimiters));

                            if (byte == END_OBJECT)
                            {
                                faulty &= !was_array;
                                objects -= 1;
                                // object = (objects != 0);
                                was_array = false;
                                was_object = true;
                            }
                            else
                            {
                                faulty &= (arrays == 0);
                                arrays -= 1;
                                array = (arrays != 0);
                                was_array = true;
                                was_object = false;

                                prop.value = prop.value.push_back(byte); has_value = true;
                            }

                            if (!faulty & has_value & !array & (byte_prev != BACKSLASH))
                            {
                                if (JSON::value_parsable(prop.value, was_array, literal, number, minus, digit_0, digit_1_9, fraction, fraction_digit, e_E, e_digit))
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
                            faulty = ((number | literal) & !array);
                            string = true;

                            if (expect_value) { prop.value = prop.value.push_back(byte); has_value = true; }
                        }
                        else if (byte == KEY_DELIMITER)
                        {
                            faulty = expect_value;
                            expect_value = (byte_prev != BACKSLASH);

                            key_delimiters += ((true ^ string) as Field);
                        }
                        else if (byte == VALUE_DELIMITER)
                        {
                            faulty = !expect_value;

                            if (!faulty & has_value & !array & (byte_prev != BACKSLASH))
                            {
                                if (JSON::value_parsable(prop.value, was_array, literal, number, minus, digit_0, digit_1_9, fraction, fraction_digit, e_E, e_digit))
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

                            if (expect_value) { prop.value = prop.value.push_back(byte); has_value = true; }
                        }
                        else if (expect_value)
                        {
                            faulty = whitespace;

                            if (DIGITS_0_9.any(equals_byte))
                            {
                                faulty |= (digit_0 & !(fraction | e_E));
                                digit_0 |= ((byte == ZERO) & !digit_1_9);
                                digit_1_9 |= !digit_0;
                                e_digit = e_E;
                                fraction_digit = fraction;
                            }
                            else if (byte == DECIMAL_POINT)
                            {
                                faulty |= !(digit_0 | digit_1_9);
                                fraction = true;
                            }
                            else if (((byte == CHAR_e) | (byte == CHAR_E)) & !literal)
                            {
                                faulty |= (e_E | (fraction & !fraction_digit));
                                e_E = true;
                            }
                            else if (byte == MINUS)
                            {
                                faulty |= ((!e_E & (minus | digit_0 | digit_1_9)) | e_minus | e_digit);
                                minus = true;
                                e_minus = e_E;
                            }
                            else if (byte == PLUS)
                            {
                                faulty |= (!e_E | e_plus | e_digit);
                                e_plus = true;
                            }
                            else
                            {
                                literal = (LITERALS.any(equals_byte) & !(digit_0 | digit_1_9 | whitespace));
                                faulty |= !(literal | array);
                            }

                            number  = !(literal | (byte_prev == BACKSLASH));
                            faulty |= !(number | literal);

                            prop.value = prop.value.push_back(byte);
                            has_value = true;
                        }
                        else { faulty = (byte != BACKSLASH); }
                    }
                    else
                    {
                        string = ((byte != QUOTATION_MARK) | (expect_value & (byte_prev == BACKSLASH)));

                        if      (expect_value)                 { prop.value = prop.value.push_back(byte); has_value = true; }
                        else if (string & (byte != BACKSLASH)) { prop.key = prop.key.push_back(byte); }
                    }
                }
                else if (string)
                {
                    if (expect_value) { prop.value = prop.value.push_back(byte); has_value = true; }
                    else              { prop.key = prop.key.push_back(byte); }
                }
                else { whitespace = has_value; }

                byte_prev = byte;

                // if (faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
            }
        }

        if (faulty) { JSON { doc: [] } } else { json }
    }
}
