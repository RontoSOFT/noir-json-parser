// Six structural characters

    // BEGIN_ARRAY     =  0x5B -> [ (left square bracket)
    // BEGIN_OBJECT    =  0x7B -> { (left curly bracket)
    // END_ARRAY       =  0x5D -> ] (right square bracket)
    // END_OBJECT      =  0x7D -> } (right curly bracket)
    // KEY_DELIMITER   =  0x3A -> : (colon)
    // VALuE_DELIMITER =  0x2C -> , (comma)

// Whitespace is allowed before or after any of the six structural characters

    // WHITESPACE =
    // [
    //     0x20, -> Space
    //     0x09, -> Horizontal tab
    //     0x0A, -> Line feed or New line
    //     0x0D, -> Carriage return
    // ]

// Expected possible values ==> ( "string", literal, number, { object }, [ array ] )

// 1. STRINGS

// The representation of strings is similar to conventions used in the C
// family of programming languages, using UTF-8 encoding by default
// It begins and ends with quotation marks, and since Noir allows ' (single quote) inside a string,
// when parsing, will consider " character instead of '

    // mark_quotation = "'" // TODO: change to " when support is updated

// Any character can be escaped using \ (backslash or reverse solidus)

    // BACKSLASH = 0x2F

// 2. LITERALS

// MUST be lowercase, and these are the only ones allowed:

    // false = [ 0x66, 0x61, 0x6c, 0x73, 0x65 ]
    // null  = [ 0x6e, 0x75, 0x6c, 0x6c
    // true  = [ 0x74, 0x72, 0x75, 0x65

// 3. NUMBERS

// A number contains an integer component that may be prefixed with an optional MINUS (-) sign,
// which may be followed by a fraction part and/or an exponent part

// Octal forms are not allowed
// Hex forms are not allowed
// Leading zeros are not allowed
// Numeric values that cannot be represented as sequences of digits (such as Infinity and NaN) are not permitted

// A fraction part is a decimal point followed by one or more digits
// An exponent part begins with the letter 'E' or 'e', which may be followed by '+' or '-' sign
// The exponent is followed by at least one digit

// Template using regex:
// number = [MINUS]? int [fraction]?[exp]?
// int    = zero{1}|DIGIT_1-9+[zero|DIGIT_1-9]+ -> [0] or [integral number] (no leading 0s)
// frac   = decimal-point[zero|DIGIT1-9]+       -> .[zero and any digit]
// exp    = [eE]{1}[MINUS|PLUS]?int             -> (e or E)[+ or -][0 or integral number]

// PLUS  = 0x2B
// MINUS = 0x2D
// ZERO  = 0x30
// DIGITS_1_9 = [ 0x31, 0x31, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39 ]
// DECIMAL_POINT = 0x2E
// eE = [ 0x65, 0x45 ]

use dep::std::slice;

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

use crate::utils::print_bytes;

struct Property<KEY_SIZE, VALUE_SIZE>
{
    key : [u8; KEY_SIZE],
    value : [u8; VALUE_SIZE],
}

struct UnconstrainedProperty
{
    key : [u8],
    value : [u8],
}

struct JSON<SIZE>
{
    bytes : [u8; SIZE]
}

impl<KEY_SIZE, VALUE_SIZE> Property<KEY_SIZE, VALUE_SIZE>
{
    unconstrained fn new() -> Self
    {
        Property { key: [BYTE_NULL; KEY_SIZE], value: [BYTE_NULL; VALUE_SIZE] }
    }
}

impl UnconstrainedProperty
{
    unconstrained fn new() -> Self
    {
        UnconstrainedProperty { key: [], value: [] }
    }

    unconstrained fn print(&mut self)
    {
        print_bytes("key", self.key);
        print_bytes("value", self.value);
    }
}

impl<SIZE_JSON> JSON<SIZE_JSON>
{
    unconstrained pub fn new(string : str<SIZE_JSON>) -> Self
    {
        dep::std::println("");
        dep::std::println(string);
        dep::std::println("");

        JSON { bytes: string.as_bytes() }
    }

    unconstrained pub fn get<KEY_SIZE, VALUE_SIZE>(self, key : str<KEY_SIZE>) -> Property<KEY_SIZE, VALUE_SIZE>
    {
        let json = parse(self.bytes);

        let mut prop = Property::new();
        let key_bytes = key.as_bytes();
        let mut found = false;
        for object in json
        {
            if (!found)
            {
                found = (object.key.len() == KEY_SIZE);
                if (found) { for i in 0..KEY_SIZE { found &= (key_bytes[i] == object.key[i]); } }
                if (found)
                {
                    prop.key = key_bytes;

                    let index = if ((VALUE_SIZE as u64) <= (object.value.len() as u64)) { VALUE_SIZE } else { object.value.len() };
                    for i in 0..index { prop.value[i] = object.value[i]; }
                }
            }
        }

        prop
    }
}

unconstrained pub fn parse<SIZE_JSON>(bytes : [u8; SIZE_JSON]) -> [ UnconstrainedProperty ]
{
    let mut is_faulty = &mut false;
    let mut has_value = &mut false;
    let mut is_string = &mut false;
    let mut is_number = &mut false;
    let mut is_literal = &mut false;
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

    let mut count_pairs = &mut 0;
    let mut count_key_delimiters = 0;
    let mut count_objects = 0;
    let mut count_arrays = 0;

    let mut json : &mut [ UnconstrainedProperty ] = &mut [];
    let mut prop = &mut UnconstrainedProperty::new();

    let value_parsed = ||
    {
        *is_faulty = !*has_value;

        if      (*is_number)
        {
            *is_faulty  = (*found_e & !*found_e_digit);
            *is_faulty |= (*found_fraction & !*found_fraction_digit);
            *is_faulty |= (*found_minus & !(*found_digit_0 | *found_digit_1_9));
        }
        else if (*is_literal)
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

            *count_pairs += 1;

            prop.print();

            let mut found = false;
            // TODO: indexing (operator[]) for references of slices is broken, make a copy
            let mut json_ : [ UnconstrainedProperty ] = *json;
            for i in 0..json_.len()
            {
                let current = json_[i];

                if (!found)
                {
                    found = (prop.key.len() == current.key.len());
                    if (found)
                    {
                        for j in 0..prop.key.len() { found &= (prop.key[j] == current.key[j]); }
                        if (found) { json_[i].value = prop.value; }
                    }
                }
            }

            if (!found) { json_ = json_.push_back(*prop); }
            { *json = json_; }

            { *prop = UnconstrainedProperty::new(); }
        }
    };

    let mut byte : &mut u8 = &mut 0;
    let mut byte_prev : u8 = 0;

    let equals_byte = |x| { *byte == x };

    for i in 0..SIZE_JSON
    {
        if (!*is_faulty)
        {
            *byte = bytes[i];

            if (!WHITESPACES.any(equals_byte))
            {
                if (!*is_string)
                {
                    if      (*byte == BEGIN_OBJECT) | (*byte == BEGIN_ARRAY)
                    {
                        *is_faulty = (*is_number | *is_literal);

                        if (*byte == BEGIN_OBJECT)
                        {
                            *is_faulty |= (count_objects != 0);
                            count_objects += 1;
                        }
                        else
                        {
                            *is_faulty |= (count_arrays != 0) | !*expect_value;
                            count_arrays += 1;
                        }
                    }
                    else if ((*byte == END_OBJECT) | (*byte == END_ARRAY))
                    {
                        *is_faulty  = ((*count_pairs == count_key_delimiters) & !*has_value);
                        *is_faulty |= (((*count_pairs + 1) != count_key_delimiters) & *has_value);

                        if (!*is_faulty & (byte_prev != BACKSLASH) & *has_value) { value_parsed(); }

                        if (*byte == END_OBJECT)
                        {
                            *is_faulty |= (count_objects != 1);
                            count_objects -= 1;
                        }
                        else
                        {
                            *is_faulty |= (count_arrays != 1);
                            count_arrays -= 1;
                        }
                    }
                    else if (*byte == QUOTATION_MARK)
                    {
                        *is_faulty = (*is_number | *is_literal);
                        *is_string = true;
                    }
                    else if (*byte == KEY_DELIMITER)
                    {
                        *is_faulty = *expect_value;
                        *expect_value = true;
                        count_key_delimiters += 1;
                    }
                    else if (*byte == VALUE_DELIMITER)
                    {
                        *is_faulty = !(*expect_value & *is_string);
                        if (*has_value & (byte_prev != BACKSLASH)) { value_parsed(); }
                    }
                    else if (*expect_value)
                    {
                        *is_faulty = true;

                        if (*byte == MINUS)
                        {
                            *is_faulty = (*found_e_minus | *found_e_digit | (!*found_e & (*found_minus | *found_digit_0 | *found_digit_1_9)));
                            *found_minus = true;
                            *found_e_minus = *found_e;
                        }
                        else if (*byte == PLUS)
                        {
                            *is_faulty = (*found_e_plus | (!*found_e | (*found_e & *found_e_digit)));
                            *found_e_plus = true;
                        }
                        else if ((*byte == ZERO) | DIGITS_1_9.any(equals_byte))
                        {
                            *is_faulty = (*found_digit_0 & !(*found_fraction | *found_e));
                            *found_digit_0 |= ((*byte == ZERO) & !*found_digit_1_9);
                            *found_digit_1_9 |= !*found_digit_0;
                            *found_e_digit = *found_e;
                            *found_fraction_digit = *found_fraction;
                        }
                        else if (*byte == DECIMAL_POINT)
                        {
                            *is_faulty = !(*found_digit_0 | *found_digit_1_9);
                            *found_fraction = true;
                        }
                        else if (eE.any(equals_byte) & !*is_literal)
                        {
                            *is_faulty = (*found_e | (*found_fraction & !*found_fraction_digit));
                            *found_e = true;
                        }
                        else { *is_literal = (LITERALS.any(equals_byte) & !*found_digit_0 & !*found_digit_1_9); }

                        { *is_number = !(*is_faulty | *is_literal); }
                        { *is_faulty = !(*is_number | *is_literal); }
                    }
                    else { *is_faulty = (*byte != BACKSLASH); }
                }
                else { *is_string = ((*byte != QUOTATION_MARK) | (*expect_value & (byte_prev == BACKSLASH))); }

                // store the byte in key or value slice
                if      (!*is_faulty & *expect_value & (*is_string | (*byte != KEY_DELIMITER)))       { prop.value = prop.value.push_back(*byte); *has_value = true; }
                else if (!*is_faulty & *is_string & (*byte != QUOTATION_MARK) & (*byte != BACKSLASH)) { prop.key = prop.key.push_back(*byte); }
            }
            else if (*is_string)
            {
                if (*expect_value) { prop.value = prop.value.push_back(*byte); *has_value = true; }
                else               { prop.key = prop.key.push_back(*byte); }
            }
            else if (*has_value)
            {
                count_key_delimiters += 1;  // prevent END_OBJECT/ARRAY marker from detecting error (false negative)
                value_parsed();
            }

            byte_prev = *byte;

            if (*is_faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
        }
    }

    if (*is_faulty) { [] } else { *json }
}
