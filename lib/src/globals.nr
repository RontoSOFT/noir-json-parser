global SINGLE_QUOTE : u8 = 0x27;    // single-quote         '
global DOUBLE_QUOTE : u8 = 0x22;    // double-quote         "
global COLON        : u8 = 0x3A;    // colon                :
global COMMA        : u8 = 0x2C;    // comma                ,
global LEFT_PARENT  : u8 = 0x7B;    // left parenthesis     (
global RIGHT_PARENT : u8 = 0x7D;    // right parenthesis    )
global LEFT_BRACKET : u8 = 0x7B;    // left bracket         [
global RIGHT_BRACKET: u8 = 0x7D;    // right bracket        ]
global LEFT_BRACE   : u8 = 0x7B;    // left curly brace     {
global RIGHT_BRACE  : u8 = 0x7D;    // right curly brace    }
global SPACE        : u8 = 0x20;    // space                ( )

global BEGIN_ARRAY     : u8 = 0x5B; // [ left square bracket
global END_ARRAY       : u8 = 0x5D; // ] right square bracket
global BEGIN_OBJECT    : u8 = 0x7B; // { left curly bracket
global END_OBJECT      : u8 = 0x7D; // } right curly bracket
global KEY_DELIMITER   : u8 = 0x3A; // : colon
global VALUE_DELIMITER : u8 = 0x2C; // , comma
global QUOTATION_MARK  : u8 = 0x27; // ' single quote
global BACKSLASH       : u8 = 0x5C; // \ reverse solidus

global PLUS  = 0x2B; // +
global MINUS = 0x2D; // -
global ZERO  = 0x30; // 0
global DECIMAL_POINT = 0x2E; // .
global DIGITS_1_9 : [u8; 9] = [ 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39 ];
global eE : [u8; 2]= [ 0x65, 0x45 ]; // e or E

global WHITESPACES : [u8; 4] =
[
    0x20, // space           ( )
    0x09, // horizontal tab  (\t)
    0x0A, // newline         (\n)
    0x0D, // carriage return (\r)
];
                  // a     e     f     l     n     r     s     t     u
global LITERALS = [ 0x61, 0x65, 0x66, 0x6c, 0x6e, 0x72, 0x73, 0x74, 0x75];

global LITERALS_NULL  = [ 0x6e, 0x75, 0x6c, 0x6c ];
global LITERALS_TRUE  = [ 0x74, 0x72, 0x75, 0x65 ];
global LITERALS_FALSE = [ 0x66, 0x61, 0x6c, 0x73, 0x65 ];

// value represeting 'null' for all byte arrays
// TODO: actually -1, but can't declare it, see https://github.com/noir-lang/noir/issues/2660
// global BYTE_NULL        : Field = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000000;
global BYTE_NULL     : u8 = 0xff;

global DIGIT_NULL       : Field = 10;   // value represeting 'null' for digit byte arrays

global BOOL_CHAR_SIZE   : Field =  5;  // max(bool)                      "false",  5 characters
global U8_CHAR_SIZE     : Field =  3;  // max(u8)                          "255",  3 characters
global U16_CHAR_SIZE    : Field =  5;  // max(u16)                      "65'535",  5 characters
global U32_CHAR_SIZE    : Field = 10;  // max(u32)               "4'294'967'295", 10 characters
global U64_CHAR_SIZE    : Field = 20;  // max(u64)  "18'446'744'073'709'551'616", 20 characters

global TRUE_ARRAY   : [Field; BOOL_CHAR_SIZE] = [0x74,0x72,0x75,0x65,BYTE_NULL];
global FALSE_ARRAY  : [Field; BOOL_CHAR_SIZE] = [0x66,0x61,0x6c,0x73,0x65];   
global ONE_ARRAY    : [Field; BOOL_CHAR_SIZE] = [0x31,BYTE_NULL,BYTE_NULL,BYTE_NULL,BYTE_NULL];   
global ZERO_ARRAY   : [Field; BOOL_CHAR_SIZE] = [0x30,BYTE_NULL,BYTE_NULL,BYTE_NULL,BYTE_NULL];
