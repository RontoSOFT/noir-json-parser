use dep::noir::new_parse::JSON;

#[test]
fn property_string_number_zero()
{
    let (key, value) = ("a", "'0'");

    let kvp = JSON::new("{'a' : '0'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_number_multiple_zero()
{
    let (key, value) = ("a", "'000'");

    let kvp = JSON::new("{'a' : '000'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_number_multiple_digits()
{
    let (key, value) = ("a", "'12345'");

    let kvp = JSON::new("{'a' : '12345'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string()
{
    let (key, value) = ("a", "'abc'");

    let kvp = JSON::new("{'a' : 'abc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_with_escaped_quote()
{
    let (key, value) = ("a", "'a\'bc'");

    let kvp = JSON::new("{'a' : 'a\'bc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_with_double_escape()
{
    let (key, value) = ("a", "'a\\bc'");

    let kvp = JSON::new("{'a' : 'a\\bc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_with_double_escape_and_quote()
{
    let (key, value) = ("a", "'a\\'bc'");

    let kvp = JSON::new("{'a' : 'a\\'bc'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_null()
{
    let (key, value) = ("a", "'null'");

    let kvp = JSON::new("{'a' : 'null'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_true()
{
    let (key, value) = ("a", "'true'");

    let kvp = JSON::new("{'a' : 'true'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_string_false()
{
    let (key, value) = ("a", "'false'");

    let kvp = JSON::new("{'a' : 'false'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_string_value_right_brace()
{
    let (key, value) = ("a", "'5}'");

    let kvp = JSON::new("{'a' : '5}'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_string_value_left_brace()
{
    let (key, value) = ("a", "'5{'");

    let kvp = JSON::new("{'a' : '5{'}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}
