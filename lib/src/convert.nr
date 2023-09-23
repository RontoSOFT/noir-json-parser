use crate::globals;

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

type BytesBool = StringBytes<globals::BOOL_CHAR_SIZE>;
type BytesU8   = StringBytes<globals::U8_CHAR_SIZE>;
type BytesU16  = StringBytes<globals::U16_CHAR_SIZE>;
type BytesU32  = StringBytes<globals::U32_CHAR_SIZE>;
type BytesU64  = StringBytes<globals::U64_CHAR_SIZE>;

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

    fn transformASCIIDigits(self) -> Self
    {
        let mut copy = self;
        let mut reached_end = false;

        for i in 0..N
        {
            if (copy.valid & !reached_end)
            {
                if ((copy.bytes[i] > 0x2f) & (copy.bytes[i] < 0x3a)) { copy.bytes[i] -= 0x30; } // convert ASCII to digit as integer
                else
                {
                    copy.valid = (copy.bytes[i] == globals::BYTE_NULL);

                    if (copy.valid)
                    {
                        for j in (i + 1)..N { copy.valid &= (copy.bytes[j] == globals::BYTE_NULL); }
                        reached_end = true;
                    }
                }
            }
        }

        copy.valid &= (copy.bytes[0] != globals::BYTE_NULL); // ensure at least one digit is valid

        copy
    }

    fn asField(self) -> PropertyValue<Field>
    {
        let mut value    : Field = 0;
        let mut exponent : Field = 1;
        let mut valid = true;

        for i in 0..N
        {
            if (valid)
            {
                let index : Field = (N - 1 - i); // walking property value bytes in reverse
                if ((self.bytes[index] > 0x2f) & (self.bytes[index] < 0x3a))
                {
                    value += ((self.bytes[index] - 0x30) as Field) * exponent; // convert ASCII to digit number
                    exponent *= 10;
                }
                else
                {
                    valid = ((value == 0) & (self.bytes[index] == globals::BYTE_NULL));
                    if (!valid) { value = 0; }
                }
            }
        }

        valid &= (self.bytes[0] != globals::BYTE_NULL); // ensure at least one digit is valid

        PropertyValue { valid, value }
    }

    fn asBool(self) -> PropertyValue<bool>
    {
        let compare_array = |other: [u8; globals::BOOL_CHAR_SIZE]| -> bool
        {
            let mut is_equal = (N == globals::BOOL_CHAR_SIZE);

            if (is_equal) { for i in 0..globals::BOOL_CHAR_SIZE { is_equal &= (self.bytes[i] == other[i]); } }

            is_equal
        };

        let valid = (compare_array(globals::TRUE_ARRAY) | compare_array(globals::ONE_ARRAY) | compare_array(globals::FALSE_ARRAY) | compare_array(globals::ZERO_ARRAY));
        let value = (valid & (self.bytes[0] == globals::TRUE_ARRAY[0]) | (self.bytes[0] == globals::ONE_ARRAY[0]));

        PropertyValue{valid, value}
    }
}
