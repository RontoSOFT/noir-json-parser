use dep::noir::new_parse::JSON;

#[test]
fn property_number_zero_point_zero()
{
    let (key, value) = ("a", "0.0");

    let kvp = JSON::new("{'a' : 0.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_point_single_digits()
{
    let (key, value) = ("a", "0.1");

    let kvp = JSON::new("{'a' : 0.1}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_point_multiple_digits()
{
    let (key, value) = ("a", "0.12345");

    let kvp = JSON::new("{'a' : 0.12345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_zero_point_multiple_digits()
{
    let (key, value) = ("a", "-0.12345");

    let kvp = JSON::new("{'a' : -0.12345}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_single_digit_point_zero()
{
    let (key, value) = ("a", "1.0");

    let kvp = JSON::new("{'a' : 1.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_single_digit_point_zero()
{
    let (key, value) = ("a", "-1.0");

    let kvp = JSON::new("{'a' : -1.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_single_digit_point_single_digit()
{
    let (key, value) = ("a", "1.2");

    let kvp = JSON::new("{'a' : 1.2}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_single_digit_point_single_digit()
{
    let (key, value) = ("a", "-1.2");

    let kvp = JSON::new("{'a' : -1.2}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_single_digit_point_multiple_digits()
{
    let (key, value) = ("a", "1.23456");

    let kvp = JSON::new("{'a' : 1.23456}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_single_digit_point_multiple_digits()
{
    let (key, value) = ("a", "-1.23456");

    let kvp = JSON::new("{'a' : -1.23456}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_multiple_digits_point_zero()
{
    let (key, value) = ("a", "12345.0");

    let kvp = JSON::new("{'a' : 12345.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_multiple_digits_point_zero()
{
    let (key, value) = ("a", "-12345.0");

    let kvp = JSON::new("{'a' : -12345.0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_multiple_digits_point_single_digit()
{
    let (key, value) = ("a", "12345.6");

    let kvp = JSON::new("{'a' : 12345.6}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_multiple_digits_point_single_digit()
{
    let (key, value) = ("a", "-12345.6");

    let kvp = JSON::new("{'a' : -12345.6}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_multiple_digits_point_multiple_digits()
{
    let (key, value) = ("a", "12345.67890");

    let kvp = JSON::new("{'a' : 12345.67890}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_multiple_digits_point_multiple_digits()
{
    let (key, value) = ("a", "-12345.67890");

    let kvp = JSON::new("{'a' : -12345.67890}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_point_zero_letter()
{
    let kvp = JSON::new("{'a' : 0.0f}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_minus_number_one_point_minus_zero()
{
    let kvp = JSON::new("{'a' : -1.-0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_point_minus_zero()
{
    let kvp = JSON::new("{'a' : -1.-0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_zero_point()
{
    let kvp = JSON::new("{'a' : 0.}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_point_zero()
{
    let kvp = JSON::new("{'a' : .0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}
