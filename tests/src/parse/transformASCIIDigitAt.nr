use dep::noir::globals;
use dep::noir::convert;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let transformSingleDigit = |x| convert::StringBytes::new_valid([x]).transformASCIIDigitAt(0);

    assert( transformSingleDigit(-1) == globals::BYTE_NULL );

    assert( transformSingleDigit(0) == globals::BYTE_NULL );
    assert( transformSingleDigit(1) == globals::BYTE_NULL );
    assert( transformSingleDigit(2) == globals::BYTE_NULL );
    assert( transformSingleDigit(3) == globals::BYTE_NULL );
    assert( transformSingleDigit(4) == globals::BYTE_NULL );
    assert( transformSingleDigit(5) == globals::BYTE_NULL );
    assert( transformSingleDigit(6) == globals::BYTE_NULL );
    assert( transformSingleDigit(7) == globals::BYTE_NULL );
    assert( transformSingleDigit(8) == globals::BYTE_NULL );
    assert( transformSingleDigit(9) == globals::BYTE_NULL );
    assert( transformSingleDigit(10) == globals::BYTE_NULL );

    assert( transformSingleDigit(0x30) == 0 );
    assert( transformSingleDigit(0x31) == 1 );
    assert( transformSingleDigit(0x32) == 2 );
    assert( transformSingleDigit(0x33) == 3 );
    assert( transformSingleDigit(0x34) == 4 );
    assert( transformSingleDigit(0x35) == 5 );
    assert( transformSingleDigit(0x36) == 6 );
    assert( transformSingleDigit(0x37) == 7 );
    assert( transformSingleDigit(0x38) == 8 );
    assert( transformSingleDigit(0x39) == 9 );

    assert( transformSingleDigit(0x3A) == globals::BYTE_NULL );
}
