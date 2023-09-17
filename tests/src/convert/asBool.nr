use dep::noir::globals;
use dep::noir::convert;
use dep::noir::convert::BytesBool;
use dep::noir::parse::JSON;




#[test]
fn ValidInput_true_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == true) );
}


#[test]
fn ValidInput_trueInSingleQuotes_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'true'}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == true) );
}

#[test]
fn ValidInput_one_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':1}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == true) );
}

#[test]
fn ValidInput_oneInSingleQuotes_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'1'}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == true) );
}

#[test]
fn ValidInput_false_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':false}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == false) );
}

#[test]
fn ValidInput_falseInSingleQuotes_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'false'}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == false) );
}

#[test]
fn ValidInput_zero_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':0}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == false) );
}


fn ValidInput_zeroInSingleQuotes_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'0'}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( result.valid & (result.value == false) );
}


//-----------Invalid Inputs




#[test]
fn InvalidInput_true_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':trye}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( !result.valid & (result.value == false) );
}


#[test]
fn InvalidInput_false_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':falle}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( !result.valid & (result.value == false) );
}



#[test]
fn InvalidInput_one_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':01}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( !result.valid & (result.value == false) );
}




#[test]
fn InvalidInput_zero_ReturnsExpectedValue()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':000}").bytesOf("isEmployed");
    let result = bytes.asBool();
    
    assert( !result.valid & (result.value == false) );
}


