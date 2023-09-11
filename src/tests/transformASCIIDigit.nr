use crate::utils;
use crate::globals;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    assert( utils::transformASCIIDigit(-1) == globals::DIGIT_NULL );
    assert( utils::transformASCIIDigit(0x30) == 0 );
    assert( utils::transformASCIIDigit(0x31) == 1 );
    assert( utils::transformASCIIDigit(0x32) == 2 );
    assert( utils::transformASCIIDigit(0x33) == 3 );
    assert( utils::transformASCIIDigit(0x34) == 4 );
    assert( utils::transformASCIIDigit(0x35) == 5 );
    assert( utils::transformASCIIDigit(0x36) == 6 );
    assert( utils::transformASCIIDigit(0x37) == 7 );
    assert( utils::transformASCIIDigit(0x38) == 8 );
    assert( utils::transformASCIIDigit(0x39) == 9 );
    assert( utils::transformASCIIDigit(0x3A) == 10 );
}
