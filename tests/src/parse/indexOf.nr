use dep::noir::globals;
use dep::noir::parse::JSON;

#[test]
fn ValidInput_JSONAndAgeProperty_ReturnsExpectedValue()
{
    assert( JSON::new("{'age':30,isEmployed:true,'id':'0x3f'}").indexOf("age") == 2 );
}

#[test]
fn ValidInput_JSONAndIsEmployedProperty_ReturnsExpectedValue()
{
    assert( JSON::new("{'age':30,isEmployed:true,'id':'0x3f'}").indexOf("isEmployed") == 10 );
}

#[test]
fn ValidInput_JSONAndIDProperty_ReturnsExpectedValue()
{
    assert( JSON::new("{'age':30,isEmployed:true,'id':'0x3f'}").indexOf("id") == 27 );
}

#[test]
fn PropertyOverlapsJSONProperty1_ReturnsInvalidValue()
{
    assert( JSON::new("{'age ': 30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty2_ReturnsInvalidValue()
{
    assert( JSON::new("{' age': 30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty3_ReturnsInvalidValue()
{
    assert( JSON::new("{' age ': 30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty4_ReturnsInvalidValue()
{
    assert( JSON::new("{'Rage':30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty5_ReturnsInvalidValue()
{
    assert( JSON::new("{'Rage ':30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty6_ReturnsInvalidValue()
{
    assert( JSON::new("{'ageR':30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty7_ReturnsInvalidValue()
{
    assert( JSON::new("{' ageR':30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty8_ReturnsInvalidValue()
{
    assert( JSON::new("{Rage:30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty9_ReturnsInvalidValue()
{
    assert( JSON::new("{Rage :30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty10_ReturnsInvalidValue()
{
    assert( JSON::new("{ageR:30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty11_ReturnsInvalidValue()
{
    assert( JSON::new("{ ageR:30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty12_ReturnsInvalidValue()
{
    assert( JSON::new("{R age:30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty13_ReturnsInvalidValue()
{
    assert( JSON::new("{age R:30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty14_ReturnsInvalidValue()
{
    assert( JSON::new("{ age R:30}").indexOf("age") == -1 );
}

#[test]
fn PropertyOverlapsJSONProperty15_ReturnsInvalidValue()
{
    assert( JSON::new("{'AGE': 30}").indexOf("age") == -1 );
}

#[test]
fn PropertyIsEmpty_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("") == -1 );
}

#[test]
fn JSONIsFlawed_MissingLeftBrace_ReturnsMinus1()
{
    assert( JSON::new("age:30}").indexOf("age") == -1 );
}

#[test]
fn JSONIsFlawed_MissingRightBrace_IsRecoverable_ReturnsExpectedValue()
{
    assert( JSON::new("{age:30").indexOf("age") == 1 );
}

#[test]
fn JSONIsFlawed_MissingRightBrace_FaultySingleQuoteIsRecoverable_ReturnsExpectedValue()
{
    assert( JSON::new("{age':30").indexOf("age") == 1 );
}

// #[test]
// fn JSONIsFlawed_MissingRightBrace_FaultyDoubleQuoteIsRecoverable_ReturnsExpectedValue()
// {
//     assert( JSON::new("{age\":30").indexOf("age") == 1 );
// }

#[test]
fn JSONIsFlawed_MissingBothBraces_ReturnsMinus1()
{
    assert( JSON::new("age:30").indexOf("age") == -1 );
}

#[test]
fn PropertyIsFlawed_SingleQuote_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("a'ge") == -1 );
}

// #[test]
// fn PropertyIsFlawed_DoubleQuote_ReturnsMinus1()
// {
//     assert( JSON::new("{age:30}").indexOf("a\"ge") == -1 );
// }

#[test]
fn PropertyIsFlawed_SemiColon_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("a;ge") == -1 );
}

#[test]
fn PropertyIsFlawed_Comma_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("ag,e") == -1 );
}

#[test]
fn PropertyIsFlawed_Colon_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("ag:e") == -1 );
}

#[test]
fn PropertyIsFlawed_RightBrace_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("ag}e") == -1 );
}

#[test]
fn PropertyIsFlawed_LeftBrace_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("ag{e") == -1 );
}

#[test]
fn PropertyIsFlawed_Space_ReturnsMinus1()
{
    assert( JSON::new("{age:30}").indexOf("ag e") == -1 );
}

#[test]
fn JSONPropertyIsEmpty1_ReturnsMinus1()
{
    assert( JSON::new("{}").indexOf("age") == -1 );
}

#[test]
fn JSONPropertyIsEmpty2_ReturnsMinus1()
{
    assert( JSON::new("{''}").indexOf("age") == -1 );
}

#[test]
fn JSONPropertyIsEmpty3_ReturnsMinus1()
{
    assert( JSON::new("{30}").indexOf("age") == -1 );
}

#[test]
fn JSONPropertyIsEmpty4_ReturnsMinus1()
{
    assert( JSON::new("{'30'}").indexOf("age") == -1 );
}

#[test]
fn JSONPropertyIsMissing1_ReturnsMinus1()
{
    assert( JSON::new("{a : 30}").indexOf("age") == -1 );
}

#[test]
fn JSONPropertyIsMissing2_ReturnsMinus1()
{
    assert( JSON::new("{ag: 30}").indexOf("age") == -1 );
}

#[test]
fn JSONPropertyIsMissing3_ReturnsMinus1()
{
    assert( JSON::new("{ge: 30}").indexOf("age") == -1 );
}
