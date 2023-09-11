use dep::noir_json_parser::globals;
use dep::noir_json_parser::parsing;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let json = "{'age':30,isEmployed:true,'id':'0x3f'}";
    let json_bytes = json.as_bytes();

    let prop_names = ("age", "isEmployed", "id");

    assert( parsing::findProperty(json_bytes, prop_names.0.as_bytes()) ==  2 );
    assert( parsing::findProperty(json_bytes, prop_names.1.as_bytes()) == 10 );
    assert( parsing::findProperty(json_bytes, prop_names.2.as_bytes()) == 27 );
}

#[test]
fn PropertyOverlapsJSONProperty_ReturnsInvalidValue()
{
    let jsons =
    (
        "{'ageRestriction':30}",
        "{' ageRestriction':30}",
        "{'age Restriction':30}",
        "{' age Restriction':30}",
        "{ageRestriction:30}",
        "{ ageRestriction:30}",
        "{ageRestriction :30}",
        "{ ageRestriction :30}",
        "{ age Restriction:30}",
    );

    let prop_name = "age";

    assert( parsing::findProperty(jsons.0.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.1.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.2.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.3.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.4.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.5.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.6.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.7.as_bytes(), prop_name.as_bytes()) == -1 );
    assert( parsing::findProperty(jsons.8.as_bytes(), prop_name.as_bytes()) == -1 );
}

#[test]
fn PropertyIsEmpty_ReturnsMinus1()
{
    let json = "{ age: 30 }";
    let prop_name = "";

    assert( parsing::findProperty(json.as_bytes(), prop_name.as_bytes()) == -1 );
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
        "ag,e",
        "ag:e",
        "ag}e",
        "ag{e",
        "ag e",
    ];

    for name in prop_names
    {
        assert( parsing::findProperty(json_bytes, name.as_bytes()) == -1 );
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
        assert( parsing::findProperty(json.as_bytes(), prop_name.as_bytes()) == -1 );
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
        assert( parsing::findProperty(json.as_bytes(), prop_name.as_bytes()) == -1 );
    }
}
