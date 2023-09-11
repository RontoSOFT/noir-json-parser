// EXAMPLE 1:

let json = "{'name':'John Doe','age':\"30\",'isEmployed':true}";     // \" is not allowed

// .. //


// EXAMPLE 2:
use dep::noir_json_parser;

#[test]
fn test_crash()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let json_bytes = json.as_bytes();
    let expected = noir_json_parser::parsing::ValueBytes { valid: true, bytes: [0x33, 0x30]};

    assert(noir_json_parser::parsing::getValueU32(json_bytes, 24) == expected);    // Unsupported types for comparison: ValueBytes<2> and ValueBytes<_>
}

// .. //
