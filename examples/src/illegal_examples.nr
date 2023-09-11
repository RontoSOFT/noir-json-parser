// EXAMPLE 1:

let json = "{'name':'John Doe','age':\"30\",'isEmployed':true}";     // \" is not allowed

// .. //


// EXAMPLE 2:
use dep::noir;

#[test]
fn test_crash()
{
    let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let json_bytes = json.as_bytes();
    let expected = noir::convert::StringBytes { valid: true, bytes: [0x33, 0x30]};

    assert(noir::convert::bytesOf(json_bytes, 24) == expected);    // Unsupported types for comparison: StringBytes<2> and StringBytes<_>
}

// .. //
