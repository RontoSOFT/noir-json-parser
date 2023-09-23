use dep::noir::convert::BytesBool;
use dep::noir::new_parse::JSON;

#[test]
fn property_literal_true_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_some());
    assert(result.unwrap_unchecked() == true);
}

#[test]
fn property_string_true_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'true'}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_literal_one_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':1}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_string_one_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'1'}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_literal_false_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':false}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_some());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_string_false_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'false'}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_number_zero_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':0}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

fn property_string_quote_zero_quote_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'0'}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_literal_null_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':null}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_some());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_string_null_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':'null'}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_literal_wrong_letter_as_bool_true()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':trye}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_literal_wrong_letter_as_bool_false()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':falle}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_literal_wrong_letter_as_bool_null()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':nulm}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_number_zero_one_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':01}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}

#[test]
fn property_number_three_zero_as_bool()
{
    let bytes : BytesBool = JSON::new("{'name':'John Doe','age':30,'isEmployed':000}").get("isEmployed").value;
    let result = bytes.asBool();

    assert(result.is_none());
    assert(result.unwrap_unchecked() == false);
}
