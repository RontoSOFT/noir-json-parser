use crate::globals;

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
unconstrained fn findProperty<JSON_SIZE, PROP_NAME_SIZE>(jsonBytes : [u8; JSON_SIZE], propNameBytes : [u8; PROP_NAME_SIZE]) -> Field
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

            if (is_property_found) { index = i; }
        }
    }

    index
}

unconstrained fn transformASCIIDigit(mut byteValue : Field) -> Field
{
    if (byteValue != -1) { byteValue -= 0x30; } // convert ASCII to digit as integer
    else                 { byteValue = globals::DIGIT_NULL; }

    byteValue
}

unconstrained fn validateASCIDigit(byteValue : u8) -> bool
{
    (byteValue <= (globals::DIGIT_NULL as u8))
}

//
// Parses ASCII bytes of input JSON, starting at index, and loads bytes corresponding to property value
//
// @returns A ValueBytes<N> instance representing the ASCII byte array and its validity
//
unconstrained fn getValueBytes<JSON_SIZE, BYTES_SIZE>(jsonBytes : [u8; JSON_SIZE], index : Field) -> ValueBytes<BYTES_SIZE> //, transform : fn (Field) -> (Field), validate : fn (u4) -> (bool)) -> ValueBytes<BYTES_SIZE>
{
    let mut value_bytes : [Field; BYTES_SIZE] = [-1; BYTES_SIZE];
    let mut value_bytes_index : Field = 0;

    let mut is_value_found = false;
    let mut is_value_malformed = false;
    let mut is_value_parsed = false;
    let mut is_skipped = false;

    let mut is_colon_found = false;
    let mut is_single_quoted = false;
    let mut is_double_quoted = false;

    for i in index..JSON_SIZE
    {
        if (!is_value_parsed)
        {
            if (!is_colon_found)
            {
                is_colon_found = (jsonBytes[i] == globals::COLON);
            }

            if (is_colon_found)
            {
                is_single_quoted = (jsonBytes[i] == globals::SINGLE_QUOTE);
                is_double_quoted = (jsonBytes[i] == globals::DOUBLE_QUOTE);
            }

            is_skipped  = (jsonBytes[i] == globals::SINGLE_QUOTE);
            is_skipped |= (jsonBytes[i] == globals::DOUBLE_QUOTE);
            is_skipped |= (jsonBytes[i] == globals::COLON);
            is_skipped |= (jsonBytes[i] == globals::SPACE);

            is_value_malformed = (is_value_found & is_skipped & !is_single_quoted & !is_double_quoted);
            is_value_parsed = is_value_malformed;

            // dep::std::println("...");
            // dep::std::println(jsonBytes[i]);
            // dep::std::println(is_skipped);
            // dep::std::println(is_colon_found);
            // dep::std::println(is_single_quoted);
            // dep::std::println(is_value_malformed);

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

                    value_bytes[value_bytes_index] = jsonBytes[i] as Field;
                    value_bytes_index += 1;

                    is_value_parsed  = (jsonBytes[i + 1] == globals::COMMA);
                    is_value_parsed |= (jsonBytes[i + 1] == globals::RIGHT_BRACE);
                    is_value_parsed |= (jsonBytes[i + 1] == globals::SINGLE_QUOTE);
                    is_value_parsed |= (jsonBytes[i + 1] == globals::DOUBLE_QUOTE);
                }
            }
        }
    }

    ValueBytes { valid: (is_value_parsed & !is_value_malformed), bytes: value_bytes }
}
