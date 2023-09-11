use crate::utils;
use crate::globals;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    assert( !utils::validateASCIDigit(-1) );

    assert( utils::validateASCIDigit(0) );
    assert( utils::validateASCIDigit(1) );
    assert( utils::validateASCIDigit(2) );
    assert( utils::validateASCIDigit(3) );
    assert( utils::validateASCIDigit(4) );
    assert( utils::validateASCIDigit(5) );
    assert( utils::validateASCIDigit(6) );
    assert( utils::validateASCIDigit(7) );
    assert( utils::validateASCIDigit(8) );
    assert( utils::validateASCIDigit(9) );
    assert( utils::validateASCIDigit(globals::DIGIT_NULL as u8) );

    assert( !utils::validateASCIDigit(11) );
}
