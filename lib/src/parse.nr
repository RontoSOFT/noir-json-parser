use crate::globals;
use crate::convert::StringBytes;

struct JSON<N>
{
    bytes : [u8; N]
}

impl<SIZE_JSON> JSON<SIZE_JSON>
{

fn new(string : str<SIZE_JSON>) -> Self
{
    JSON { bytes: string.as_bytes() }
}

//
// Searches for property name (bytes to match) in JSON (bytes)
//
// @returns A Field value indicating the starting index where the value is found
//
fn indexOf<SIZE_PROP_NAME>(self, propName : str<SIZE_PROP_NAME>) -> Field
{
    let prop_name_bytes = propName.as_bytes();
    let mut index : Field = -1;

    for i in 1..(SIZE_JSON - 1)
    {
        if (index == -1)
        {
            let mut is_property_found = true;
            for j in 0..SIZE_PROP_NAME { is_property_found &= (self.bytes[i + j] == prop_name_bytes[j]); }

            if (is_property_found)
            {
                let is_adjacent_symbol_valid = |side : Field| // 0 -> left or 1 -> right
                {
                    let j = (i - 1) + (side * (SIZE_PROP_NAME + 1));  // left -> (i - 1) or right -> (i + SIZE_PROP_NAME)

                    let mut is_valid = false;

                    if (side == 0)                                          // left side termination characters
                    {
                        is_valid = (self.bytes[j] == globals::COMMA);
                        is_valid |= (self.bytes[j] == globals::LEFT_BRACE);
                    }
                    else                                                    // right side termination characters
                    {
                        is_valid = (self.bytes[j] == globals::COLON);
                        is_valid |= (self.bytes[j] == globals::RIGHT_BRACE);
                    }

                    is_valid |= (self.bytes[j] == globals::SINGLE_QUOTE);   // common termination characters
                    is_valid |= (self.bytes[j] == globals::DOUBLE_QUOTE);

                    is_valid
                };

                if (is_adjacent_symbol_valid(0) & is_adjacent_symbol_valid(1)) { index = i; index }
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
fn bytesOf<SIZE_PROP_NAME, SIZE_BYTE_ARRAY>(self, propName : str<SIZE_PROP_NAME>) -> StringBytes<SIZE_BYTE_ARRAY>
{
    // TODO: Unconstrained functions cannot call *any other functions*
    // https://github.com/AztecProtocol/aztec-packages/blob/master/yarn-project/acir-simulator/README.md
    let index = self.indexOf(propName);

    let mut value_bytes : [u8; SIZE_BYTE_ARRAY] = [globals::BYTE_NULL; SIZE_BYTE_ARRAY];
    let mut value_bytes_index : Field = 0;

    let mut can_start = false;
    let mut can_array_fit_value = true;
    let mut is_done = false;
    let mut is_value_found = false;
    let mut is_value_intact = false;
    let mut is_char_skipped = false;
    let mut is_colon_found = false;
    let mut is_single_quoted = false;
    let mut is_double_quoted = false;

    for i in 0..SIZE_JSON
    {
        if (!can_start) { can_start = (i == (index + SIZE_PROP_NAME)); }

        if (!is_done & can_start)
        {
            if (!is_colon_found) { is_colon_found = (self.bytes[i] == globals::COLON); }

            if (is_colon_found)
            {
                if (!is_single_quoted & !is_double_quoted) { is_single_quoted = (self.bytes[i] == globals::SINGLE_QUOTE); }
                if (!is_single_quoted & !is_double_quoted) { is_double_quoted = (self.bytes[i] == globals::DOUBLE_QUOTE); }
            }

            if (is_single_quoted | is_double_quoted) & (self.bytes[i] == globals::SPACE) { is_char_skipped = false; }
            else
            {
                is_char_skipped  = (self.bytes[i] == globals::COLON);
                is_char_skipped |= (self.bytes[i] == globals::SPACE);
                is_char_skipped |= (self.bytes[i] == globals::SINGLE_QUOTE);
                is_char_skipped |= (self.bytes[i] == globals::DOUBLE_QUOTE);
            }

            is_value_intact = (!is_value_found | !is_char_skipped | is_single_quoted | is_double_quoted);
            is_done = !is_value_intact;

            if (!is_char_skipped)
            {
                if (!is_colon_found)
                {
                    is_value_intact = false;
                    is_done = true;
                }

                if (is_value_intact)
                {
                    can_array_fit_value = (value_bytes_index != SIZE_BYTE_ARRAY);

                    if (!can_array_fit_value) { is_done = true; }
                    else
                    {
                        is_value_found = true;

                        let x = self.bytes[i] as Field;
                        value_bytes[value_bytes_index] = x as u8;
                        // TODO:
                        // value_bytes[value_bytes_index] = self.bytes[i];
                        value_bytes_index += 1;

                        is_done  = (self.bytes[i + 1] == globals::COMMA);
                        is_done |= (self.bytes[i + 1] == globals::RIGHT_BRACE);
                        is_done |= (self.bytes[i + 1] == globals::SINGLE_QUOTE);
                        is_done |= (self.bytes[i + 1] == globals::DOUBLE_QUOTE);
                    }
                }
            }
        }
    }

    StringBytes { valid: (is_done & is_value_intact & can_array_fit_value), bytes: value_bytes }
}

}
