use dep::noir_json_parser::parsing;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let prop_name = "age";

    let result = parsing::getValueBytes(json, prop_name);    // ":"

    assert(result.valid == true);
    assert(result.bytes == [0x33, 0x30]);
}
