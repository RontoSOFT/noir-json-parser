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
        let mut is_null_found = false;

        for i in 0..N
        {
            if (copy.valid)
            {
                copy.bytes[i] -= 0x30; // convert ASCII to digit as integer
                if (copy.bytes[i] > 9) // clamp
                {
                    copy.bytes[i] = globals::BYTE_NULL;
                    is_null_found = true;
                }

                if (is_null_found) { copy.valid &= (copy.bytes[i] == globals::BYTE_NULL); } // ensure bytes following the first null are also null
            }
        }

        copy.valid &= (copy.bytes[0] != globals::BYTE_NULL); // ensure at least one digit is valid

        copy
    }

    fn asField(self) -> PropertyValue<Field>
    {
        let copy = self.transformASCIIDigits();

        let mut value : Field = 0;

        if (copy.valid)
        {
            let mut exponent : Field = 1;

            for i in 0..N
            {
                let index : Field = (N - 1 - i); // walking property value bytes in reverse
                if (copy.bytes[index] != globals::BYTE_NULL) // skip 'nulls'
                {
                    value += ((copy.bytes[index] as Field) * exponent);
                    exponent *= 10;
                }
            }
        }

        PropertyValue { valid: copy.valid, value }
    }

    fn asBool(self) -> PropertyValue<bool>
    {
        let compare_array = |other: [Field; globals::BOOL_CHAR_SIZE]| -> bool
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
