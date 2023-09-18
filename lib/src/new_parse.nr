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

use crate::globals;
use crate::convert;

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

use dep::std::option::Option;
use dep::std::slice;

struct KeyValuePair<K, V>
{
    key : [u8; K],
    value : [u8; V],
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

impl<K, V> KeyValuePair<K, V>
{
    unconstrained fn new () -> Self
    {
        KeyValuePair { key: [0; K], value: [0; V] }
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

// TODO: Temp "solution" due to lambda/closure bug
struct ControlStruct
{
    is_faulty : bool,
    is_string : bool,
    is_number : bool,
    is_negative : bool,
    is_fraction : bool,
    is_literal : bool,
    is_escaped : bool,
    expect_value : bool,
    found_digit_1_9 : bool,
    found_digit_zero : bool,
    found_fraction_digit : bool,
    found_e : bool,
    found_e_digit : bool,
}

impl ControlStruct
{
    unconstrained fn new() -> Self
    {
        Self
        {
            is_faulty : false,
            is_string : false,
            is_number : false,
            is_negative : false,
            is_fraction : false,
            is_literal : false,
            is_escaped : false,
            expect_value : false,
            found_digit_1_9 : false,
            found_digit_zero : false,
            found_fraction_digit : false,
            found_e : false,
            found_e_digit : false,
        }
    }
}

unconstrained fn parse<SIZE_JSON>(bytes : [u8; SIZE_JSON]) -> [KeyValueSlice]
{
    let mut json : [KeyValueSlice] = [];
    let mut kvp = KeyValueSlice::new();

    let mut _ = ControlStruct::new();

    let on_value_done = |mut _ : &mut ControlStruct, mut json : &mut [KeyValueSlice], mut kvp : &mut KeyValueSlice|
    {
        _.is_faulty = (kvp.value.len() == 0);

        if (_.is_number)
        {
            _.is_faulty  = (_.found_e & !_.found_e_digit);
            _.is_faulty |= (_.is_fraction & !_.found_fraction_digit);

            _.is_number = false;
            _.is_negative = false;
            _.is_fraction = false;
            _.found_digit_1_9 = false;
            _.found_digit_zero = false;
            _.found_fraction_digit = false;
            _.found_e = false;
            _.found_e_digit = false;
        }
        else if (_.is_literal)
        {
            _.is_literal = false;

            if (kvp.value.len() == 4)
            {
                if      (kvp.value[0] == LITERALS_NULL[0])  { for j in 0..4 { _.is_faulty |= (kvp.value[j] != LITERALS_NULL[j]); } }
                else if (kvp.value[0] == LITERALS_TRUE[0])  { for j in 0..4 { _.is_faulty |= (kvp.value[j] != LITERALS_TRUE[j]); } }
                else { _.is_faulty = true; }
            }
            else if (kvp.value.len() == 5)
            {
                if (kvp.value[0] == LITERALS_FALSE[0]) { for j in 0..5 { _.is_faulty |= (kvp.value[j] != LITERALS_FALSE[j]); } }
                else { _.is_faulty = true; }
            }
            else { _.is_faulty = true; }
        }
        else if (_.is_string & _.expect_value) { kvp.value = (*kvp).value.push_back(QUOTATION_MARK); }

        if (!_.is_faulty & _.expect_value)
        {
            print_bytes("value", kvp.value);

            *json = (*json).push_back(*kvp);
            *kvp = KeyValueSlice::new();
        }

        _.expect_value = !_.is_string;
    };

    for i in 0..SIZE_JSON
    {
        if (!_.is_faulty)
        {
            let byte = bytes[i];
            let equals_byte = |x| { byte == x };

            if (!WHITESPACES.any(equals_byte))
            {
                if (byte == BEGIN_OBJECT)
                {
                    // TODO
                }
                else if (byte == BEGIN_ARRAY)
                {
                    // TODO
                }
                else if ((byte == END_OBJECT) | (byte == END_ARRAY)) { on_value_done(&mut _, &mut json, &mut kvp); }
                else if (byte == QUOTATION_MARK)
                {
                    if (_.is_string)
                    {
                        if (_.expect_value)
                        {
                            if (!_.is_escaped) { on_value_done(&mut _, &mut json, &mut kvp); }
                            _.is_string = _.is_escaped;
                        }
                        else
                        {
                            print_bytes("name", kvp.key);
                            _.is_string = false;
                        }
                    }
                    else { _.is_string = true; }

                    _.is_escaped = false;
                }
                else if (byte == KEY_DELIMITER) { _.expect_value = !_.is_string; } // string can contain ':'
                else if (_.expect_value & !_.is_string)
                {
                    _.is_literal = (LITERALS.any(equals_byte) & !_.found_digit_zero & !_.found_digit_1_9);

                    if (!_.is_literal)
                    {
                        dep::std::println("number");
                        _.is_number = true;

                        if (byte == MINUS)
                        {
                            _.is_faulty = (_.is_negative & !_.found_e) | (_.found_e & !_.found_e_digit);
                            _.is_negative = !_.is_faulty;

                            // if (_.is_negative) { _.is_faulty = (!_.found_e | (_.found_e & _.found_e_digit)); }
                            // else               { _.is_negative = true; }

                            // if (_.is_negative & !_.found_e) { _.is_faulty = true; }
                            // else                            { _.is_negative = true; }
                        }
                        else if (byte == PLUS)
                        {
                            _.is_faulty = (!_.found_e | (_.found_e & _.found_e_digit));
                        }
                        else if (byte == ZERO)
                        {
                            dep::std::println("0");
                            if (_.found_digit_zero) { _.is_faulty = true; }   // no leading zeros

                            _.found_digit_zero = true;

                            if (_.is_fraction) { _.found_fraction_digit = true; }
                            if (_.found_e)     { _.found_e_digit = true; }
                        }
                        else if (DIGITS_1_9.any(equals_byte))
                        {
                            dep::std::println("D");
                            _.is_faulty = _.found_digit_zero;

                            if      (_.is_fraction) { _.found_fraction_digit = true; }
                            else if (_.found_e)     { _.found_e_digit = true; }
                            else                    { _.found_digit_1_9 = true; }
                        }
                        else if (byte == DECIMAL_POINT) { _.is_fraction = true; }
                        else if (eE.any(equals_byte))
                        {
                            _.is_faulty = (_.is_fraction & !_.found_fraction_digit);
                            _.found_e = !_.is_faulty;
                        }
                        else { _.is_faulty = true; }
                    }
                }
                else if (byte == BACKSLASH)
                {
                    dep::std::println("escape");
                    _.is_escaped = true;
                }
                else { _.is_faulty = !_.is_string; }

                // store the value
                if (!_.is_faulty)
                {
                    if (_.is_string)
                    {
                        if      (_.expect_value)                                 { kvp.value = kvp.value.push_back(byte); }
                        else if ((byte != QUOTATION_MARK) & (byte != BACKSLASH)) { kvp.key = kvp.key.push_back(byte); }
                    }
                    else if (_.is_number | _.is_literal) { kvp.value = kvp.value.push_back(byte); }
                }
            }
            else if (_.expect_value)
            {
                if      (_.is_string)          { kvp.value = kvp.value.push_back(byte); }
                else if (kvp.value.len() != 0) { on_value_done(&mut _, &mut json, &mut kvp); }
            }

            // dep::std::println(_.is_faulty);
            if (_.is_faulty) { let pos = i + 1; dep::std::println(f"Unexpected character at position {pos}"); }
        }
    }

    json
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
    let mut kvp = KeyValuePair::new();

    let json = parse(self.bytes);

    let key_bytes = key.as_bytes();
    let mut found = false;
    for object in json
    {
        if (!found)
        {
            found = true;
            for j in 0..K { found &= (object.key[j] == key_bytes[j]); }

            if (found)
            {
                kvp.key = key_bytes;
                for j in 0..V { kvp.value[j] = object.value[j]; }
            }
        }
    }

    kvp
}

}
