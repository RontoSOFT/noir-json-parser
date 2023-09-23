use dep::std::option::Option;

use dep::noir::globals::BYTE_NULL;
use dep::noir::convert::BytesU8;
use dep::noir::convert::StringBytes;
use dep::noir::new_parse::JSON;
use dep::noir::new_parse::KeyValuePair;

#[test]
fn convert_StringBytes_array_as_field()
{
    let bytes = StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, 0x36, 0x37, 0x35, 0x31, 0x30]);
    let result = bytes.asField();

    assert(result.is_some());
    assert(result.unwrap_unchecked() == 4293867510);
}

#[test]
fn convert_StringBytes_array_with_nulls_as_field()
{
    let bytes = StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
    let result = bytes.asField();

    assert(result.is_some());
    assert(result.unwrap_unchecked() == 42938);
}

#[test]
fn convert_StringBytes_array_value_overflows_as_field()
{
    // max (Field) + 1
    let bytes = StringBytes::new_valid([0x32,0x31,0x38,0x38,0x38,0x32,0x34,0x32,0x38,0x37,0x31,0x38,0x33,0x39,0x32,0x37,0x35,0x32,0x32,0x32,0x32,0x34,0x36,0x34,0x30,0x35,0x37,0x34,0x35,0x32,0x35,0x37,0x32,0x37,0x35,0x30,0x38,0x38,0x35,0x34,0x38,0x33,0x36,0x34,0x34,0x30,0x30,0x34,0x31,0x36,0x30,0x33,0x34,0x33,0x34,0x33,0x36,0x39,0x38,0x32,0x30,0x34,0x31,0x38,0x36,0x35,0x37,0x35,0x38,0x30,0x38,0x34,0x39,0x35,0x36,0x31,0x38]);
    let result = bytes.asField();

    assert(result.is_some());
    assert(result.unwrap_unchecked() == 1);
}

#[test]
fn convert_StringBytes_array_with_leading_null_as_field()
{
    let bytes = StringBytes::new_valid([BYTE_NULL, 0x34, 0x39, 0x36 ]);
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn convert_StringBytes_array_with_sparse_digits_as_field()
{
    let bytes = StringBytes::new_valid([0x34, 0x32, BYTE_NULL, 0x34, 0x39, 0x36, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_number_three_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_some());
    assert(result.unwrap_unchecked() == 30);
}

#[test]
fn property_string_three_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':'30','isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

//
// TODO: see https://github.com/noir-lang/noir/issues/2657
//
// #[test]
// fn property_string_escaped_three_zero_as_field()
// {
//     let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':\"30\",'isEmployed':true}").get("age").value;
//     let result = bytes.asField();

//     assert( result.valid && result.unwrap_unchecked() == 30 );
// }

#[test]
fn property_number_minus_three_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':-30,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_number_three_zero_point_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':30.0,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_string_thirty_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':'thirty','isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_number_three_colon_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3:0,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_number_three_space_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3 0,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_number_three_left_brace_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3{0,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_number_three_right_brace_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3}0,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

#[test]
fn property_number_three_quote_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3'0,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}

// #[test]
// fn property_number_three_escaped_quote_zero_as_field()
// {
//     let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3\"0,'isEmployed':true}").get("age").value;
//     let result = bytes.asField();

    // assert( !result.valid & (result.unwrap_unchecked() == 0);
// }

#[test]
fn property_number_three_comma_zero_as_field()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3,0,'isEmployed':true}").get("age").value;
    let result = bytes.asField();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == 0);
}
