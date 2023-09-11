use dep::noir::parse::JSON;
use dep::noir::convert;

#[test]
fn ValidInputsStringBytes_ReturnsExpectedValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, 0x36, 0x37, 0x35, 0x31, 0x30]);
    assert( bytes.asU32().value == 4293867510 );
}

#[test]
fn ValidInputsStringBytesLargerThanMaxU32_ReturnsOverflowedValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, 0x39, 0x34, 0x39, 0x36, 0x37, 0x32, 0x39, 0x36]);
    assert( bytes.asU32().value == 0 );
}

#[test]
fn ValidInputsJSON_ReturnsExpectedValue()
{
    let json = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}");
    let prop = "age";

    let result = json.bytesOf(prop).asU32();

    assert(result.valid & (result.value == 30));
}

#[test]
fn JSONPropertyValueIsSingleQuoted_ReturnsValidValue()
{
    let json = JSON::new("{'name':'John Doe','age':'30','isEmployed':true}");
    let prop = "age";

    let result = json.bytesOf(prop).asU32();

    assert(result.valid & (result.value == 30));
}

// #[test]
// fn JSONPropertyValueIsDoubleQuoted_ReturnsValidValue()
// {
//     let json = JSON::new("{'name':'John Doe','age':\"30\",'isEmployed':true}");
//     let prop = "age";

//     let result = json.bytesOf(prop).asU32();

//     assert(result.valid);
//     assert(result.value == 30);
// }

#[test]
fn JSONPropertyValueHasMinusSign_ReturnsInvalidValue()
{
    let json = JSON::new("{'name':'John Doe','age':-30,'isEmployed':true}");
    let prop = "age";

    let result = json.bytesOf(prop).asU32();

    assert(!result.valid & (result.value == 0));
}

fn JSONPropertyValueTypeIsFloat_ReturnsInvalidValue()
{
    let json = JSON::new("{'name':'John Doe','age':30.0,'isEmployed':true}");
    let prop = "age";

    let result = json.bytesOf(prop).asU32();

    assert(!result.valid & (result.value == 0));
}

#[test]
fn JSONPropertyValueTypeIsString_ReturnsInvalidValue()
{
    let json = JSON::new("{'name':'John Doe','age':'thirty','isEmployed':true}");
    let prop = "age";

    let result = json.bytesOf(prop).asU32();

    assert(!result.valid & (result.value == 0));
}

#[test]
fn JSONPropertyValueIsMalformed_ReturnsInvalidValue()
{
    let prop = "age";
    let jsons =
    [
        JSON::new("{'name':'John Doe','age':3:0,'isEmployed':true}"),
        JSON::new("{'name':'John Doe','age':3 0,'isEmployed':true}"),
        JSON::new("{'name':'John Doe','age':3{0,'isEmployed':true}"),
    ];

    for json in jsons
    {
        let result = json.bytesOf(prop).asU32();

        assert(!result.valid & (result.value == 0));
    }
}

#[test]
fn JSONIsMalformedButPropertyValueIsParsable_ReturnsValidValue()
{
    let prop = "age";
    let jsons =
    [
        JSON::new("{'name':'John Doe','age':3'0,'isEmployed':true}"),
        // JSON::new("{'name':'John Doe','age':3\"0,'isEmployed':true}"),
        JSON::new("{'name':'John Doe','age':3,0,'isEmployed':true}"),
        JSON::new("{'name':'John Doe','age':3}0,'isEmployed':true}"),
    ];

    for json in jsons
    {
        let result = json.bytesOf(prop).asU32();

        assert(result.valid & (result.value == 3));
    }
}
