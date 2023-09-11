use crate::parsers;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let prop_name = "age";

    let res = parsers::U32::getValue(json, prop_name);

    assert(res.valid & (res.value == 30));
}

#[test]
fn JSONPropertyValueIsSingleQuoted_ReturnsValidValue()
{
    let json = "{'name':'John Doe','age':'30','isEmployed':true}";
    let prop_name = "age";

    let res = parsers::U32::getValue(json, prop_name);

    assert(res.valid & (res.value == 30));
}

// #[test]
// fn JSONPropertyValueIsDoubleQuoted_ReturnsValidValue()
// {
//     let json = "{'name':'John Doe','age':\"30\",'isEmployed':true}";
//     let prop_name = "age";

//     let res = parsers::U32::getValue(json, prop_name);

//     assert(res.valid);
//     assert(res.value == 30);
// }

#[test]
fn JSONIsEmpty_ReturnsInvalidValue()
{
    let json = "{}";
    let prop_name = "age";

    let res = parsers::U32::getValue(json, prop_name);

    assert(!res.valid & (res.value == 0));
}

#[test]
fn PropertyIsEmpty_ReturnsInvalidValue()
{
    let json = "{ age: 30 }";
    let prop_name = "";

    let res = parsers::U32::getValue(json, prop_name);

    assert(!res.valid & (res.value == 0));
}

#[test]
fn JSONIsMissingProperty_ReturnsInvalidValue()
{
    let json = "{'name':'John Doe','isEmployed':true,id:'0x3f'}";
    let prop_name = "age";

    let res = parsers::U32::getValue(json, prop_name);

    assert(!res.valid & (res.value == 0));
}

#[test]
fn JSONPropertyValueHasMinusSign_ReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':-30,'isEmployed':true}";
    let prop_name = "age";

    let res = parsers::U32::getValue(json, prop_name);

    assert(!res.valid & (res.value == 0));
}

fn JSONPropertyValueTypeIsFloat_ReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':30.0,'isEmployed':true}";
    let prop_name = "age";

    let res = parsers::U32::getValue(json, prop_name);

    assert(!res.valid & (res.value == 0));
}

#[test]
fn JSONPropertyValueTypeIsString_ReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':'thirty','isEmployed':true}";
    let prop_name = "age";

    let res = parsers::U32::getValue(json, prop_name);

    assert(!res.valid & (res.value == 0));
}

#[test]
fn JSONPropertyValueIsMalformed_ReturnsInvalidValue()
{
    let prop_name = "age";
    let jsons =
    [
        "{'name':'John Doe','age':3:0,'isEmployed':true}",
        "{'name':'John Doe','age':3 0,'isEmployed':true}",
        "{'name':'John Doe','age':3{0,'isEmployed':true}",
    ];

    for json in jsons
    {
        let res = parsers::U32::getValue(json, prop_name);

        assert(!res.valid & (res.value == 0));
    }
}

#[test]
fn JSONIsMalformedButPropertyValueIsParsable_ReturnsValidValue()
{
    let prop_name = "age";
    let jsons =
    [
        "{'name':'John Doe','age':3'0,'isEmployed':true}",
        // "{'name':'John Doe','age':3\"0,'isEmployed':true}",
        "{'name':'John Doe','age':3,0,'isEmployed':true}",
        "{'name':'John Doe','age':3}0,'isEmployed':true}",
    ];

    for json in jsons
    {
        let res = parsers::U32::getValue(json, prop_name);

        assert(res.valid & (res.value == 3));
    }
}
