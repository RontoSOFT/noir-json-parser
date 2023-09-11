use crate::globals;
use crate::converters;

fn transformASCIIDigit(mut byteValue : Field) -> Field
{
    if (byteValue != -1) { byteValue -= 0x30; } // convert ASCII to digit as integer
    else                 { byteValue = globals::DIGIT_NULL; }

    byteValue
}

fn validateASCIDigit(byteValue : Field) -> bool
{
    // TODO: Should work as u4??
    // see crash example 1
    ((byteValue as u32) <= (globals::DIGIT_NULL_))
}
