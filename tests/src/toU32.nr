use dep::noir_json_parser::globals;
use dep::noir_json_parser::converters;

#[test]
fn ValidInputs_ReturnsExpectedValue()
{
    let bytes : [Field; globals::U32_CHAR_SIZE] = [4, 2, 9, 3, 8, 6, 7, 5, 1, 0];
    assert( converters::toU32(bytes) == 4293867510 );
}

#[test]
fn ValueLargerThanMaxU32_ReturnsOverflowedValue()
{
    let bytes : [Field; globals::U32_CHAR_SIZE] = [4, 2, 9, 4, 9, 6, 7, 2, 9, 6];
    assert( converters::toU32(bytes) == 0 );
}
