global BYTE_NULL : u8 = 0x00;

global BEGIN_ARRAY     : u8 = 0x5B; // [ left square bracket
global END_ARRAY       : u8 = 0x5D; // ] right square bracket
global BEGIN_OBJECT    : u8 = 0x7B; // { left curly bracket
global END_OBJECT      : u8 = 0x7D; // } right curly bracket
global KEY_DELIMITER   : u8 = 0x3A; // : colon
global VALUE_DELIMITER : u8 = 0x2C; // , comma
global QUOTATION_MARK  : u8 = 0x27; // ' single quote
global BACKSLASH       : u8 = 0x5C; // \ reverse solidus

global LITERALS_NULL  : [u8; 4] = [ 0x6E, 0x75, 0x6C, 0x6C ];
global LITERALS_TRUE  : [u8; 4] = [ 0x74, 0x72, 0x75, 0x65 ];
global LITERALS_FALSE : [u8; 5] = [ 0x66, 0x61, 0x6C, 0x73, 0x65 ];

global MINUS         : u8 = 0x2D; // -
global ZERO          : u8 = 0x30; // 0
global DECIMAL_POINT : u8 = 0x2E; // .
global CHAR_e        : u8 = 0x65; // e
global CHAR_E        : u8 = 0x45; // E
global PLUS          : u8 = 0x2B; // +
