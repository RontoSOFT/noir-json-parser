use crate::converters;
use crate::globals;
use crate::utils;

struct ValueBytes<N>
{
    valid: bool,
    bytes: [Field;N]
}

struct PropertyValue<T>
{
    valid: bool,
    value: T
}

//
// Searches for property name in input JSON
//
// @returns A Field value indicating the starting index where the value is found
//
/*unconstrained*/ fn findProperty<JSON_SIZE, PROP_NAME_SIZE>(jsonBytes : [u8; JSON_SIZE], propNameBytes : [u8; PROP_NAME_SIZE]) -> Field
{
    let mut index : Field = -1;

    for i in 0..JSON_SIZE
    {
        if (index == -1)
        {
            let mut is_property_found = (PROP_NAME_SIZE != 0);

            for j in 0..PROP_NAME_SIZE
            {
                is_property_found &= (jsonBytes[j + i] == propNameBytes[j]);
            }

            if (is_property_found)
            {
                let mut j = 0;
                let mut is_left_OK = true;
                let mut is_right_OK = true;

                let mut is_colon_found = false;
                let mut is_single_quoted = false;
                let mut is_double_quoted = false;

                j = i - 1;

                if (i != 0)
                {
                    is_left_OK  = (jsonBytes[j] == globals::COMMA);
                    is_left_OK |= (jsonBytes[j] == globals::SPACE);
                    is_left_OK |= (jsonBytes[j] == globals::LEFT_BRACE);
                    is_left_OK |= (jsonBytes[j] == globals::RIGHT_BRACE);
                    is_left_OK |= (jsonBytes[j] == globals::SINGLE_QUOTE);
                    is_left_OK |= (jsonBytes[j] == globals::DOUBLE_QUOTE);

                    // if ((jsonBytes[j] == globals::SPACE))
                    // {
                    //     for k in 0..j
                    //     {
                    //         if (is_left_OK)
                    //         {
                    //             if (!is_colon_found)   { is_colon_found  = (jsonBytes[k] == globals::COLON); }

                    //             if (!is_single_quoted)
                    //             {
                    //                 if (is_colon_found) { is_left_OK = false; }
                    //                 else                { is_single_quoted = (jsonBytes[k] == globals::SINGLE_QUOTE); }
                    //             }

                    //             if (!is_double_quoted)
                    //             {
                    //                 if (is_colon_found) { is_left_OK = false; }
                    //                 else                { is_double_quoted = (jsonBytes[k] == globals::DOUBLE_QUOTE); }
                    //             }
                    //         }
                    //     }
                    // }
                }

                j += PROP_NAME_SIZE + 1;

                if ((j - JSON_SIZE) != 1)
                {
                    is_right_OK  = (jsonBytes[j] == globals::COLON);
                    is_right_OK |= (jsonBytes[j] == globals::SPACE);
                    is_right_OK |= (jsonBytes[j] == globals::LEFT_BRACE);
                    is_right_OK |= (jsonBytes[j] == globals::RIGHT_BRACE);
                    is_right_OK |= (jsonBytes[j] == globals::SINGLE_QUOTE);
                    is_right_OK |= (jsonBytes[j] == globals::DOUBLE_QUOTE);

                    if ((jsonBytes[j] == globals::SPACE))
                    {
                        for k in j..JSON_SIZE
                        {
                            if (is_right_OK)
                            {
                                if (!is_colon_found)   { is_colon_found  = (jsonBytes[k] == globals::COLON); }

                                if (!is_single_quoted)
                                {
                                    if (is_colon_found) { is_right_OK = false; }
                                    else                { is_single_quoted = (jsonBytes[k] == globals::SINGLE_QUOTE); }
                                }

                                if (!is_double_quoted)
                                {
                                    if (is_colon_found) { is_right_OK = false; }
                                    else                { is_double_quoted = (jsonBytes[k] == globals::DOUBLE_QUOTE); }
                                }
                            }
                        }
                    }
                }

                if (is_left_OK & is_right_OK) { index = i; }
            }
        }
    }

    index
}

//
// Parses ASCII bytes of input JSON corresponding to input property value
//
// @returns A ValueBytes<N> instance representing the ASCII byte array and its validity
//
/* unconstrained */ fn getValueBytes<JSON_SIZE, PROP_NAME_SIZE, BYTES_SIZE>(aJSONString : str<JSON_SIZE>, aPropName : str<PROP_NAME_SIZE>) -> ValueBytes<BYTES_SIZE>
{
    let json_bytes = aJSONString.as_bytes();
    let prop_name_bytes = aPropName.as_bytes();

    // TODO: Unconstrained functions cannot call *any other functions*
    // https://github.com/AztecProtocol/aztec-packages/blob/master/yarn-project/acir-simulator/README.md
    let index = findProperty(json_bytes, prop_name_bytes);

    let mut value_bytes : [Field; BYTES_SIZE] = [-1; BYTES_SIZE];
    let mut value_bytes_index : Field = 0;

    let mut is_value_found = false;
    let mut is_value_malformed = false;
    let mut is_value_parsed = false;
    let mut is_skipped = false;

    let mut is_colon_found = false;
    let mut is_single_quoted = false;
    let mut is_double_quoted = false;
    let mut can_start = false;

    for i in 0..JSON_SIZE
    {
        if (!can_start) { can_start = (i == (index + PROP_NAME_SIZE)); }

        if (!is_value_parsed & can_start)
        {
            if (!is_colon_found)
            {
                is_colon_found = (json_bytes[i] == globals::COLON);
            }

            if (is_colon_found)
            {
                is_single_quoted = (json_bytes[i] == globals::SINGLE_QUOTE);
                is_double_quoted = (json_bytes[i] == globals::DOUBLE_QUOTE);
            }

            is_skipped  = (json_bytes[i] == globals::SINGLE_QUOTE);
            is_skipped |= (json_bytes[i] == globals::DOUBLE_QUOTE);
            is_skipped |= (json_bytes[i] == globals::COLON);
            is_skipped |= (json_bytes[i] == globals::SPACE);

            is_value_malformed = (is_value_found & is_skipped & !is_single_quoted & !is_double_quoted);
            is_value_parsed = is_value_malformed;

            if (!is_skipped)
            {
                if (!is_colon_found)
                {
                    is_value_malformed = true;
                    is_value_parsed = true;
                }

                if (!is_value_malformed)
                {
                    is_value_found = true;

                    value_bytes[value_bytes_index] = json_bytes[i] as Field;
                    value_bytes_index += 1;

                    is_value_parsed  = (json_bytes[i + 1] == globals::COMMA);
                    is_value_parsed |= (json_bytes[i + 1] == globals::RIGHT_BRACE);
                    is_value_parsed |= (json_bytes[i + 1] == globals::SINGLE_QUOTE);
                    is_value_parsed |= (json_bytes[i + 1] == globals::DOUBLE_QUOTE);
                }
            }
        }
    }

    ValueBytes { valid: (is_value_parsed & !is_value_malformed), bytes: value_bytes }
}

//
// Parses characters from input JSON string corresponding to input property's value (expected type: u32)
//
// @returns A PropertyValue<u32> instance representing the converted value and its validity
//
fn getValueU32<JSON_SIZE, PROP_NAME_SIZE>(aJSONString : str<JSON_SIZE>, aPropName : str<PROP_NAME_SIZE>) -> PropertyValue<u32>
{
    let mut value_bytes = getValueBytes(aJSONString, aPropName);

    for i in 0..value_bytes.bytes.len()
    {
        if (value_bytes.valid)
        {
            value_bytes.bytes[i] = utils::transformASCIIDigit(value_bytes.bytes[i]);
            value_bytes.valid &= utils::validateASCIDigit(value_bytes.bytes[i]);
        }
    }

    let mut value : u32 = 0;
    if (value_bytes.valid) { value = converters::toU32(value_bytes.bytes); }

    PropertyValue { valid: value_bytes.valid, value: value }
}
