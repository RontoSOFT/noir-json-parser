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

impl JSON
{
    unconstrained pub fn parse<SIZE>(string : str<SIZE>) -> JSON
    {
        dep::std::println("");
        dep::std::println(string);
        dep::std::println("");

        let mut is_faulty = &mut false;
        let mut is_string = &mut false;
        let mut is_number = &mut false;
        let mut is_literal = &mut false;
        let mut is_whitespace = &mut false;
        let mut is_array = &mut false;
        let mut was_array = &mut false;
        let mut was_object = &mut false;
        let mut has_value = &mut false;
        let mut expect_value = &mut false;
        let mut found_minus = &mut false;
        let mut found_digit_0 = &mut false;
        let mut found_digit_1_9 = &mut false;
        let mut found_e = &mut false;
        let mut found_e_minus = &mut false;
        let mut found_e_plus = &mut false;
        let mut found_e_digit = &mut false;
        let mut found_fraction = &mut false;
        let mut found_fraction_digit = &mut false;

        let mut count_pairs : &mut Field = &mut 0;
        let mut count_key_delimiters : Field = 0;
        let mut count_objects : Field = 0;
        let mut count_arrays : Field = 0;

        let mut json = &mut JSON { doc: [] };
        let mut prop = &mut Property::new();

        let mut byte : &mut u8 = &mut 0;
        let mut byte_prev : u8 = 0;

        let equals_byte = |x| { *byte == x };

        let push_key   = || { prop.key = prop.key.push_back(*byte); };
        let push_value = || { prop.value = prop.value.push_back(*byte); *has_value = true; };

        let value_parsed = ||
        {
            *is_faulty = !*has_value;

            if      (*is_number & !*was_array)
            {
                *is_faulty  = (*found_e & !*found_e_digit);
                *is_faulty |= (*found_fraction & !*found_fraction_digit);
                *is_faulty |= (*found_minus & !(*found_digit_0 | *found_digit_1_9));
            }
            else if (*is_literal & !*was_array)
            {
                let mut i : &mut Field = &mut -1;
                let equal_value = |a| { *i += 1; prop.value[*i] == a };

                *is_faulty = true;

                if (prop.value.len() == 4)
                {
                    if      (prop.value[0] == LITERALS_NULL[0]) { *is_faulty = !LITERALS_NULL.all(equal_value); }
                    else if (prop.value[0] == LITERALS_TRUE[0]) { *is_faulty = !LITERALS_TRUE.all(equal_value); }
                }
                else if ((prop.value.len() == 5) & (prop.value[0] == LITERALS_FALSE[0])) { *is_faulty = !LITERALS_FALSE.all(equal_value); }
            }

            if (!*is_faulty)
            {
                *is_whitespace = false;
                *has_value = false;
                *is_number = false;
                *is_literal = false;
                *expect_value = false;
                *found_minus = false;
                *found_digit_0 = false;
                *found_digit_1_9 = false;
                *found_e = false;
                *found_e_minus = false;
                *found_e_plus = false;
                *found_e_digit = false;
                *found_fraction_digit = false;
                *found_fraction = false;

                prop.print();

                let mut found = false;
                for i in 0..json.doc.len()
                {
                    let current = json.doc[i];

                    if (!found)
                    {
                        found = (prop.key.len() == current.key.len());
                        if (found)
                        {
                            for j in 0..prop.key.len() { found &= (prop.key[j] == current.key[j]); }
                            if (found) { json.doc[i].value = prop.value; }
                        }
                    }
                }

                if (!found)
                {
                    json.doc = json.doc.push_back(*prop);
                    *count_pairs += 1;
                }

                { *prop = Property::new(); }
            }
        };

        let bytes = string.as_bytes();
        for i in 0..SIZE
        {
            if (!*is_faulty)
            {
                *byte = bytes[i];

                if (!WHITESPACES.any(equals_byte))
                {
                    if (!*is_string)
                    {
                        if      ((*byte == BEGIN_OBJECT) | (*byte == BEGIN_ARRAY))
                        {
                            *is_faulty = (*is_number | *is_literal);// & (!*was_array & !*was_object);

                            if (*byte == BEGIN_OBJECT)
                            {
                                *is_faulty |= ((count_objects != 0) & !*was_object);
                                count_objects += 1;
                            }
                            else
                            {
                                *expect_value = true;
                                *is_faulty &= (!*was_array & (count_arrays == 0));
                                count_arrays += 1;
                                *is_array = true;
                                push_value();
                            }
                        }
                        else if ((*byte == END_OBJECT) | (*byte == END_ARRAY))
                        {
                            *is_faulty  = (!*has_value & (*count_pairs == count_key_delimiters));
                            *is_faulty |= (*has_value & ((*count_pairs + 1) != count_key_delimiters));

                            if (*byte == END_OBJECT)
                            {
                                *is_faulty &= !*was_array;
                                count_objects -= 1;
                                // *is_object = (count_objects != 0);
                                *was_array = false;
                                *was_object = true;
                            }
                            else
                            {
                                *is_faulty &= (count_arrays == 0);
                                count_arrays -= 1;
                                *is_array = (count_arrays != 0);
                                *was_array = true;
                                *was_object = false;

                                push_value();
                            }

                            if (*has_value & !*is_array & (byte_prev != BACKSLASH)) { value_parsed(); }
                        }
                        else if (*byte == QUOTATION_MARK)
                        {
                            *is_faulty = (*is_number | *is_literal) & !*is_array;
                            *is_string = true;

                            if (*expect_value) { push_value(); }
                        }
                        else if (*byte == KEY_DELIMITER)
                        {
                            *is_faulty = *expect_value;
                            *expect_value = (byte_prev != BACKSLASH);

                            if (!*is_string) { count_key_delimiters += 1; }
                        }
                        else if (*byte == VALUE_DELIMITER)
                        {
                            *is_faulty = !*expect_value;

                            if (*has_value & !*is_array & (byte_prev != BACKSLASH)) { value_parsed(); }
                            if (*expect_value) { push_value(); }
                        }
                        else if (*expect_value)
                        {
                            *is_faulty = *is_whitespace;

                            if ((*byte == ZERO) | DIGITS_1_9.any(equals_byte))
                            {
                                *is_faulty |= (*found_digit_0 & !(*found_fraction | *found_e));
                                *found_digit_0 |= ((*byte == ZERO) & !*found_digit_1_9);
                                *found_digit_1_9 |= !*found_digit_0;
                                *found_e_digit = *found_e;
                                *found_fraction_digit = *found_fraction;
                            }
                            else if (*byte == DECIMAL_POINT)
                            {
                                *is_faulty |= !(*found_digit_0 | *found_digit_1_9);
                                *found_fraction = true;
                            }
                            else if (eE.any(equals_byte) & !*is_literal)
                            {
                                *is_faulty |= (*found_e | (*found_fraction & !*found_fraction_digit));
                                *found_e = true;
                            }
                            else if (*byte == MINUS)
                            {
                                *is_faulty |= (*found_e_minus | *found_e_digit | (!*found_e & (*found_minus | *found_digit_0 | *found_digit_1_9)));
                                *found_minus = true;
                                *found_e_minus = *found_e;
                            }
                            else if (*byte == PLUS)
                            {
                                *is_faulty |= (*found_e_digit | *found_e_plus | !*found_e);
                                *found_e_plus = true;
                            }
                            else
                            {
                                *is_literal = (LITERALS.any(equals_byte) & !*found_digit_0 & !*found_digit_1_9 & !*is_whitespace);
                                *is_faulty |= (!*is_literal & !*is_array);
                            }

                            { *is_number  = (!*is_literal & (byte_prev != BACKSLASH)); }
                            { *is_faulty |= (!*is_number & !*is_literal); }

                            push_value();
                        }
                        else { *is_faulty = (*byte != BACKSLASH); }
                    }
                    else
                    {
                        *is_string = ((*byte != QUOTATION_MARK) | (*expect_value & (byte_prev == BACKSLASH)));

                        if      (*expect_value)                     { push_value(); }
                        else if (*is_string & (*byte != BACKSLASH)) { push_key(); }
                    }
                }
                else if (*is_string)
                {
                    if (*expect_value) { push_value(); }
                    else               { push_key(); }
                }
                else { *is_whitespace = *has_value; }

                byte_prev = *byte;

                if (*is_faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
            }
        }

        if (*is_faulty) { JSON { doc: [] } } else { *json }
    }
}
