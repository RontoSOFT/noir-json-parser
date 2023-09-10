use dep::std;

global DIGIT_NULL    : Field = 10;  // value represeting 'null' for digit byte arrays
global U32_CHAR_SIZE : Field = 10;  // string representing max(u32) is "4294967295", 10 characters long

global SINGLE_QUOTE : u8 = 0x27;    // single-quote         (')
global DOUBLE_QUOTE : u8 = 0x22;    // double-quote         (")
global COLON        : u8 = 0x3a;    // colon                (:)
global COMMA        : u8 = 0x2c;    // comma                (,)
global LEFT_BRACE   : u8 = 0x7b;    // left curly brace     ({)
global RIGHT_BRACE  : u8 = 0x7d;    // right curly brace    (})
global SPACE        : u8 = 0x20;    // space                ( )

struct U32Value
{
    valid: bool,
    value: u32
}

//
// Searches for property name in json, starting at index and returns a
//
// @returns Boolean indicating whether the value is found
//
unconstrained fn findProperty<JSON_SIZE, PROP_NAME_SIZE>(jsonBytes : [u8; JSON_SIZE], propNameBytes : [u8; PROP_NAME_SIZE], index : Field) -> bool
{
    let mut is_property_found = true;

    for i in 0..PROP_NAME_SIZE
    {
        is_property_found &= (jsonBytes[index + i] == propNameBytes[i]);
    }

    is_property_found
}

//
// Parses characters corresponding to property's value (expected to be of type u32), starting at index.
//
// @returns Byte array representing each digit
//
unconstrained fn getU32Bytes<JSON_SIZE>(jsonBytes : [u8; JSON_SIZE], index : Field) -> [Field; U32_CHAR_SIZE]
{
    let mut value_bytes : [Field; U32_CHAR_SIZE] = [DIGIT_NULL; U32_CHAR_SIZE];
    let mut value_bytes_index : Field = 0;

    let mut is_value_found = false;
    let mut is_value_malformed = false;
    let mut is_value_parsed = false;
    let mut is_skipped = false;

    let mut is_colon_found = false;
    let mut is_single_quoted = false;
    let mut is_double_quoted = false;

    for i in index..JSON_SIZE
    {
        if (!is_value_parsed)
        {
            if (!is_colon_found)
            {
                is_colon_found = (jsonBytes[i] == COLON);
            }

            if (is_colon_found)
            {
                is_single_quoted = (jsonBytes[i] == SINGLE_QUOTE);
                is_double_quoted = (jsonBytes[i] == DOUBLE_QUOTE);
            }

            is_skipped  = (jsonBytes[i] == SINGLE_QUOTE);
            is_skipped |= (jsonBytes[i] == DOUBLE_QUOTE);
            is_skipped |= (jsonBytes[i] == COLON);
            is_skipped |= (jsonBytes[i] == SPACE);

            is_value_malformed = (is_value_found & is_skipped & !is_single_quoted & !is_double_quoted);
            is_value_parsed = is_value_malformed;

            // std::println("...");
            // std::println(jsonBytes[i]);
            // std::println(is_skipped);
            // std::println(is_colon_found);
            // std::println(is_single_quoted);
            // std::println(is_value_malformed);

            if (!is_skipped & !is_value_malformed)
            {
                let value = (jsonBytes[i] - 0x30);      // convert ASCII to digit as integer

                is_value_malformed = (value > 0x09);    // expect digit values to be < 10
                is_value_parsed = is_value_malformed;

                if (!is_value_malformed)
                {
                    is_value_found = true;

                    value_bytes[value_bytes_index] = value as Field;
                    value_bytes_index += 1;

                    is_value_parsed  = (jsonBytes[i + 1] == COMMA);
                    is_value_parsed |= (jsonBytes[i + 1] == RIGHT_BRACE);
                    is_value_parsed |= (jsonBytes[i + 1] == SINGLE_QUOTE);
                    is_value_parsed |= (jsonBytes[i + 1] == DOUBLE_QUOTE);
                }
            }
        }
    }

    if (!is_value_parsed | is_value_malformed)
    {
        value_bytes = [DIGIT_NULL; U32_CHAR_SIZE];
    }

    value_bytes
}

//
// Converts a byte array to u32
//
// @returns An unsigned 32-bit integer representing the converted value
//
unconstrained fn bytesToU32 (value_bytes : [Field; U32_CHAR_SIZE]) -> u32
{
    let mut value : u32 = 0;
    let mut exponent : Field = 1;

    for i in 0..U32_CHAR_SIZE
    {
        let index = (U32_CHAR_SIZE - i - 1);    // walking property value bytes in reverse
        if (value_bytes[index] != 10)           // expect digit values to be < 10, a value of '10' meaning 'null'
        {
            value += (value_bytes[index] * exponent) as u32;
            exponent *= 10;
        }
    }

    value
}

//
// Gets a u32 value corresponding to property name from the json string
//
// @returns A U32Value instance representing the converted value and its validity
//
unconstrained fn getU32Value<JSON_SIZE, PROP_NAME_SIZE>(aJSONString : str<JSON_SIZE>, aPropName : str<PROP_NAME_SIZE>) -> U32Value
{
    let json_bytes = aJSONString.as_bytes();
    let prop_name_bytes = aPropName.as_bytes();

    // std::println("");
    // std::println(json_bytes);
    // std::println("");

    let mut value_bytes : [Field; U32_CHAR_SIZE] = [DIGIT_NULL; U32_CHAR_SIZE]; // '10' (or '0x0A') means 'null'
    let mut is_property_found = false;

    for i in 0..JSON_SIZE
    {
        if (!is_property_found)
        {
            is_property_found = findProperty(json_bytes, prop_name_bytes, i);

            if (is_property_found)
            {
                value_bytes = getU32Bytes(json_bytes, i + PROP_NAME_SIZE);
            }
        }
    }

    U32Value { valid: (is_property_found & (value_bytes[0] != DIGIT_NULL)), value: bytesToU32(value_bytes) }
}

fn main()
{
    // let json = "{'age':'30''}";
    // let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let json = "{'name':'John Doe','age':30,'isEmployed':true,'salary':50000.75,'address':'0xd8da6bf26964af9d7eed9e03e53415d37aa96045'}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);
    std::println(res);
}

#[test]
fn test_main()
{
    main();
}

#[test]
fn test_withCorrectInputs_getU32ValueReturnsExpectedValue()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == true);
    assert(res.value == 30);
}

#[test]
fn test_whenJSONPropertyValueIsSingleQuoted_getU32ValueReturnsValidValue()
{
    let json = "{'name':'John Doe','age':'30','isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == true);
    assert(res.value == 30);
}

// #[test]
// fn test_whenJSONPropertyValueIsDoubleQuoted_getU32ValueReturnsValidValue()
// {
//     let json = "{'name':'John Doe','age':\"30\",'isEmployed':true}";
//     let prop_name = "age";

//     let res = getU32Value(json, prop_name);

//     assert(res.valid == true);
//     assert(res.value == 30);
// }

#[test]
fn test_whenJSONIsEmpty_getU32ValueReturnsInvalidValue()
{
    let json = "{}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenInputPropertyIsEmpty_getU32ValueReturnsInvalidValue()
{
    let json = "{ age: 30 }";
    let prop_name = "";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenJSONPropertyIsMissing_getU32ValueReturnsInvalidValue()
{
    let json = "{'name':'John Doe','isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenJSONPropertyValueHasMinusSign_getU32ValueReturnsValidValue()
{
    let json = "{'name':'John Doe','age':-30,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

fn test_whenJSONPropertyValueTypeIsFloat_getU32ValueReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':30.0,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenJSONPropertyValueTypeIsString_getU32ValueReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':'thirty','isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenJSONPropertyValueIsMalformed1_getU32ValueReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':3:0,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenJSONPropertyValueIsMalformed2_getU32ValueReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':3 0,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenJSONPropertyValueIsMalformed4_getU32ValueReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':3{0,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == false);
    assert(res.value == 0);
}

#[test]
fn test_whenJSONIsMalformedButPropertyValueIsParsable1_getU32ValueReturnsValidValue()
{
    let json = "{'name':'John Doe','age':3'0,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == true);
    assert(res.value == 3);
}

// #[test]
// fn test_whenJSONIsMalformedButPropertyValueIsParsable2_getU32ValueReturnsValidValue()
// {
//     let json = "{'name':'John Doe','age':3\"0,'isEmployed':true}";
//     let prop_name = "age";

//     let res = getU32Value(json, prop_name);

//     assert(res.valid == true);
//     assert(res.value == 3);
// }

#[test]
fn test_whenJSONIsMalformedButPropertyValueIsParsable3_getU32ValueReturnsValidValue()
{
    let json = "{'name':'John Doe','age':3,0,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == true);
    assert(res.value == 3);
}

#[test]
fn test_whenJSONIsMalformedButPropertyValueIsParsable4_getU32ValueReturnsValidValue()
{
    let json = "{'name':'John Doe','age':3}0,'isEmployed':true}";
    let prop_name = "age";

    let res = getU32Value(json, prop_name);

    assert(res.valid == true);
    assert(res.value == 3);
}
