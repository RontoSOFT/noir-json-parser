use dep::noir::globals::BYTE_NULL;
use dep::noir::parse::JSON;
use dep::noir::convert::BytesBool;
use dep::noir::convert::BytesU32;
use dep::noir::convert::StringBytes;

#[test]
fn PropertyIsEmpty_ReturnsInvalidValue()
{
    let result : BytesU32 = JSON::new("{ age: 30 }").bytesOf("");

    assert(!result.valid);
    assert(result.bytes == [BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}

#[test]
fn JSONPropertyIsMissing_ReturnsInvalidValue()
{
    let result : BytesU32 = JSON::new("{'name':'John Doe','isEmployed':true,id:'0x3f'}").bytesOf("missingProperty");

    assert(!result.valid);
    assert(result.bytes == [BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}

#[test]
fn JSONIsEmpty_ReturnsInvalidValue()
{
    let result : BytesU32 = JSON::new("{}").bytesOf("age");

    assert(!result.valid);
    assert(result.bytes == [BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}

#[test]
fn ValidInputs_ReturnsExpectedBoolValueBytes()
{
    let result : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}").bytesOf("isEmployed");

    assert(result.valid);
    assert(result.bytes == [0x74, 0x72, 0x75, 0x65, BYTE_NULL]);
}

#[test]
fn ValidInputs_ReturnsExpectedU32ValueBytes()
{
    let result : BytesU32 = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}").bytesOf("age");

    assert(result.valid);
    assert(result.bytes == [0x33, 0x30, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}

#[test]
fn ValidInputs_ReturnsExpectedStringValueBytes()
{
    let result : StringBytes<8> = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}").bytesOf("name");

    assert(result.valid);
    assert(result.bytes == [0x4a, 0x6f, 0x68, 0x6e, 0x20, 0x44, 0x6f, 0x65]);
}
