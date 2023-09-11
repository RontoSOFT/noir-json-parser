use crate::globals;
use crate::utils;
use crate::converters;

//
// Parses characters from input JSON string corresponding to property's value (expected type: u32)
//
// @returns A PropertyValue<u32> instance representing the converted value and its validity
//
unconstrained fn getValue<JSON_SIZE, PROP_NAME_SIZE>(aJSONString : str<JSON_SIZE>, aPropName : str<PROP_NAME_SIZE>) -> utils::PropertyValue<u32>
{
    let json_bytes = aJSONString.as_bytes();
    let prop_name_bytes = aPropName.as_bytes();

    // dep::std::println("");
    // dep::std::println(json_bytes);
    // dep::std::println("");

    let index = utils::findProperty(json_bytes, prop_name_bytes);
    let mut value_bytes = utils::getValueBytes(json_bytes, (index + PROP_NAME_SIZE));//, utils::transformASCIIDigit, utils::validateASCIDigit);

    for i in 0..value_bytes.bytes.len()
    {
        if (value_bytes.valid)
        {
            value_bytes.bytes[i] = utils::transformASCIIDigit(value_bytes.bytes[i]);
            value_bytes.valid &= utils::validateASCIDigit(value_bytes.bytes[i] as u8);
        }
    }

    let mut value : u32 = 0;
    if (value_bytes.valid) { value = converters::U32::from(value_bytes.bytes); }

    utils::PropertyValue { valid: value_bytes.valid, value: value }
}
