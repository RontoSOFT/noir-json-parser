use dep::noir::globals;
use dep::noir::convert;
use dep::noir::convert::BytesU8;
use dep::noir::parse::JSON;

#[test]
fn ValidInput_StringBytes_ReturnsExpectedValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, 0x36, 0x37, 0x35, 0x31, 0x30]);
    let result = bytes.asField();

    assert( result.valid & (result.value == 4293867510) );
}

#[test]
fn ValidInput_StringBytesWithNulls_ReturnsExpectedValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL]);
    let result = bytes.asField();

    assert( result.valid & (result.value == 42938) );
}

#[test]
fn ValidInput_StringBytesLargerThanMaxOfFieldType_ReturnsOverflowedValue()
{
    let bytes = convert::StringBytes::new_valid([0x32,0x31,0x38,0x38,0x38,0x32,0x34,0x32,0x38,0x37,0x31,0x38,0x33,0x39,0x32,0x37,0x35,0x32,0x32,0x32,0x32,0x34,0x36,0x34,0x30,0x35,0x37,0x34,0x35,0x32,0x35,0x37,0x32,0x37,0x35,0x30,0x38,0x38,0x35,0x34,0x38,0x33,0x36,0x34,0x34,0x30,0x30,0x34,0x31,0x36,0x30,0x33,0x34,0x33,0x34,0x33,0x36,0x39,0x38,0x32,0x30,0x34,0x31,0x38,0x36,0x35,0x37,0x35,0x38,0x30,0x38,0x34,0x39,0x35,0x36,0x31,0x38]);
    let result = bytes.asField();

    assert( result.valid & (result.value == 1) );
}

#[test]
fn StringBytesIsFlawed_StartingNullElement_ReturnsInvalidValue()
{
    let bytes = convert::StringBytes::new_valid([globals::BYTE_NULL, 0x34, 0x39, 0x36 ]);
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn StringBytesIsFlawed_NullBetweenNonNullElements_ReturnsInvalidValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, globals::BYTE_NULL, 0x34, 0x39, 0x36, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL]);
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn ValidInput_JSONAndPropertyName_ReturnsExpectedValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( result.valid & (result.value == 30) );
}

#[test]
fn JSONPropertyValueIsSingleQuoted_ReturnsValidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':'30','isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( result.valid & (result.value == 30) );
}

//
// TODO: see https://github.com/noir-lang/noir/issues/2657
//
// #[test]
// fn JSONPropertyValueIsDoubleQuoted_ReturnsValidValue()
// {
//     let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':\"30\",'isEmployed':true}").bytesOf("age");
//     let result = bytes.asField();

//     assert( result.valid && result.value == 30 );
// }

#[test]
fn JSONPropertyValueTypeMismatch_Signed_ReturnsInvalidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':-30,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn JSONPropertyValueTypeMismatch_Float_ReturnsInvalidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':30.0,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn JSONPropertyValueTypeMismatch_String_ReturnsInvalidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':'thirty','isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn JSONPropertyValueIsFlawed_WithColon_ReturnsInvalidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3:0,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn JSONPropertyValueIsFlawed_WithSpace_ReturnsInvalidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3 0,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn JSONPropertyValueIsFlawed_WithLeftBrace_ReturnsInvalidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3{0,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn JSONPropertyValueIsFlawed_WithSingleQuote_AndIsParsable_ReturnsValidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3'0,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( result.valid & (result.value == 3) );
}

// #[test]
// fn JSONPropertyValueIsFlawed_WithDoubleQuote_AndIsParsable_ReturnsValidValue()
// {
//     let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3\"0,'isEmployed':true}").bytesOf("age");
//     let result = bytes.asField();

//     assert( result.valid & (result.value == 3) );
// }

#[test]
fn JSONPropertyValueIsFlawed_WithComma_AndIsParsable_ReturnsValidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3,0,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( result.valid & (result.value == 3) );
}

#[test]
fn JSONPropertyValueIsFlawed_WithRightBrace_AndIsParsable_ReturnsValidValue()
{
    let bytes : BytesU8 = JSON::new("{'name':'John Doe','age':3}0,'isEmployed':true}").bytesOf("age");
    let result = bytes.asField();

    assert( result.valid & (result.value == 3) );
}
