use crate::globals;

//
// Converts a byte array to u32
//
// @returns An unsigned 32-bit integer representing the converted value
//
fn toU32(bytes : [Field; globals::U32_CHAR_SIZE]) -> u32
{
    let mut value : Field = 0;
    let mut exponent : Field = 1;

    for i in 0..globals::U32_CHAR_SIZE
    {
        let index : Field = (globals::U32_CHAR_SIZE - i - 1);   // walking property value bytes in reverse
        if (bytes[index] != globals::DIGIT_NULL)                // skip 'null' digits
        {
            value += (bytes[index] * exponent);
            exponent *= 10;
        }
    }

    value as u32
}
