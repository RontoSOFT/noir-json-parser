use dep::noir::new_parse::JSON;

#[test]
unconstrained fn propertyNameU()
{
    let (key, value) = ("a", "5");
    let bytes = "{'a' : 5}".as_bytes();
    let json = dep::noir::new_parse::parse(bytes);

    assert(json.len() != 0);
    assert(json[0].key[0] == key.as_bytes()[0]);
    assert(json[0].value[0] == value.as_bytes()[0]);
}

#[test]
fn property_number_zero()
{
    let (key, value) = ("a", "0");

    let kvp = JSON::new("{'a' : 0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_zero_point()
{
    let kvp = JSON::new("{'a' : 0.}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn property_number_point_zero()
{
    let kvp = JSON::new("{'a' : .0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn property_number_zero_point_zero()
{
    let (key, value) = ("a", "0.0");

    let kvp = JSON::new("{'a' : 0.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_one_point_zero()
{
    let (key, value) = ("a", "1.0");

    let kvp = JSON::new("{'a' : 1.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_multiple_digits_point_zero()
{
    let (key, value) = ("a", "12345.0");

    let kvp = JSON::new("{'a' : 12345.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_one_point_zero_multiple_digits()
{
    let (key, value) = ("a", "0.012345");

    let kvp = JSON::new("{'a' : 0.012345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_multiple_digits_point_zero_multiple_digits()
{
    let (key, value) = ("a", "12345.012345");

    let kvp = JSON::new("{'a' : 12345.012345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_multiple_digits_point_multiple_digits()
{
    let (key, value) = ("a", "12345.12345");

    let kvp = JSON::new("{'a' : 12345.12345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_double_zero()
{
    let kvp = JSON::new("{'a' : 00}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn property_number_leading_zero()
{
    let kvp = JSON::new("{'a' : 05}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn property_number_single_digit()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{'a' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_multiple_digits()
{
    let (key, value) = ("a", "12345");

    let kvp = JSON::new("{'a' : 12345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_string_zero()
{
    let (key, value) = ("a", "'0'");

    let kvp = JSON::new("{'a' : '0'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_string_multiple_zero()
{
    let (key, value) = ("a", "'000'");

    let kvp = JSON::new("{'a' : '000'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_number_string_multiple_digits()
{
    let (key, value) = ("a", "'12345'");

    let kvp = JSON::new("{'a' : '12345'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_literal_null()
{
    let (key, value) = ("a", "null");

    let kvp = JSON::new("{'a' : null}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_literal_true()
{
    let (key, value) = ("a", "true");

    let kvp = JSON::new("{'a' : true}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_literal_false()
{
    let (key, value) = ("a", "false");

    let kvp = JSON::new("{'a' : false}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_string()
{
    let (key, value) = ("a", "'abc'");

    let kvp = JSON::new("{'a' : 'abc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_string_with_escaped_quote()
{
    let (key, value) = ("a", "'a\'bc'");

    let kvp = JSON::new("{'a' : 'a\'bc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_string_with_double_escape()
{
    let (key, value) = ("a", "'a\\bc'");

    let kvp = JSON::new("{'a' : 'a\\bc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_string_with_double_escape_and_quote()
{
    let (key, value) = ("a", "'a\\'bc'");

    let kvp = JSON::new("{'a' : 'a\\'bc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_string_null()
{
    let (key, value) = ("a", "'null'");

    let kvp = JSON::new("{'a' : 'null'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_string_true()
{
    let (key, value) = ("a", "'true'");

    let kvp = JSON::new("{'a' : 'true'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn property_string_false()
{
    let (key, value) = ("a", "'false'");

    let kvp = JSON::new("{'a' : 'false'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn escapedPropertyName_Left()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{\'a' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn escapedPropertyName_Right()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{'a\' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn escapedPropertyName_Both()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{\'a\' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value == value.as_bytes());
}

#[test]
fn literalWithEscape()
{
    let kvp = JSON::new("{'a' : fals\e}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn incompleteLiteral_1()
{
    let kvp = JSON::new("{'a' : fals}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn incompleteLiteral_2()
{
    let kvp = JSON::new("{'a' : t}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn incompleteLiteral_3()
{
    let kvp = JSON::new("{'a' : nul}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn wrongLiteral_1()
{
    let kvp = JSON::new("{'a' : falst}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn wrongLiteral_2()
{
    let kvp = JSON::new("{'a' : nult}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn wrongLiteral_3()
{
    let kvp = JSON::new("{'a' : truf}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn missingValue_1()
{
    let kvp = JSON::new("{'a' : }").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn missingValue_2()
{
    let kvp = JSON::new("{'a' : ").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}
