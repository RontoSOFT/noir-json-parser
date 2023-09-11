use crate::globals;
use crate::utils;
use crate::convert;

struct JSON<N>
{
    bytes : [u8; N]
}

impl<SIZE_JSON> JSON<SIZE_JSON>
{
    fn new(aJSONString : str<SIZE_JSON>) -> Self
    {
        JSON { bytes: aJSONString.as_bytes() }
    }

//
// Searches for property name (bytes to match) in JSON (bytes)
//
// @returns A Field value indicating the starting index where the value is found
//
/*unconstrained*/ fn indexOf<SIZE_PROP_NAME>(self : JSON<SIZE_JSON>, aPropName : str<SIZE_PROP_NAME>) -> Field
{
    let prop_name_bytes = aPropName.as_bytes();
    let mut index : Field = -1;

    for i in 0..SIZE_JSON
    {
        if (index == -1)
        {
            let mut is_property_found = (SIZE_PROP_NAME != 0);

            for j in 0..SIZE_PROP_NAME
            {
                is_property_found &= (self.bytes[j + i] == prop_name_bytes[j]);
            }

            if (is_property_found)
            {
                let mut j = 0;
                let mut is_left_OK = true;
                let mut is_right_OK = true;

                let mut is_colon_found = false;
                let mut is_single_quoted = false;
                let mut is_double_quoted = false;

                // analyze first character on the left hand side
                j = i - 1;

                if (i != 0)
                {
                    is_left_OK  = (self.bytes[j] == globals::COMMA);
                    is_left_OK |= (self.bytes[j] == globals::SPACE);
                    is_left_OK |= (self.bytes[j] == globals::LEFT_BRACE);
                    is_left_OK |= (self.bytes[j] == globals::RIGHT_BRACE);
                    is_left_OK |= (self.bytes[j] == globals::SINGLE_QUOTE);
                    is_left_OK |= (self.bytes[j] == globals::DOUBLE_QUOTE);

                    //
                    // TODO: create a test that can show this code to be of use for treating an 'edge-case'
                    //
                    // if ((self.bytes[j] == globals::SPACE))
                    // {
                    //     for k in 0..j
                    //     {
                    //         if (is_left_OK)
                    //         {
                    //             if (!is_colon_found) { is_colon_found  = (self.bytes[k] == globals::COLON); }

                    //             if (!is_single_quoted)
                    //             {
                    //                 if (is_colon_found) { is_left_OK = false; }
                    //                 else                { is_single_quoted = (self.bytes[k] == globals::SINGLE_QUOTE); }
                    //             }

                    //             if (!is_double_quoted)
                    //             {
                    //                 if (is_colon_found) { is_left_OK = false; }
                    //                 else                { is_double_quoted = (self.bytes[k] == globals::DOUBLE_QUOTE); }
                    //             }
                    //         }
                    //     }
                    // }
                }

                // analyze all characters on right hand side
                j += SIZE_PROP_NAME + 1;

                if ((j - SIZE_JSON) != 1)
                {
                    is_right_OK  = (self.bytes[j] == globals::COLON);
                    is_right_OK |= (self.bytes[j] == globals::SPACE);
                    is_right_OK |= (self.bytes[j] == globals::LEFT_BRACE);
                    is_right_OK |= (self.bytes[j] == globals::RIGHT_BRACE);
                    is_right_OK |= (self.bytes[j] == globals::SINGLE_QUOTE);
                    is_right_OK |= (self.bytes[j] == globals::DOUBLE_QUOTE);

                    if ((self.bytes[j] == globals::SPACE))
                    {
                        for k in j..SIZE_JSON
                        {
                            if (is_right_OK)
                            {
                                if (!is_colon_found) { is_colon_found  = (self.bytes[k] == globals::COLON); }

                                if (!is_single_quoted)
                                {
                                    if (is_colon_found) { is_right_OK = false; }
                                    else                { is_single_quoted = (self.bytes[k] == globals::SINGLE_QUOTE); }
                                }

                                if (!is_double_quoted)
                                {
                                    if (is_colon_found) { is_right_OK = false; }
                                    else                { is_double_quoted = (self.bytes[k] == globals::DOUBLE_QUOTE); }
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
// Parses ASCII bytes corresponding to input property value (as bytes)
//
// @returns A StringBytes<N> instance representing the ASCII byte array and its validity
//
/* unconstrained */ fn bytesOf<SIZE_PROP_NAME, SIZE_BYTE_ARRAY>(self : JSON<SIZE_JSON>, aPropName : str<SIZE_PROP_NAME>) -> convert::StringBytes<SIZE_BYTE_ARRAY>
{
    // TODO: Unconstrained functions cannot call *any other functions*
    // https://github.com/AztecProtocol/aztec-packages/blob/master/yarn-project/acir-simulator/README.md
    let index = self.indexOf(aPropName);

    let mut value_bytes : [Field; SIZE_BYTE_ARRAY] = [-1; SIZE_BYTE_ARRAY];
    let mut value_bytes_index : Field = 0;

    let mut is_value_parsed = false;
    let mut is_value_found = false;
    let mut is_value_malformed = false;
    let mut is_char_skipped = false;

    let mut is_colon_found = false;
    let mut is_single_quoted = false;
    let mut is_double_quoted = false;
    let mut can_start = false;

    for i in 0..SIZE_JSON
    {
        if (!can_start) { can_start = (i == (index + SIZE_PROP_NAME)); }

        if (!is_value_parsed & can_start)
        {
            if (!is_colon_found)
            {
                is_colon_found = (self.bytes[i] == globals::COLON);
            }

            if (is_colon_found)
            {
                is_single_quoted = (self.bytes[i] == globals::SINGLE_QUOTE);
                is_double_quoted = (self.bytes[i] == globals::DOUBLE_QUOTE);
            }

            is_char_skipped  = (self.bytes[i] == globals::SINGLE_QUOTE);
            is_char_skipped |= (self.bytes[i] == globals::DOUBLE_QUOTE);
            is_char_skipped |= (self.bytes[i] == globals::COLON);
            is_char_skipped |= (self.bytes[i] == globals::SPACE);

            is_value_malformed = (is_value_found & is_char_skipped & !is_single_quoted & !is_double_quoted);
            is_value_parsed = is_value_malformed;

            if (!is_char_skipped)
            {
                if (!is_colon_found)
                {
                    is_value_malformed = true;
                    is_value_parsed = true;
                }

                if (!is_value_malformed)
                {
                    is_value_found = true;

                    value_bytes[value_bytes_index] = self.bytes[i] as Field;
                    value_bytes_index += 1;

                    is_value_parsed  = (self.bytes[i + 1] == globals::COMMA);
                    is_value_parsed |= (self.bytes[i + 1] == globals::RIGHT_BRACE);
                    is_value_parsed |= (self.bytes[i + 1] == globals::SINGLE_QUOTE);
                    is_value_parsed |= (self.bytes[i + 1] == globals::DOUBLE_QUOTE);
                }
            }
        }
    }

    convert::StringBytes { valid: (is_value_parsed & !is_value_malformed), bytes: value_bytes }
}

}
