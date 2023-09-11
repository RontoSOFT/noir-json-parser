use crate::utils;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";

    let result = utils::getValueBytes(json.as_bytes(), 24);    // ":"

    assert(result.valid == true);
    assert(result.bytes == [0x33, 0x30]);
}

#[test]
fn IndexIsTolerable_ReturnsExpectedValue()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";

    let result = utils::getValueBytes(json.as_bytes(), 23);    // "'"

    assert(result.valid == true);
    assert(result.bytes == [0x33, 0x30]);
}

#[test]
fn IndexIsInvalid_ReturnsInvalidValue()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let json_bytes = json.as_bytes();

    let results =
    [
        utils::getValueBytes(json_bytes, 27),  // "0"
        utils::getValueBytes(json_bytes, 26),  // "3"
        utils::getValueBytes(json_bytes, 22),  // "e"
        utils::getValueBytes(json_bytes, 21),  // "g"
    ];

    for result in results
    {
        assert(result.valid == false);
        assert(result.bytes == [-1, -1]);
    }
}
