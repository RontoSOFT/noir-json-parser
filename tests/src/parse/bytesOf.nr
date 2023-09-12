use dep::noir::globals;
use dep::noir::parse::JSON;
use dep::noir::convert;

type BytesBool = convert::StringBytes<globals::BOOL_CHAR_SIZE>;
type BytesU32  = convert::StringBytes<globals::U32_CHAR_SIZE>;

#[test]
fn PropertyIsEmpty_ReturnsInvalidValue()
{
    let json = JSON::new("{ age: 30 }");
    let prop = "";

    let result : BytesU32 = json.bytesOf(prop);

    assert(!result.valid);
    assert(result.bytes == [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1]);
}

#[test]
fn JSONPropertyIsMissing_ReturnsInvalidValue()
{
    let json = JSON::new("{'name':'John Doe','isEmployed':true,id:'0x3f'}");
    let prop = "age";

    let result : BytesU32 = json.bytesOf(prop);

    assert(!result.valid);
    assert(result.bytes == [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1]);
}

#[test]
fn JSONIsEmpty_ReturnsInvalidValue()
{
    let json = JSON::new("{}");
    let prop = "age";

    let result : BytesU32 = json.bytesOf(prop);

    assert(!result.valid);
    assert(result.bytes == [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1]);
}

#[test]
fn ValidInputs_ReturnsExpectedBoolValueBytes()
{
    let json = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}");
    let prop = "isEmployed";

    let result : BytesBool = json.bytesOf(prop);

    assert(result.valid);
    assert(result.bytes == [0x74, 0x72, 0x75, 0x65, -1]);
}

#[test]
fn ValidInputs_ReturnsExpectedU32ValueBytes()
{
    let json = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}");
    let prop = "age";

    let result : BytesU32 = json.bytesOf(prop);

    assert(result.valid);
    assert(result.bytes == [0x33, 0x30, -1, -1, -1, -1, -1, -1, -1, -1]);
}
