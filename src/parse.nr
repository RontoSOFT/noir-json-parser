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
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::ZERO;
use crate::globals::DECIMAL_POINT;
use crate::globals::DIGITS_1_9;
use crate::globals::eE;
use crate::globals::WHITESPACES;
use crate::globals::LITERALS;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;

use crate::utils::slice_eq_array;

impl JSON
{
    unconstrained
    fn value_parsed
    (
        prop : Property
    ,   is_number : bool
    ,   is_literal : bool
    ,   found_minus : bool
    ,   found_digit_0 : bool
    ,   found_digit_1_9 : bool
    ,   found_fraction : bool
    ,   found_fraction_digit : bool
    ,   found_e : bool
    ,   found_e_digit : bool
    ) -> bool
    {
        let mut is_faulty = false;

        if      (is_number)
        {
            is_faulty  = (found_e & !found_e_digit);
            is_faulty |= (found_fraction & !found_fraction_digit);
            is_faulty |= (found_minus & !(found_digit_0 | found_digit_1_9));
        }
        else if (is_literal)
        {
            is_faulty = true;
            let len = prop.value.len();
            let first = prop.value[0];
            if (len == 4)
            {
                if      (first == LITERALS_NULL[0]) { is_faulty = !slice_eq_array(prop.value, LITERALS_NULL); }
                else if (first == LITERALS_TRUE[0]) { is_faulty = !slice_eq_array(prop.value, LITERALS_TRUE); }
            }
            else if ((len == 5) & (first == LITERALS_FALSE[0])) { is_faulty = !slice_eq_array(prop.value, LITERALS_FALSE); }
        }

        !is_faulty
    }

    unconstrained
    fn store_value(mut self, prop : Property) -> Self
    {
        // prop.print();

        let mut found = false;
        let len = self.doc.len();
        for i in 0..len
        {
            let current = self.doc[i];
            if (!found)
            {
                let len = prop.key.len();
                found = (len == current.key.len());
                if (found)
                {
                    for j in 0..len { found &= (prop.key[j] == current.key[j]); }
                    if (found) { self.doc[i].value = prop.value; }
                }
            }
        }

        if (!found) { self.doc = self.doc.push_back(prop); }

        self
    }

    unconstrained pub fn parse<SIZE>(string : str<SIZE>) -> JSON
    {
        // dep::std::println("");
        // dep::std::println(string);
        // dep::std::println("");

        let mut is_faulty = false;
        let mut is_string = false;
        let mut is_number = false;
        let mut is_literal = false;
        let mut is_whitespace = false;
        let mut has_value = false;
        let mut expect_value = false;
        let mut found_minus = false;
        let mut found_digit_0 = false;
        let mut found_digit_1_9 = false;
        let mut found_fraction = false;
        let mut found_fraction_digit = false;
        let mut found_e = false;
        let mut found_e_minus = false;
        let mut found_e_plus = false;
        let mut found_e_digit = false;

        let mut count_key_delimiters = 0;
        let mut count_objects = 0;
        let mut count_arrays = 0;

        let mut json = JSON { doc: [] };
        let mut prop = Property::new();

        let bytes = string.as_bytes();

        let mut byte : u8 = 0;
        let mut byte_prev : u8 = 0;

        for i in 0..SIZE
        {
            if (!is_faulty)
            {
                byte = bytes[i];

                let equals_byte = |x| { byte == x };

                if (!WHITESPACES.any(equals_byte))
                {
                    if (!is_string)
                    {
                        if      (byte == BEGIN_OBJECT) | (byte == BEGIN_ARRAY)
                        {
                            is_faulty = (is_number | is_literal);

                            if (byte == BEGIN_OBJECT)
                            {
                                is_faulty |= (count_objects != 0);
                                count_objects += 1;
                            }
                            else
                            {
                                is_faulty |= ((count_objects != 0) & (!expect_value | (count_arrays != 0)));
                                is_faulty |= ((count_objects == 0) & (count_arrays != 0));
                                count_arrays += 1;
                            }
                        }
                        else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                        {
                            let count_pairs = json.doc.len();
                            is_faulty  = (!has_value & (count_pairs == count_key_delimiters));
                            is_faulty |= (has_value & ((count_pairs + 1) != count_key_delimiters));

                            if (byte == END_OBJECT) { count_objects -= 1; }
                            else                    { count_arrays -= 1; }

                            if (!is_faulty & has_value & (byte_prev != BACKSLASH))
                            {
                                if (JSON::value_parsed(prop, is_number, is_literal, found_minus, found_digit_0, found_digit_1_9, found_fraction, found_fraction_digit, found_e, found_e_digit))
                                {
                                    has_value = false;
                                    expect_value = false;
                                    is_whitespace = false;
                                    is_number = false;
                                    is_literal = false;
                                    found_minus = false;
                                    found_digit_0 = false;
                                    found_digit_1_9 = false;
                                    found_fraction = false;
                                    found_fraction_digit = false;
                                    found_e = false;
                                    found_e_digit = false;
                                    found_e_minus = false;
                                    found_e_plus = false;

                                    json = json.store_value(prop);
                                    prop = Property::new();
                                }
                            }
                        }
                        else if (byte == QUOTATION_MARK)
                        {
                            is_faulty = (is_number | is_literal);
                            is_string = true;
                        }
                        else if (byte == KEY_DELIMITER)
                        {
                            is_faulty = expect_value;
                            expect_value = (byte_prev != BACKSLASH);
                            count_key_delimiters += 1;
                        }
                        else if (byte == VALUE_DELIMITER)
                        {
                            is_faulty = !expect_value;
                            if (!is_faulty & has_value & (byte_prev != BACKSLASH))
                            {
                                if (JSON::value_parsed(prop, is_number, is_literal, found_minus, found_digit_0, found_digit_1_9, found_fraction, found_fraction_digit, found_e, found_e_digit))
                                {
                                    has_value = false;
                                    expect_value = false;
                                    is_whitespace = false;
                                    is_number = false;
                                    is_literal = false;
                                    found_minus = false;
                                    found_digit_0 = false;
                                    found_digit_1_9 = false;
                                    found_fraction = false;
                                    found_fraction_digit = false;
                                    found_e = false;
                                    found_e_digit = false;
                                    found_e_minus = false;
                                    found_e_plus = false;

                                    json = json.store_value(prop);
                                    prop = Property::new();
                                }
                            }
                        }
                        else if (expect_value)
                        {
                            is_faulty = is_whitespace;
                            if ((byte == ZERO) | DIGITS_1_9.any(equals_byte))
                            {
                                is_faulty |= (found_digit_0 & !(found_fraction | found_e));
                                found_digit_0 |= ((byte == ZERO) & !found_digit_1_9);
                                found_digit_1_9 |= !found_digit_0;
                                found_fraction_digit = found_fraction;
                                found_e_digit = found_e;
                            }
                            else if (byte == MINUS)
                            {
                                is_faulty |= (found_e_minus | found_e_digit | (!found_e & (found_minus | found_digit_0 | found_digit_1_9)));
                                found_minus = true;
                                found_e_minus = found_e;
                            }
                            else if (byte == DECIMAL_POINT)
                            {
                                is_faulty |= !(found_digit_0 | found_digit_1_9);
                                found_fraction = true;
                            }
                            else if (eE.any(equals_byte) & !is_literal)
                            {
                                is_faulty |= (found_e | (found_fraction & !found_fraction_digit));
                                found_e = true;
                            }
                            else if (byte == PLUS)
                            {
                                is_faulty |= (found_e_digit | found_e_plus | !found_e);
                                found_e_plus = true;
                            }
                            else
                            {
                                is_literal = (LITERALS.any(equals_byte) & !found_digit_0 & !found_digit_1_9 & !is_whitespace & (byte_prev != BACKSLASH));
                                is_faulty |= !is_literal;
                            }

                            is_number  = (!is_literal & (byte_prev != BACKSLASH));
                            is_faulty |= (!is_number & !is_literal);
                        }
                        else { is_faulty = (byte != BACKSLASH); }
                    }
                    else { is_string = ((byte != QUOTATION_MARK) | (expect_value & (byte_prev == BACKSLASH))); }

                    // store the byte in key or value slice
                    if      (!is_faulty & expect_value & (is_string | (byte != KEY_DELIMITER)))       { prop.value = prop.value.push_back(byte); has_value = true; }
                    else if (!is_faulty & is_string & (byte != QUOTATION_MARK) & (byte != BACKSLASH)) { prop.key = prop.key.push_back(byte); }
                }
                else if (is_string)
                {
                    if (expect_value) { prop.value = prop.value.push_back(byte); has_value = true; }
                    else              { prop.key = prop.key.push_back(byte); }
                }
                else { is_whitespace = has_value; }

                byte_prev = byte;

                // if (is_faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
            }
        }

        if (is_faulty) { JSON { doc: [] } } else { json }
    }
}
