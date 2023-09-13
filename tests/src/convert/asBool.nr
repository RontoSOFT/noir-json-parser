use dep::noir::globals::BYTE_NULL;
use dep::noir::parse::JSON;
use dep::noir::convert::BytesBool;
use dep::noir::convert::BytesU32;
use dep::noir::convert::StringBytes;

#[test]
fn ValidInputTrue_ReturnsExpectedValueTrue()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( val.valid & (val.value == true));
}

#[test]
fn ValidInputFalse_ReturnsExpectedValueValidAndFalse()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':false}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( val.valid & (val.value == false));
}

#[test]
fn ValidInputOne_ReturnsExpectedValueValidAndTrue()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':'1'}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( val.valid & (val.value == true));
}

#[test]
fn ValidInputWithoutQuotesOne_ReturnsExpectedValueValidAndTrue()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':1}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( val.valid & (val.value == true));
}


#[test]
fn ValidInputZero_ReturnsExpectedValueValidAndFalse()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':'0'}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( val.valid & (val.value == false));
}


#[test]
fn ValidInputWithoutQuotesZero_ReturnsExpectedValueValidAndFalse()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':0}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( val.valid & (val.value == false));
}


// TODO: Check why both these `assert` passing
#[test]
fn InvalidInputsFalse_ReturnsExpectedValueInvalidAndFalse()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':falle}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    
    assert( !val.valid & (val.value == false));// DEBUG: Both these passes. Why?
}


#[test]
fn InvalidInputsTrue_ReturnsExpectedValueInvalidAndFalse()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':trye}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( !val.valid & (val.value == false));
}

#[test]
fn InvalidInputsTrue_ReturnsExpectedValueInvalidTrueAndFalse()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':True}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( !val.valid & (val.value == false));
}

#[test]
fn InvalidInputsTrue_ReturnsExpectedValueInvalidFalseAndFalse()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':False}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( !val.valid & (val.value == false));
}
//----------------
#[test]
fn ValidInput_ReturnsExpectedValueInvalidAndTrue()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':123456}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);
    dep::std::println(result);
    let val= result.asBool();
    
    
    assert( !val.valid & (val.value == false));
}


//For more than 5 characters, the value will be 0
#[test]
fn ValidInputNumberUnderQuotes_ReturnsExpectedValueValidAndTrue()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':'123456'}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( !val.valid & (val.value == false));
}

//----------------
#[test]
fn ValidInputNumberUnderQuotes_ReturnsExpectedValueValidAndTrueFor12345()
{
    let json  = JSON::new("{'name':'John Doe','age':30,'isEmployed':'12345'}");
    let prop = "isEmployed";

    let result: BytesBool = json.bytesOf(prop);

    let val= result.asBool();
    
    
    assert( val.valid & (val.value == true));
}
