use dep::noir::new_parse::JSON;

#[test]
fn property_number_zero()
{
    let (key, value) = ("a", "0");

    let kvp = JSON::new("{'a' : 0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_single_digit()
{
    let (key, value) = ("a", "1");

    let kvp = JSON::new("{'a' : 1}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_multiple_digits()
{
    let (key, value) = ("a", "12345");

    let kvp = JSON::new("{'a' : 12345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_zero()
{
    let (key, value) = ("a", "-0");

    let kvp = JSON::new("{'a' : -0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_single_digit()
{
    let (key, value) = ("a", "-1");

    let kvp = JSON::new("{'a' : -1}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_multiple_digits()
{
    let (key, value) = ("a", "-12345");

    let kvp = JSON::new("{'a' : -12345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_plus_zero()
{
    let kvp = JSON::new("{'a' : +0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_plus_single_digit()
{
    let kvp = JSON::new("{'a' : +1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_plus_multiple_digits()
{
    let kvp = JSON::new("{'a' : +12345}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_double_zero()
{
    let kvp = JSON::new("{'a' : 00}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_leading_zero_single_digit()
{
    let kvp = JSON::new("{'a' : 01}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_leading_multiple_zero_single_digit()
{
    let kvp = JSON::new("{'a' : 001}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_leading_zero_multiple_digits()
{
    let kvp = JSON::new("{'a' : 012345}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_double_minus_number()
{
    let kvp = JSON::new("{'a' : --1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_minus_between_digits_of_number()
{
    let kvp = JSON::new("{'a' : 1-1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_two_digits_between_two_minuses()
{
    let kvp = JSON::new("{'a' : -1-1}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_minus_after_digits()
{
    let kvp = JSON::new("{'a' : 1-}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_between_minuses()
{
    let kvp = JSON::new("{'a' : -1-}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_single_digit_comma()
{
    let kvp = JSON::new("{'a' : 1,}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_single_digit_colon()
{
    let kvp = JSON::new("{'a' : 1:}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_single_digit_quote()
{
    let kvp = JSON::new("{'a' : 1'}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_single_digit_left_brace()
{
    let kvp = JSON::new("{'a' : 1{}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_single_digit_right_brace()
{
    let kvp = JSON::new("{'a' : 1}}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_single_digit_left_bracket()
{
    let kvp = JSON::new("{'a' : 1[}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_single_digit_right_bracket()
{
    let kvp = JSON::new("{'a' : 1]}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}
