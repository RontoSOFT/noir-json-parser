use dep::noir::globals;
use dep::noir::utils;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    assert( !utils::validateDigit(-1) );
    assert( !utils::validateDigit(11) );

    assert( utils::validateDigit(0) );
    assert( utils::validateDigit(1) );
    assert( utils::validateDigit(2) );
    assert( utils::validateDigit(3) );
    assert( utils::validateDigit(4) );
    assert( utils::validateDigit(5) );
    assert( utils::validateDigit(6) );
    assert( utils::validateDigit(7) );
    assert( utils::validateDigit(8) );
    assert( utils::validateDigit(9) );
    assert( utils::validateDigit(globals::DIGIT_NULL as u8) );
}
