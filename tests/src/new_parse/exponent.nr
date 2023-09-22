use dep::noir::new_parse::JSON;

#[test]
fn property_number_zero_e_zero()
{
    let (key, value) = ("a", "0e0");
    let kvp = JSON::new("{'a' : 0e0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_E_zero()
{
    let (key, value) = ("a", "0E0");
    let kvp = JSON::new("{'a' : 0E0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_e_plus_zero()
{
    let (key, value) = ("a", "0e+0");
    let kvp = JSON::new("{'a' : 0e+0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_e_minus_zero()
{
    let (key, value) = ("a", "0e-0");
    let kvp = JSON::new("{'a' : 0e-0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_zero_e_minus_zero()
{
    let (key, value) = ("a", "-0e-0");
    let kvp = JSON::new("{'a' : -0e-0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_zero_e_plus_zero()
{
    let (key, value) = ("a", "-0e+0");
    let kvp = JSON::new("{'a' : -0e+0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_plus_zero_e_plus_zero()
{
    let kvp = JSON::new("{'a' : +0e+0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_plus_zero_e_minus_zero()
{
    let kvp = JSON::new("{'a' : +0e-0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_plus_zero_point_zero_e_plus_zero()
{
    let kvp = JSON::new("{'a' : +0.0e+0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_plus_zero_point_zero_e_minus_zero()
{
    let kvp = JSON::new("{'a' : +0.0e-0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_zero_point_zero_e_zero_plus_zero()
{
    let (key, value) = ("a", "0.0e+0");
    let kvp = JSON::new("{'a' : 0.0e+0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_point_zero_e_zero_minus_zero()
{
    let (key, value) = ("a", "0.0e-0");
    let kvp = JSON::new("{'a' : 0.0e-0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_zero_point_zero_e_zero_minus_zero()
{
    let (key, value) = ("a", "-0.0e-0");
    let kvp = JSON::new("{'a' : -0.0e-0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_minus_zero_point_zero_e_zero_plus_zero()
{
    let (key, value) = ("a", "-0.0e+0");
    let kvp = JSON::new("{'a' : -0.0e+0}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_number_zero_point_zero_e_letter()
{
    let kvp = JSON::new("{'a' : 0.0ef}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_zero_point_zero_e_escaped_zero()
{
    let kvp = JSON::new("{'a' : 0.0e\0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_escaped_zero_point_zero_e_zero()
{
    let kvp = JSON::new("{'a' : \0.0e0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_zero_point_zero_escaped_e_zero()
{
    let kvp = JSON::new("{'a' : 0.0\e0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_zero_plus_zero_e_zero()
{
    let kvp = JSON::new("{'a' : 0+e0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_zero_plus_zero_E_zero()
{
    let kvp = JSON::new("{'a' : 0+E0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_minus_zero_e_minus_minus_zero()
{
    let kvp = JSON::new("{'a' : -0e--0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_zero_point_zero_e_zero_plus_plus_zero()
{
    let kvp = JSON::new("{'a' : 0.0e++0}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_e()
{
    let kvp = JSON::new("{'a' : 1e}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_e_minus()
{
    let kvp = JSON::new("{'a' : 1e-}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_e_plus()
{
    let kvp = JSON::new("{'a' : 1e+}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_point_e()
{
    let kvp = JSON::new("{'a' : 1.e}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_point_e_minus()
{
    let kvp = JSON::new("{'a' : 1.e-}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_point_e_plus()
{
    let kvp = JSON::new("{'a' : 1.e+}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}


#[test]
fn property_number_one_point_zero_e()
{
    let kvp = JSON::new("{'a' : 1.0e}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_point_zero_e_minus()
{
    let kvp = JSON::new("{'a' : 1.0e-}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_one_point_zero_e_plus()
{
    let kvp = JSON::new("{'a' : 1.0e+}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_minus_one_point_zero_e_plus()
{
    let kvp = JSON::new("{'a' : -1.0e+}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_number_minus_one_point_zero_e_minus()
{
    let kvp = JSON::new("{'a' : -1.0e-}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}
