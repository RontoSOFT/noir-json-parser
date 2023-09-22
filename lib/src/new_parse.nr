// the six structural characters

    // BEGIN_ARRAY     =  0x5B; [ left square bracket
    // BEGIN_OBJECT    =  0x7B; { left curly bracket
    // END_ARRAY       =  0x5D; ] right square bracket
    // END_OBJECT      =  0x7D; } right curly bracket
    // separator_property  =  0x3A; : colon
    // separator_value =  0x2C; , comma

// WHITESPACE is allowed before or after any of the six structural characters

    // WHITESPACE =
    // [
    //     0x20, // Space
    //     0x09, // Horizontal tab
    //     0x0A, // Line feed or New line
    //     0x0D, // Carriage return
    // ];

// expected possible values

    // value = ( { object }, [ array ], "string", literal, number )

// ==============================
// we deduce that, while starting to parse, we will be accepting
//  -> any WHITESPACE
//  -> '{', or '[', or '"' (double quote)
// ==============================

// STRINGS

// The representation of strings is similar to conventions used in the C
// family of programming languages, using UTF-8 encoding by default
// It begins and ends with quotation marks, and since Noir allows ' (single quote) inside a string,
// when parsing, will consider " character instead of '

    // mark_quotation = "'";

// Any character can be BACKSLASHd using \ (reverse solidus)

    // BACKSLASH = 0x2F;

// literal names MUST be lowercase, and these are the only ones allowed:

    // false = [ 0x66, 0x61, 0x6c, 0x73, 0x65 ]; // false
    // null  = [ 0x6e, 0x75, 0x6c, 0x6c        ; // null
    // true  = [ 0x74, 0x72, 0x75, 0x65        ; // true


// NUMBERS

// A number contains an integer component that may be prefixed with an optional MINUS (-) sign,
// which may be followed by a fraction part and/or an exponent part

// Octal forms are not allowed
// Hex forms are not allowed
// Leading zeros are not allowed
// Numeric values that cannot be represented as sequences of digits (such as Infinity and NaN) are not permitted.

// A fraction part is a decimal point followed by one or more digits
// An exponent part begins with the letter 'E' or 'e', which may be followed by '+' or '-' sign.
// The exponent is followed by at least one digit

// Template using regex:
// number = [MINUS]? int [fraction]?[exp]?
// int    = zero{1}|DIGIT_1-9+[zero|DIGIT_1-9]+ -> [0] or [integral number] (no leading 0s)
// frac   = decimal-point[zero|DIGIT1-9]+       -> .[zero and any digit]
// exp    = [eE]{1}[MINUS|PLUS]?int             -> (e or E)[+ or -][0 or integral number]

// PLUS  = 0x2B; // +
// MINUS = 0x2D; // -
// zero  = 0x30; // 0
// DIGITS_1_9 = [ 0x31, 0x31, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39 ];
// DECIMAL_POINT = 0x2E; // .
// e = [ 0x65, 0x45 ]; // e or E

use dep::std::slice;

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

use crate::convert::StringBytes;

struct KeyValuePair<K, V>
{
    key : [u8; K],
    value : StringBytes<V>,
}

struct KeyValueSlice
{
    key : [u8],
    value : [u8],
}

struct JSON<N>
{
    bytes : [u8; N]
}

// TODO: indexing (operator[]) for references of slices is broken
struct WrappedJSON
{
    _ : [KeyValueSlice]
}

impl<K, V> KeyValuePair<K, V>
{
    unconstrained fn new () -> Self
    {
        KeyValuePair { key: [0; K], value: StringBytes { valid: false, bytes: [0; V] } }
    }
}

impl KeyValueSlice
{
    unconstrained fn new () -> Self
    {
        KeyValueSlice { key: [], value: [] }
    }
}

unconstrained fn print_bytes<N>(label : str<N>, value_bytes : [u8])
{
    dep::std::println(label);
    dep::std::println("{");
    for j in 0..value_bytes.len() { dep::std::println(value_bytes[j]); }
    dep::std::println("}");
}

unconstrained fn parse<SIZE_JSON>(bytes : [u8; SIZE_JSON]) -> [KeyValueSlice]
{
    let mut is_faulty = &mut false;
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

    let mut json = &mut WrappedJSON { _ : [] };
    let mut kvp = &mut KeyValueSlice::new();

    let new_key_value_pair = &mut ||
    {
        *is_faulty = false;
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

        let mut found = false;
        for i in 0..json._.len()
        {
            let kvp_prev = json._[i];
            if (!found)
            {
                found = (kvp.key.len() == kvp_prev.key.len());
                if (found) { for j in 0..kvp.key.len() { found &= (kvp.key[j] == kvp_prev.key[j]); } }
                if (found) { json._[i].value = kvp.value; }
            }
        }

        print_bytes("value", kvp.value);
        if (!found) { json._ = json._.push_back(*kvp); }
        { *kvp = KeyValueSlice::new(); }
    };

    let value_parsed = ||
    {
        *is_faulty = (kvp.value.len() == 0);

        if      (*is_number) { *is_faulty = ((*found_e & !*found_e_digit) | (*found_fraction & !*found_fraction_digit)); }
        else if (*is_literal)
        {
            let mut i : &mut Field = &mut -1;
            let equal_value = |a| { *i += 1; kvp.value[*i] == a };

            *is_faulty = true;

            if (kvp.value.len() == 4)
            {
                if      (kvp.value[0] == LITERALS_NULL[0]) { *is_faulty = !LITERALS_NULL.all(equal_value); }
                else if (kvp.value[0] == LITERALS_TRUE[0]) { *is_faulty = !LITERALS_TRUE.all(equal_value); }
            }
            else if ((kvp.value.len() == 5) & (kvp.value[0] == LITERALS_FALSE[0])) { *is_faulty = !LITERALS_FALSE.all(equal_value); }
        }

        if (!*is_faulty) { (*new_key_value_pair)(); }
    };

    let mut i_minus_1 : Field = -1;
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
                if (*byte == BEGIN_OBJECT)
                {
                    // TODO
                }
                else if (*byte == BEGIN_ARRAY)
                {
                    // TODO
                }
                else if ((*byte == END_OBJECT) | (*byte == END_ARRAY) | (*byte == VALUE_DELIMITER))
                {
                    if (!*is_string & (byte_prev != BACKSLASH)) { value_parsed(); }
                }
                else if (*byte == QUOTATION_MARK)
                {
                    if (*is_string)
                    {
                        if      (!*expect_value) { print_bytes("name", kvp.key); }
                        else if (byte_prev != BACKSLASH)
                        {
                            kvp.value = (*kvp).value.push_back(QUOTATION_MARK);
                            (*new_key_value_pair)();
                        }

                        { *is_string = (*expect_value & (byte_prev == BACKSLASH)); }
                    }
                    else { *is_string = true; }
                }
                else if (*byte == KEY_DELIMITER) { *expect_value = !*is_string; } // string can contain ':'
                else if (*expect_value & !*is_string)
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
                        *is_faulty = *found_e_plus | (!*found_e | (*found_e & *found_e_digit));
                        *found_e_plus = true;
                    }
                    else if ((*byte == ZERO) | DIGITS_1_9.any(equals_byte))
                    {
                        *is_faulty = (*found_digit_0 & !(*found_fraction | *found_e));
                        *found_digit_0 = ((*byte == ZERO) | *found_digit_0);
                        *found_digit_1_9 = (!*found_digit_0 | *found_digit_1_9);
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
                else if (*byte != BACKSLASH) { *is_faulty = !*is_string; }

                if (!*is_faulty) // store the byte in key or value slice
                {
                    if      (*expect_value & (*is_string | (*byte != KEY_DELIMITER)))       { kvp.value = kvp.value.push_back(*byte); }
                    else if (*is_string & (*byte != QUOTATION_MARK) & (*byte != BACKSLASH)) { kvp.key = kvp.key.push_back(*byte); }
                }
            }
            else if (*is_string)           { kvp.value = kvp.value.push_back(*byte); }
            else if (kvp.value.len() != 0) { value_parsed(); }

            i_minus_1 += 1;
            byte_prev = bytes[i_minus_1];

            if (*is_faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
        }
    }

    { json._ }
}

impl<SIZE_JSON> JSON<SIZE_JSON>
{

unconstrained fn new(string : str<SIZE_JSON>) -> Self
{
    dep::std::println("");
    dep::std::println(string);
    dep::std::println("");

    JSON { bytes: string.as_bytes() }
}

unconstrained fn get<K, V>(self, key : str<K>) -> KeyValuePair<K, V>
{
    let json = parse(self.bytes);

    let mut kvp = KeyValuePair::new();
    let key_bytes = key.as_bytes();
    for object in json
    {
        if (!kvp.value.valid)
        {
            kvp.value.valid = (object.key.len() == K);
            if (kvp.value.valid) { for i in 0..K { kvp.value.valid &= (key_bytes[i] == object.key[i]); } }
            if (kvp.value.valid)
            {
                kvp.key = key_bytes;
                for i in 0..V { kvp.value.bytes[i] = object.value[i]; }
            }
        }
    }

    kvp
}

}
