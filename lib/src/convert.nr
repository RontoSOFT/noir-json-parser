use crate::globals;
use crate::utils;

struct StringBytes<N>
{
    valid: bool,
    bytes: [Field;N]
}

struct PropertyValue<T>
{
    valid: bool,
    value: T
}

impl<N> StringBytes<N>
{
    fn new_valid(bytes: [Field;N]) -> Self
    {
        StringBytes { valid: true, bytes }
    }

    fn new_invalid(bytes: [Field;N]) -> Self
    {
        StringBytes { valid: false, bytes }
    }
}

impl StringBytes<globals::U32_CHAR_SIZE>
{
    fn asU32(mut self) -> PropertyValue<u32>
    {
        for i in 0..globals::U32_CHAR_SIZE
        {
            if (self.valid)
            {
                self.bytes[i] = utils::transformASCIIDigit(self.bytes[i]);
                self.valid &= utils::validateDigit(self.bytes[i] as u8);
            }
        }

        let mut value : Field = 0;
        if (self.valid)
        {
            let mut exponent : Field = 1;

            for i in 0..globals::U32_CHAR_SIZE
            {
                let index : Field = (globals::U32_CHAR_SIZE - i - 1);   // walking property value bytes in reverse
                if (self.bytes[index] != globals::DIGIT_NULL)           // skip 'null' digits
                {
                    value += (self.bytes[index] * exponent);
                    exponent *= 10;
                }
            }
        }

        PropertyValue { valid: self.valid, value: value as u32 }
    }
}
