use crate::utils;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let json = "{'age':30,isEmployed:true,'id':'0x3f'}";
    let json_bytes = json.as_bytes();

    let prop_names = ("age", "isEmployed", "id");

    assert( utils::findProperty(json_bytes, prop_names.0.as_bytes()) ==  2 );
    assert( utils::findProperty(json_bytes, prop_names.1.as_bytes()) == 10 );
    assert( utils::findProperty(json_bytes, prop_names.2.as_bytes()) == 27 );
}

#[test]
fn PropertyIsEmpty_ReturnsMinus1()
{
    let json = "{ age: 30 }";
    let prop_name = "";

    assert( utils::findProperty(json.as_bytes(), prop_name.as_bytes()) == -1 );
}

#[test]
fn PropertyIsMalformed_ReturnsMinus1()
{
    let json = "{ age: 30 }";
    let json_bytes = json.as_bytes();

    let prop_names =
    [
        "a'ge",
        // "a\"ge",
        "a;ge",
        "ag}e",
        "ag{e",
        "ag e",
    ];

    for name in prop_names
    {
        assert( utils::findProperty(json_bytes, name.as_bytes()) == -1 );
    }
}

#[test]
fn JSONPropertyIsEmpty_ReturnsMinus1()
{
    let prop_name = "age";
    let jsons =
    [
        "{    }",
        "{ '' }",
        "{ 30 }",
        "{'30'}",
    ];

    for json in jsons
    {
        assert( utils::findProperty(json.as_bytes(), prop_name.as_bytes()) == -1 );
    }
}

#[test]
fn JSONPropertyIsMissing_ReturnsMinus1()
{
    let prop_name = "age";
    let jsons =
    [
        "{a : 30}",
        "{ag: 30}",
        "{ge: 30}",
        "{ae: 30}",
    ];

    for json in jsons
    {
        assert( utils::findProperty(json.as_bytes(), prop_name.as_bytes()) == -1 );
    }
}
