global BEGIN_ARRAY     : u8 = 0x5B; // [ left square bracket
global END_ARRAY       : u8 = 0x5D; // ] right square bracket
global BEGIN_OBJECT    : u8 = 0x7B; // { left curly bracket
global END_OBJECT      : u8 = 0x7D; // } right curly bracket
global KEY_DELIMITER   : u8 = 0x3A; // : colon
global VALUE_DELIMITER : u8 = 0x2C; // , comma
global QUOTATION_MARK  : u8 = 0x22; // " double quote
global BACKSLASH       : u8 = 0x5C; // \ reverse solidus

global TAB     : u8 = 0x09;
global NEWLINE : u8 = 0x0A;
global RETURN  : u8 = 0x0D;
global SPACE   : u8 = 0x20;

global PLUS  : u8 = 0x2B;
global MINUS : u8 = 0x2D;
global POINT : u8 = 0x2E;
global ZERO  : u8 = 0x30;

global CHAR_e : u8 = 0x65;
global CHAR_E : u8 = 0x45;
global CHAR_f : u8 = 0x66;
global CHAR_n : u8 = 0x6E;
global CHAR_t : u8 = 0x74;

global FIELD_true  : Field = 0x74727565;
global FIELD_null  : Field = 0x6E756C6C;
global FIELD_false : Field = 0x66616C7365;
