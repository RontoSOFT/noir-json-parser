use dep::noir::globals;
use dep::noir::parse::JSON;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let json = JSON::new("{'age':30,isEmployed:true,'id':'0x3f'}");
    let props = ("age", "isEmployed", "id");

    assert( json.indexOf(props.0) ==  2 );
    assert( json.indexOf(props.1) == 10 );
    assert( json.indexOf(props.2) == 27 );
}

#[test]
fn PropertyOverlapsJSONProperty_ReturnsInvalidValue()
{
    let prop = "age";
    let jsons =
    (
        JSON::new("{'ageRestriction':30}"),
        JSON::new("{' ageRestriction':30}"),
        JSON::new("{'age Restriction':30}"),
        JSON::new("{' age Restriction':30}"),
        JSON::new("{ageRestriction:30}"),
        JSON::new("{ ageRestriction:30}"),
        JSON::new("{ageRestriction :30}"),
        JSON::new("{ ageRestriction :30}"),
        JSON::new("{ age Restriction:30}"),
    );

    assert( jsons.0.indexOf(prop) == -1 );
    assert( jsons.1.indexOf(prop) == -1 );
    assert( jsons.2.indexOf(prop) == -1 );
    assert( jsons.3.indexOf(prop) == -1 );
    assert( jsons.4.indexOf(prop) == -1 );
    assert( jsons.5.indexOf(prop) == -1 );
    assert( jsons.6.indexOf(prop) == -1 );
    assert( jsons.7.indexOf(prop) == -1 );
    assert( jsons.8.indexOf(prop) == -1 );
}

#[test]
fn PropertyIsEmpty_ReturnsMinus1()
{
    let json = JSON::new("{ age: 30 }");
    let prop = "";

    assert( json.indexOf(prop) == -1 );
}

#[test]
fn PropertyIsMalformed_ReturnsMinus1()
{
    let json = JSON::new("{ age: 30 }");
    let props =
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

    for prop in props
    {
        assert( json.indexOf(prop) == -1 );
    }
}

#[test]
fn JSONPropertyIsEmpty_ReturnsMinus1()
{
    let prop = "age";
    let jsons =
    [
        JSON::new("{    }"),
        JSON::new("{ '' }"),
        JSON::new("{ 30 }"),
        JSON::new("{'30'}"),
    ];

    for json in jsons
    {
        assert( json.indexOf(prop) == -1 );
    }
}

#[test]
fn JSONPropertyIsMissing_ReturnsMinus1()
{
    let prop = "age";
    let jsons =
    [
        JSON::new("{a : 30}"),
        JSON::new("{ag: 30}"),
        JSON::new("{ge: 30}"),
        JSON::new("{ae: 30}"),
    ];

    for json in jsons
    {
        assert( json.indexOf(prop) == -1 );
    }
}
