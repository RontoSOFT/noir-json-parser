use dep::noir::new_parse::JSON;

#[test]
fn property_literal_null()
{
    let (key, value) = ("a", "null");

    let kvp = JSON::new("{'a' : null}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_literal_true()
{
    let (key, value) = ("a", "true");

    let kvp = JSON::new("{'a' : true}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_literal_false()
{
    let (key, value) = ("a", "false");

    let kvp = JSON::new("{'a' : false}").get(key);

    assert(kvp.key == key.as_bytes());
    assert(kvp.value.bytes == value.as_bytes());
}

#[test]
fn property_literal_escaped()
{
    let kvp = JSON::new("{'a' : fals\e}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_literal_incomplete()
{
    let kvp = JSON::new("{'a' : fals}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn incproperty_literal_incomplete2()
{
    let kvp = JSON::new("{'a' : t}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn incproperty_literal_incomplete3()
{
    let kvp = JSON::new("{'a' : nul}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_literal_wrong()
{
    let kvp = JSON::new("{'a' : falst}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_literal_wrong2()
{
    let kvp = JSON::new("{'a' : nult}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}

#[test]
fn property_literal_wrong3()
{
    let kvp = JSON::new("{'a' : truf}").get("a");

    assert(kvp.key == [0; 1]);
    assert(kvp.value.bytes == [0; 1]);
}
