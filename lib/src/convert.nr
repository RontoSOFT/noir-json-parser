use crate::globals;

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

type BytesBool = StringBytes<globals::BOOL_CHAR_SIZE>;
type BytesU8   = StringBytes<globals::U8_CHAR_SIZE>;
type BytesU16  = StringBytes<globals::U16_CHAR_SIZE>;
type BytesU32  = StringBytes<globals::U32_CHAR_SIZE>;
type BytesU64  = StringBytes<globals::U64_CHAR_SIZE>;

impl<N> StringBytes<N>
{
    fn new_valid(bytes: [Field; N]) -> Self
    {
        StringBytes { valid: true, bytes }
    }

    fn new_invalid(bytes: [Field; N]) -> Self
    {
        StringBytes { valid: false, bytes }
    }

    fn transformASCIIDigitAt(self, index : Field) -> Field
    {
        let mut byteValue = self.bytes[index];

        if (byteValue != globals::BYTE_NULL)
        {
            byteValue -= 0x30; // convert ASCII to digit as integer

            if ((byteValue as u8) > 9) { byteValue = globals::BYTE_NULL; } // clamp
        }

        byteValue
    }

    fn transformASCIIDigits(self) -> Self
    {
        let mut copy = self;
        let mut is_null_found = false;

        for i in 0..N
        {
            if (copy.valid)
            {
                copy.bytes[i] = copy.transformASCIIDigitAt(i);

                if (is_null_found)               { copy.valid   &= (copy.bytes[i] == globals::BYTE_NULL); }
                if (copy.valid & !is_null_found) { is_null_found = (copy.bytes[i] == globals::BYTE_NULL); }
            }
        }

        copy.valid &= (copy.bytes[0] != globals::BYTE_NULL); // make sure there's at least one valid digit

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
                    value += (copy.bytes[index] * exponent);
                    exponent *= 10;
                }
            }
        }

        PropertyValue { valid: copy.valid, value }
    }

    fn compareTwoArrays(self, another_array: [Field;5])->bool{

        

        let mut duplicate_of_array : [Field;5] = [0;5];
        for i in 0..globals::BOOL_CHAR_SIZE{
            duplicate_of_array[i] = self.bytes[i];
        }

        let mut return_boolean = true;

        for i in 0..globals::BOOL_CHAR_SIZE{
            return_boolean &= (duplicate_of_array[i] == another_array[i]);
        }
        return_boolean
    }
    fn asBool(self) -> PropertyValue<bool>{

        let mut isValid = false;
        let mut value = false;

        
        let true_array = [globals::SMALL_t , globals::SMALL_r, globals::SMALL_u, globals::SMALL_e, globals::BYTE_NULL];
        
        let one_array = [globals::ONE , globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL];
        
        let false_array = [globals::SMALL_f, globals::SMALL_a, globals::SMALL_l, globals::SMALL_s, globals::SMALL_e];
        
        let zero_array = [globals::ZERO, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL, globals::BYTE_NULL];
        
        if(self.compareTwoArrays(true_array) | self.compareTwoArrays(one_array)  ){
            isValid = true;
            value = true;
        }else if(self.compareTwoArrays(false_array)  | self.compareTwoArrays(zero_array)){
            isValid = true;
            value = false;
        }
        
        PropertyValue { valid: isValid, value }
    }
}
