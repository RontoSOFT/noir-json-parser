use dep::std::option::Option;

use crate::JSON;

use crate::globals::BYTE_NULL;
use crate::globals::PLUS;
use crate::globals::MINUS;
use crate::globals::DECIMAL_POINT;
use crate::globals::eE;
use crate::globals::LITERALS_NULL;
use crate::globals::LITERALS_TRUE;
use crate::globals::LITERALS_FALSE;

use crate::utils::slice_eq_array;

fn check_four_bytes(bytes: [u8]) -> bool
{
    let mut result = false;

    let first = bytes[0];
    if      (first == LITERALS_TRUE[0]) { result = slice_eq_array(bytes, LITERALS_TRUE); }
    else if (first == LITERALS_NULL[0]) { result = slice_eq_array(bytes, LITERALS_NULL); }

    result
}

unconstrained
pub fn asBool(bytes: [u8]) -> Option<bool>
{
    let N = bytes.len();
    let mut valid = false;
    if      (N == 4) { valid = check_four_bytes(bytes); }
    else if (N == 5)
    {
        if (bytes[4] == BYTE_NULL) { valid = check_four_bytes(bytes.pop_back().0); }
        else                       { valid = slice_eq_array(bytes, LITERALS_FALSE); }
    }

    if (valid) { Option::some(bytes[0] == LITERALS_TRUE[0]) } else { Option::none() }
}

fn getWholeNumber(bytes: [u8]) -> Field
{
    let N = bytes.len() as u64;
    let mut value : Field = 0;
    let mut units : Field = 1;
    let mut it = N;
    for _ in 0..N
    {
        it -= 1;
        let byte = bytes[it];                      // walking property value bytes in reverse
        value += ((byte - 0x30) as Field) * units; // convert ASCII byte to integer digit number
        units *= 10;
    }

    value
}

fn getExponent(bytes: [u8]) -> Field
{
    let first = bytes[0];
    let has_minus = (first == MINUS);
    let has_plus = (first == PLUS);

    let mut exponent = getWholeNumber( if (has_minus | has_plus) { bytes.remove(0).0 } else { bytes } );
    exponent = 10.pow_32(exponent);
    if (has_minus) { exponent = (1 / exponent); }

    exponent
}

unconstrained
pub fn asField(bytes: [u8]) -> Option<Field>
{
    let mut result = Option::none();
    let N = bytes.len() as u64;

    let first = bytes[0];
    let mut valid = (N < 78) & (N != 0) & // ensure at least one digit is valid
    if (N == 1) { (first != BYTE_NULL) & (first != MINUS) & (first != PLUS) }
    else        { ((first != BYTE_NULL) & (first != PLUS)) | ((first == MINUS) & (bytes[1] != BYTE_NULL) & (bytes[1] != PLUS)) };

    if (valid)
    {
        let has_minus = (first == MINUS);

        let mut checked_nulls = false;
        let mut has_exponent = false;

        let mut bytes_value : [u8] = [];
        let mut bytes_exponent : [u8] = [];
        let mut bytes_ref : &mut [u8] = &mut bytes_value;

        for i in (has_minus as u64)..N // if minus is present, start at index 1
        {
            if (valid & !checked_nulls)
            {
                let byte = bytes[i];

                if      (((byte >= 0x30) & (byte <= 0x39)) | (byte == MINUS) | (byte == PLUS)) { *bytes_ref = bytes_ref.push_back(byte); }
                else if (eE.any(|e| byte == e))
                {
                    bytes_ref = &mut bytes_exponent;
                    valid = !has_exponent;
                    has_exponent = (valid & !has_exponent);
                }
                else
                {
                    checked_nulls = true;
                    for j in i..N { valid &= (bytes[j] == BYTE_NULL); } // (contiguous) nulls accepted only at the end of array
                }
            }
        }

        if (valid)
        {
            let mut value = getWholeNumber(bytes_value);

            if (has_minus)    { value = -value; }
            if (has_exponent) { value *= getExponent(bytes_exponent); }

            result = Option::some(value);
        }
    }

    result
}

unconstrained
pub fn asFloat(bytes: [u8]) -> (Option<Field>, Option<Field>)
{
    // let mut result = Option::none();
    let N = bytes.len() as u64;

    // split bytes from decimal point to e/null/end, if any, from the other bytes
    let mut bytes_whole : [u8] = [];
    let mut bytes_fraction : [u8] = [];
    let mut bytes_ref : &mut [u8] = &mut bytes_whole;

    for i in 0..N
    {
        let byte = bytes[i];

        if (byte == DECIMAL_POINT) { bytes_ref = &mut bytes_fraction; }
        else
        {
            if (eE.any(|e| byte == e)) { bytes_ref = &mut bytes_whole; }

            { *bytes_ref = bytes_ref.push_back(byte); }
        }
    }

    let whole = asField(bytes_whole).unwrap_unchecked();
    let fraction = getWholeNumber(bytes_fraction);

    dep::std::println(whole);
    dep::std::println(fraction);

    let tup : (Option<Field>, Option<Field>) = (Option::some(whole), Option::some(fraction));
    tup
}

impl JSON
{
    // linear search of json keys to return an Option slice of the key's value bytes
    unconstrained
    pub fn bytesOf<KEY_SIZE>(self, key : str<KEY_SIZE>) -> Option<[u8]>
    {
        let mut result : Option<[u8]> = Option::none();

        let key_bytes = key.as_bytes();

        let mut found = false;
        for kvp in self.doc
        {
            found = (kvp.key.len() == KEY_SIZE);
            if (found)
            {
                for i in 0..KEY_SIZE { found &= (key_bytes[i] == kvp.key[i]); }
                if (found) { result = Option::some(kvp.value); }
            }
        }

        result
    }

    unconstrained
    pub fn getBool<N>(self, key : str<N>) -> Option<bool>
    {
        let bytes = self.bytesOf(key);

        if (bytes.is_some()) { asBool(bytes.unwrap_unchecked()) } else { Option::none() }
    }

    unconstrained
    pub fn getInteger<N>(self, key : str<N>) -> Option<i54>
    {
        let mut result : Option<i54> = Option::none();

        let bytes = self.bytesOf(key);

        if (bytes.is_some())
        {
            let bytes : [u8] = bytes.unwrap_unchecked();
            let value = asField(bytes);
            if (value.is_some())
            {
                let value_field = value.unwrap_unchecked();
                let value_i54 = if (bytes[0] == MINUS) { -((-value_field) as i54) } else { value_field as i54 };

                result = Option::some(value_i54);
            }
        }

        result
    }
}
