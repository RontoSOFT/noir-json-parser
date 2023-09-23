use crate::globals::BYTE_NULL;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;

use dep::std::option::Option;

global BOOL_CHAR_SIZE : Field =  5;  // max(bool)                      "false",  5 characters
global U8_CHAR_SIZE   : Field =  3;  // max(u8)                          "255",  3 characters
global U16_CHAR_SIZE  : Field =  5;  // max(u16)                      "65'535",  5 characters
global U32_CHAR_SIZE  : Field = 10;  // max(u32)               "4'294'967'295", 10 characters
global U64_CHAR_SIZE  : Field = 20;  // max(u64)  "18'446'744'073'709'551'616", 20 characters

type BytesBool = StringBytes<BOOL_CHAR_SIZE>;
type BytesU8   = StringBytes<U8_CHAR_SIZE>;
type BytesU16  = StringBytes<U16_CHAR_SIZE>;
type BytesU32  = StringBytes<U32_CHAR_SIZE>;
type BytesU64  = StringBytes<U64_CHAR_SIZE>;

struct StringBytes<N>
{
    valid: bool,
    bytes: [u8; N]
}

struct PropertyValue<T>
{
    valid: bool,
    value: T
}

impl<N> StringBytes<N>
{
    fn new_valid(bytes: [u8; N]) -> Self
    {
        StringBytes { valid: true, bytes }
    }

    fn new_invalid(bytes: [u8; N]) -> Self
    {
        StringBytes { valid: false, bytes }
    }

    fn asField(self) -> Option<Field>
    {
        let mut value    : Field = 0;
        let mut exponent : Field = 1;
        let mut valid = true;

        for i in 0..N
        {
            if (valid)
            {
                let index : Field = (N - 1 - i);                                // walking property value bytes in reverse
                if ((self.bytes[index] > 0x2f) & (self.bytes[index] < 0x3a))
                {
                    value += ((self.bytes[index] - 0x30) as Field) * exponent;  // convert ASCII byte to integer digit number
                    exponent *= 10;
                }
                else
                {
                    valid = ((value == 0) & (self.bytes[index] == BYTE_NULL));  // nulls accepted only at the end of array
                    if (!valid) { value = 0; }
                }
            }
        }

        valid &= (self.bytes[0] != BYTE_NULL);                                  // ensure at least one digit is valid

        if (valid) { Option::some(value) } else { Option::none() }
    }

    fn asBool(self) -> Option<bool>
    {
        let mut i : &mut Field = &mut -1;
        let equal_value = |a| { *i += 1; self.bytes[*i] == a };

        let mut valid = false;

        if ((N == 4) | ((N == 5) & (self.bytes[4] == BYTE_NULL)))
        {
            if      (self.bytes[0] == LITERALS_NULL[0]) { valid = LITERALS_NULL.all(equal_value); }
            else if (self.bytes[0] == LITERALS_TRUE[0]) { valid = LITERALS_TRUE.all(equal_value); }
        }
        else if (N == 5) { valid = LITERALS_FALSE.all(equal_value); }

        if (valid) { Option::some(self.bytes[0] == LITERALS_TRUE[0]) } else { Option::none() }
    }
}
