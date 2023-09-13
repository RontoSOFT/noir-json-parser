use dep::noir::globals::BYTE_NULL;
use dep::noir::convert::StringBytes;

#[test]
fn ValidInput_ReturnsExpectedValue()
{
    let bytes = StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, 0x36, 0x37, 0x35, 0x31, 0x30]);
    let result = bytes.transformASCIIDigits();

    assert( result.valid & (result.bytes == [4, 2, 9, 3, 8, 6, 7, 5, 1, 0]) );
}

#[test]
fn ValidInput_StringBytesWithNulls_ReturnsExpectedValue()
{
    let bytes = StringBytes::new_valid([0x34, 0x32, 0x39, 0x33, 0x38, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
    let result = bytes.transformASCIIDigits();

    assert( result.valid & (result.bytes == [4, 2, 9, 3, 8, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]) );
}

#[test]
fn StringBytesIsFlawed_StartingNullElement_ReturnsInvalidValue()
{
    let bytes = StringBytes::new_valid([BYTE_NULL, 0x34, 0x39, 0x36 ]);
    let result = bytes.asField();

    assert( !result.valid & (result.value == 0) );
}

#[test]
fn StringBytesIsFlawed_NullBetweenNonNullElements_ReturnsInvalid()
{
    let bytes = StringBytes::new_valid([0x34, 0x32, BYTE_NULL, 0x33, 0x38, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL, BYTE_NULL]);
    let result = bytes.transformASCIIDigits();

    assert( !result.valid );
}
