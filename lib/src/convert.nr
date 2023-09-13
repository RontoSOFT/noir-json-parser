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

/* struct DummyStruct<T>
{
    valid: bool,
    value: T,
    anotherValue: T
} */

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

    fn validateCharacterAt(self, index: Field) -> bool{

        let mut byteValue = self.bytes[index];
        let mut isValid = false;

        isValid |= byteValue == 0x74; // t

        isValid |= byteValue == 0x72; // r

        isValid |= byteValue == 0x75; // u

        isValid |= byteValue == 0x65; // e

        isValid |= byteValue == 0x66; // f

        isValid |= byteValue == 0x61; // a

        isValid |= byteValue == 0x6C; // l

        isValid |= byteValue == 0x73; // s

        isValid
    }

    /* {
        let mut byteValue = self.bytes[index];

        if (byteValue != globals::BYTE_NULL)
        {
            byteValue -= 0x30; // convert ASCII to digit as integer

            if ((byteValue as u8) > 9) { byteValue = globals::BYTE_NULL; } // clamp
        }

        byteValue
    } */

    
    fn asBool(self) -> PropertyValue<bool>
    {
        
        let mut hasValidCharacters = true;
        let mut isValid = false;
        let mut returnValue = false;
        
        for i in 0..N{
            if(self.bytes[i] != 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000000 ){ // TODO: This will fail when all the strings are empty
                hasValidCharacters &= self.validateCharacterAt(i);
            }
        }

        
        if(hasValidCharacters){
            let mut sumOfValue: u64 = 0;
            let mut exponent : u64 = 1;

            for i in 0..N
            {
                let index : Field = (N - 1 - i); // walking property value bytes in reverse
                if (self.bytes[index] != globals::BYTE_NULL) // skip 'nulls'
                {
                    sumOfValue += (self.bytes[index] as u64 * exponent);
                    exponent *= 10;
                }
            }
           
            // true ->
                // t-> 74 -> 74*1000
                // r-> 72 -> 7200 
            if(sumOfValue==128671){ // Representation of true in decimal by using ASCII values
                isValid = true;
                returnValue = true;
            }else if(sumOfValue==1129051){ // Representation of false in decimal by using ASCII values
                isValid = true;
                returnValue = false;
            }
        }

        
        let mut numeric_value_associated = self.asField();

        if (numeric_value_associated.valid){
            returnValue = (numeric_value_associated.value as u32 > 0);
            isValid = true;
        }
        
        PropertyValue { valid: isValid, value: returnValue }
    }
}
