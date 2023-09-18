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
fn property_number_any()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{'a' : 5}").get(key);

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
fn leadingZero()
{
    let key = "a";

    let kvp = JSON::new("{'a' : 05}").get(key);

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn brokenLiteral()
{
    let key = "a";

    let kvp = JSON::new("{'a' : fa}").get(key);

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}

#[test]
fn incompleteLiteral()
{
    let key = "a";

    let kvp = JSON::new("{'a' : fa}").get(key);

    assert(kvp.key == [0; 1]);
    assert(kvp.value == [0; 1]);
}
