use dep::noir::new_parse::JSON;

#[test]
fn property_name_single()
{
    let (key, value) = ("a", "5");

    let kvp = JSON::new("{'a' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_multi()
{
    let (key, value) = ("abc", "5");

    let kvp = JSON::new("{'abc' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

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
fn property_name_space()
{
    let (key, value) = ("a ", "5");

    let kvp = JSON::new("{'a ' : 5}").get(key);

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
fn property_name_right_bracket()
{
    let (key, value) = ("a]", "5");

    let kvp = JSON::new("{'a]' : 5}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_name_left_bracket()
{
    let (key, value) = ("a[", "5");

    let kvp = JSON::new("{'a[' : 5}").get(key);

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

#[test]
fn property_faulty_colon()
{
    let kvp = JSON::new("{:'a' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_comma_before()
{
    let kvp = JSON::new("{,'a' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_comma_after()
{
    let kvp = JSON::new("{'a', : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_quote_before()
{
    let kvp = JSON::new("{''a' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_quote_after()
{
    let kvp = JSON::new("{'a'' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_left_brace_before()
{
    let kvp = JSON::new("{{'a' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_left_brace_after()
{
    let kvp = JSON::new("{'a'{ : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_right_brace_before()
{
    let kvp = JSON::new("{}'a' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_right_brace_after()
{
    let kvp = JSON::new("{'a'} : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_left_bracket_before()
{
    let kvp = JSON::new("{['a' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_left_bracket_after()
{
    let kvp = JSON::new("{'a'[ : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_right_bracket_before()
{
    let kvp = JSON::new("{]'a' : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_name_right_bracket_after()
{
    let kvp = JSON::new("{'a'] : 1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}
