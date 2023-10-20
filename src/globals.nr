global BYTE_NULL : u8 = 0x00;

global BEGIN_ARRAY     : u8 = 0x5B; // [ left square bracket
global END_ARRAY       : u8 = 0x5D; // ] right square bracket
global BEGIN_OBJECT    : u8 = 0x7B; // { left curly bracket
global END_OBJECT      : u8 = 0x7D; // } right curly bracket
global KEY_DELIMITER   : u8 = 0x3A; // : colon
global VALUE_DELIMITER : u8 = 0x2C; // , comma
global QUOTATION_MARK  : u8 = 0x27; // ' single quote
global BACKSLASH       : u8 = 0x5C; // \ reverse solidus

//                               ( )   \t    \n    \r
global WHITESPACES : [u8; 4] = [ 0x20, 0x09, 0x0A, 0x0D ];

//                            a     e     f     l     n     r     s     t     u
global LITERALS : [u8; 9] = [ 0x61, 0x65, 0x66, 0x6c, 0x6e, 0x72, 0x73, 0x74, 0x75];

global LITERALS_NULL  : [u8; 4] = [ 0x6e, 0x75, 0x6c, 0x6c ];
global LITERALS_TRUE  : [u8; 4] = [ 0x74, 0x72, 0x75, 0x65 ];
global LITERALS_FALSE : [u8; 5] = [ 0x66, 0x61, 0x6c, 0x73, 0x65 ];

//                               0     1     2     3     4     5     6     7     8     9
global DIGITS_0_9 : [u8; 10] = [ 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39 ];

global MINUS         : u8 = 0x2D; // -
global ZERO          : u8 = 0x30; // 0
global DECIMAL_POINT : u8 = 0x2E; // .
global CHAR_e        : u8 = 0x65; // e
global CHAR_E        : u8 = 0x45; // E
global PLUS          : u8 = 0x2B; // +
