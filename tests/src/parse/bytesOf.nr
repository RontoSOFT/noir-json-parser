use dep::noir::globals::BYTE_NULL;
use dep::noir::parse::JSON;
use dep::noir::convert::BytesBool;
use dep::noir::convert::BytesU32;

#[test]
fn PropertyIsEmpty_ReturnsInvalidValue()
{
    let json = JSON::new("{ age: 30 }");
    let prop = "";

    let result : BytesU32 = json.bytesOf(prop);

    assert(!result.valid);
    assert(result.bytes == [BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}

#[test]
fn JSONPropertyIsMissing_ReturnsInvalidValue()
{
    let json = JSON::new("{'name':'John Doe','isEmployed':true,id:'0x3f'}");
    let prop = "age";

    let result : BytesU32 = json.bytesOf(prop);

    assert(!result.valid);
    assert(result.bytes == [BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}

#[test]
fn JSONIsEmpty_ReturnsInvalidValue()
{
    let json = JSON::new("{}");
    let prop = "age";

    let result : BytesU32 = json.bytesOf(prop);

    assert(!result.valid);
    assert(result.bytes == [BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}

#[test]
fn ValidInputs_ReturnsExpectedBoolValueBytes()
{
    let json = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}");
    let prop = "isEmployed";

    let result : BytesBool = json.bytesOf(prop);

    assert(result.valid);
    assert(result.bytes == [0x74, 0x72, 0x75, 0x65, BYTE_NULL]);
}

#[test]
fn ValidInputs_ReturnsExpectedU32ValueBytes()
{
    let json = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}");
    let prop = "age";

    let result : BytesU32 = json.bytesOf(prop);

    assert(result.valid);
    assert(result.bytes == [0x33, 0x30, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
}
