use crate::JSON;
use crate::Property;

use crate::globals::BEGIN_ARRAY;
use crate::globals::END_ARRAY;
use crate::globals::BEGIN_OBJECT;
use crate::globals::END_OBJECT;
use crate::globals::KEY_DELIMITER;
use crate::globals::VALUE_DELIMITER;
use crate::globals::QUOTATION_MARK;
use crate::globals::BACKSLASH;
use crate::globals::TAB;
use crate::globals::NEWLINE;
use crate::globals::RETURN;
use crate::globals::SPACE;
use crate::globals::MINUS;
use crate::globals::PLUS;
use crate::globals::ZERO;
use crate::globals::POINT;
use crate::globals::CHAR_e;
use crate::globals::CHAR_E;

global FIELD_t     : Field = 0x74;
global FIELD_tr    : Field = 0x7472;
global FIELD_tru   : Field = 0x747275;
global FIELD_true  : Field = 0x74727565;
global FIELD_n     : Field = 0x6E;
global FIELD_nu    : Field = 0x6E75;
global FIELD_nul   : Field = 0x6E756C;
global FIELD_null  : Field = 0x6E756C6C;
global FIELD_f     : Field = 0x66;
global FIELD_fa    : Field = 0x6661;
global FIELD_fal   : Field = 0x66616C;
global FIELD_fals  : Field = 0x66616C73;
global FIELD_false : Field = 0x66616C7365;

impl JSON
{
    unconstrained
    pub fn parse<SIZE>(string : str<SIZE>) -> Self
    {
    //     dep::std::println("");
    //     dep::std::println(string);
    //     dep::std::println("");

        string.as_bytes().parse(&mut 0, SIZE, -1)
    }
}

trait ByteArrayParser
{
    fn parse_string(bytes : Self) -> [u8];
    fn parse(bytes : Self, begin : &mut Field, end : Field, child_index : Field) -> JSON;
}

impl<N> ByteArrayParser for [u8; N]
{
    unconstrained
    fn parse_string(array : Self) -> [u8]
    {
        let mut bytes : [u8] = array.as_slice();

        if (array.len() != 0)
        {
            if (array[0] == QUOTATION_MARK)
            {
                let json = array.parse(&mut 1, (array.len() - 1), -1);
                if (!json.is_none()) { bytes = json.doc[0].value; }
            }
        }

        bytes
    }

    unconstrained
    fn parse(bytes : Self, mut begin : &mut Field, end : Field, child_index : Field) -> JSON
    {
        let mut json = JSON::none();
        let mut prop = Property::none();

        let mut arrays : Field = 0;
        let mut literal_field : Field = 0;
        let mut index : Field = *begin;

        let mut byte_prev : u8 = 0;

        let child = (index != 0);
        let mut OK = (index != end);
        let mut value = true;
        let mut done = false;
        let mut escaped = false;
        let mut key_delimiter = false;
        let mut value_delimiter = false;
        let mut object = false;
        let mut array = false;
        let mut string = false;
        let mut number = false;
        let mut literal = false;
        let mut array_value = false;
        let mut minus = false;
        let mut digit_0 = false;
        let mut digit_1_9 = false;
        let mut e_E = false;
        let mut fraction = false;
        let mut fraction_digit = false;
        let mut e_minus = false;
        let mut e_plus = false;
        let mut e_digit = false;

        for _ in index..end
        {
            if (OK & (index != end))
            {
                let byte = bytes[index];
                index += 1;

                if (string)
                {
                    string  = (byte != QUOTATION_MARK);
                    string |= ((byte == QUOTATION_MARK) & (byte_prev == BACKSLASH) & !escaped);

                    let safe = !((byte == BACKSLASH) & escaped);
                    if      (safe & value)  { prop.value = prop.value.push_back(byte); done = !(string | array); }
                    else if (safe & string) { prop.key = prop.key.push_back(byte); OK = object; }
                    else if (safe)          { OK = (prop.key.len() != 0); }
                }
                else if ((byte == BEGIN_OBJECT) | (byte == BEGIN_ARRAY))
                {
                    if (byte == BEGIN_ARRAY)
                    {
                        OK = (!array_value | (array_value & value_delimiter));

                        prop.value = prop.value.push_back(byte);
                        array_value = array;

                        arrays += 1;
                        array = true;

                        OK &= value;
                    }
                    else if (object | array)
                    {
                        let mut index_local : Field = (index - 1); // will be overwritten to store child object's end index
                        let child_index : Field = (json.children.len() + child_index + 1);

                        let child_json = bytes.parse(&mut index_local, (end - 1), child_index);

                        OK = (child_json.doc.len() != 0);
                        if (OK)
                        {
                            if ((prop.value.len() as u64) > 2) { OK = value_delimiter; }

                            prop.value = prop.value.push_back(BEGIN_OBJECT);
                            prop.value = prop.value.push_back(child_index as u8);
                            prop.value = prop.value.push_back(END_OBJECT);

                            json.children = json.children.push_back(child_json.doc);
                            for child in child_json.children { json.children = json.children.push_back(child); }

                            index = index_local;
                            array_value = true;
                        }
                    }
                    else
                    {
                        OK &= value;

                        object = true;
                        value = false;
                    }
                }
                else if ((byte == END_OBJECT) | (byte == END_ARRAY))
                {
                    let has_value = (prop.value.len() != 0);

                    OK = (!value_delimiter | (value_delimiter & array_value));

                    if (byte == END_ARRAY)
                    {
                        prop.value = prop.value.push_back(byte);

                        arrays -= 1;
                        array = (arrays != 0);
                    }
                    else
                    {
                        OK &= (object & ((prop.key.len() != 0) == has_value));

                        object = false;

                        if (child)
                        {
                            *begin = index; // return child object's end index
                            index = end;
                        }
                    }

                    done = (OK & !array & has_value) | (bytes[end - 1] == QUOTATION_MARK);
                }
                else if (byte == QUOTATION_MARK)
                {
                    OK = ((array | !(number | literal)) & !escaped);

                    string = true;
                    escaped = (byte_prev == BACKSLASH);

                    if (value)
                    {
                        OK = (!array_value | (array_value & value_delimiter));

                        prop.value = prop.value.push_back(byte);
                        array_value = true;
                    }
                }
                else if (byte == KEY_DELIMITER)
                {
                    OK = (object & !(key_delimiter | (prop.key.len() == 0)));

                    key_delimiter = true;
                    value = true;

                    if (array) { prop.value = prop.value.push_back(byte); }
                }
                else if (byte == VALUE_DELIMITER)
                {
                    OK = ((object | array) & array_value);

                    array_value = false;
                    key_delimiter = false;
                    value_delimiter = true;
                    done = (OK & !array & (prop.value.len() != 0));

                    if (array)
                    {
                        prop.value = prop.value.push_back(byte);

                        literal_field = 0;
                        number = false;
                        literal = false;
                        minus = false;
                        digit_0 = false;
                        digit_1_9 = false;
                        fraction = false;
                        fraction_digit = false;
                        e_E = false;
                        e_minus = false;
                        e_plus = false;
                        e_digit = false;
                    }
                }
                else if ((byte == SPACE) | (byte == TAB) | (byte == NEWLINE) | (byte == RETURN) | (byte == BACKSLASH))
                {
                    done = ((number | literal) & (byte != BACKSLASH));
                }
                else if (byte == 0x00)
                {
                    OK = (!(object | array) & (index == end));
                }
                else
                {
                    if ((byte - ZERO) < 10)
                    {
                        OK  = (!literal & (!digit_0 | (digit_0 & (fraction | e_E))));
                        OK &= !(object & (prop.key.len() == 0));

                        number = true;
                        digit_0 |= ((byte == ZERO) & !digit_1_9);
                        digit_1_9 |= !digit_0;
                        fraction_digit = fraction;
                        e_digit = e_E;
                    }
                    else if (byte == POINT)
                    {
                        OK = (number & !fraction & !e_E);
                        fraction = true;
                    }
                    else if (((byte == CHAR_e) | (byte == CHAR_E)) & !literal)
                    {
                        OK = (number & !e_E);
                        e_E = true;
                    }
                    else if (byte == MINUS)
                    {
                        OK = (!(minus | digit_0 | digit_1_9) | (e_E & !(e_minus | e_plus | e_digit)));

                        number = true;
                        minus = true;
                        e_minus = e_E;
                    }
                    else if (byte == PLUS)
                    {
                        OK = (e_E & !(e_plus | e_digit | e_minus));
                        e_plus = true;
                    }
                    else
                    {
                        literal_field *= 256;
                        literal_field += (byte as Field);

                        literal  = (literal_field == FIELD_t);
                        literal |= (literal_field == FIELD_tr);
                        literal |= (literal_field == FIELD_tru);
                        literal |= (literal_field == FIELD_true);
                        literal |= (literal_field == FIELD_n);
                        literal |= (literal_field == FIELD_nu);
                        literal |= (literal_field == FIELD_nul);
                        literal |= (literal_field == FIELD_null);
                        literal |= (literal_field == FIELD_f);
                        literal |= (literal_field == FIELD_fa);
                        literal |= (literal_field == FIELD_fal);
                        literal |= (literal_field == FIELD_fals);
                        literal |= (literal_field == FIELD_false);

                        OK = (!number & literal);
                    }

                    OK &= value;

                    prop.value = prop.value.push_back(byte);
                    array_value = true;
                }

                if (done)
                {
                    if      (number)  { OK = ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)); }
                    else if (literal) { OK = ((literal_field == FIELD_true) | (literal_field == FIELD_null) | (literal_field == FIELD_false)); }

                    if (OK)
                    {
                        let mut copy : [Property] = [];
                        for current in json.doc { if (!prop.key.eq(current.key)) { copy = copy.push_back(current); } }
                        json.doc = copy.push_back(prop);

                        // prop.print();
                        prop = Property::none();
                    }

                    literal_field = 0;
                    done = false;
                    value = false;
                    number = false;
                    literal = false;
                    minus = false;
                    digit_0 = false;
                    digit_1_9 = false;
                    fraction = false;
                    fraction_digit = false;
                    e_E = false;
                    e_minus = false;
                    e_plus = false;
                    e_digit = false;
                }

                byte_prev = byte;
            }
        }

        if (OK & !(object | array | string))
        {
            if (json.is_none())
            {
                OK  = (number & ((digit_0 | digit_1_9) & (!fraction | fraction_digit) & (!e_E | e_digit)));
                OK |= (!number & literal & ((literal_field == FIELD_true) | (literal_field == FIELD_null) | (literal_field == FIELD_false)));
                OK |= !value;

                if (OK) { json.doc = [prop]; }
            }

            json
        }
        else
        {
            // dep::std::println(f"Unexpected character at position {index}");
            JSON::none()
        }
    }
}
