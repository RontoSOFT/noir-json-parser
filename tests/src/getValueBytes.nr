use dep::noir_json_parser::globals;
use dep::noir_json_parser::parsing;

type BytesBool = parsing::ValueBytes<globals::BOOL_CHAR_SIZE>;
type BytesU32 = parsing::ValueBytes<globals::U32_CHAR_SIZE>;

#[test]
fn PropertyIsEmpty_ReturnsInvalidValue()
{
    let json = "{ age: 30 }";
    let prop_name = "";

    let result : BytesU32 = parsing::getValueBytes(json, prop_name);

    assert(!result.valid);
    assert(result.bytes == [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1]);
}

#[test]
fn JSONPropertyIsMissing_ReturnsInvalidValue()
{
    let json = "{'name':'John Doe','isEmployed':true,id:'0x3f'}";
    let prop_name = "age";

    let result : BytesU32 = parsing::getValueBytes(json, prop_name);

    assert(!result.valid);
    assert(result.bytes == [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1]);
}

#[test]
fn JSONIsEmpty_ReturnsInvalidValue()
{
    let json = "{}";
    let prop_name = "age";

    let result : BytesU32 = parsing::getValueBytes(json, prop_name);

    assert(!result.valid);
    assert(result.bytes == [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1]);
}

#[test]
fn ValidInputs_ReturnsExpectedBoolValueBytes()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let prop = "isEmployed";

    let result : BytesBool = parsing::getValueBytes(json, prop);

    assert(result.valid);
    assert(result.bytes == [0x74, 0x72, 0x75, 0x65, -1]);
}

#[test]
fn ValidInputs_ReturnsExpectedU32ValueBytes()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let prop = "age";

    let result : BytesU32 = parsing::getValueBytes(json, prop);

    assert(result.valid);
    assert(result.bytes == [0x33, 0x30, -1, -1, -1, -1, -1, -1, -1, -1]);
}
