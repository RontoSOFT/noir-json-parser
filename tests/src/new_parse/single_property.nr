use dep::noir::new_parse::JSON;

#[test]
fn property_name_missing_value()
{
    let kvp = JSON::new("{'a' : }").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_missing_value2()
{
    let kvp = JSON::new("{'a' : ").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_colon()
{
    let (key, value) = ("a:", "5");

    let kvp = JSON::new("{'a:' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_right_brace()
{
    let (key, value) = ("a}", "5");

    let kvp = JSON::new("{'a}' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_left_brace()
{
    let (key, value) = ("a{", "5");

    let kvp = JSON::new("{'a{' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_escaped_left_and_right()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{\'a\' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_escaped_left()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{\'a' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_escaped_right()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{'a\' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}
