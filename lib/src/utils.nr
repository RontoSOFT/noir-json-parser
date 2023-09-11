use crate::globals;

fn transformASCIIDigit(mut byteValue : Field) -> Field
{
    if (byteValue != -1) { byteValue -= 0x30; } // convert ASCII to digit as integer
    else                 { byteValue = globals::DIGIT_NULL; }

    byteValue
}

fn validateDigit(byteValue : u8) -> bool
{
    // see crash example 1
    (byteValue <= (globals::DIGIT_NULL as u8))
}
