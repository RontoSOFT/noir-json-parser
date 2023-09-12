use dep::noir::globals;
use dep::noir::convert;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, 0x36, 0x37, 0x35, 0x31, 0x30]);
    let result = bytes.transformASCIIDigits();

    assert( result.valid & (result.bytes == [4, 2, 9, 3, 8, 6, 7, 5, 1, 0]) );
}

#[test]
fn ValidInputsStringBytesWithNulls_ReturnsExpectedValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL]);
    let result = bytes.transformASCIIDigits();

    assert( result.valid & (result.bytes == [4, 2, 9, 3, 8, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL]) );
}

#[test]
fn StringBytesContainNullBetweenNonNullElements_ReturnsInvalidValue()
{
    let bytes = convert::StringBytes::new_valid([0x34, 0x32, globals::BYTE_NULL, 0x33, 0x38, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL]);
    let result = bytes.transformASCIIDigits();

    assert( !result.valid );
}
