global SINGLE_QUOTE : u8 = 0x27;    // single-quote         (')
global DOUBLE_QUOTE : u8 = 0x22;    // double-quote         (")
global COLON        : u8 = 0x3a;    // colon                (:)
global COMMA        : u8 = 0x2c;    // comma                (,)
global LEFT_BRACE   : u8 = 0x7b;    // left curly brace     ({)
global RIGHT_BRACE  : u8 = 0x7d;    // right curly brace    (})
global SPACE        : u8 = 0x20;    // space                ( )

// value represeting 'null' for all byte arrays
// TODO: actually -1, but can't declare it, see https://github.com/noir-lang/noir/issues/2660
global BYTE_NULL        : Field = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000000;

global DIGIT_NULL       : Field = 10;   // value represeting 'null' for digit byte arrays
global DIGIT_NULL_ASCII : Field = 0x3A; // ASCII code value represeting 'null' for digit byte arrays

global BOOL_CHAR_SIZE   : Field =  5;  // max(bool)                      "false",  5 characters
global U8_CHAR_SIZE     : Field =  3;  // max(u8)                          "255",  3 characters
global U16_CHAR_SIZE    : Field =  5;  // max(u16)                      "65'535",  5 characters
global U32_CHAR_SIZE    : Field = 10;  // max(u32)               "4'294'967'295", 10 characters
global U64_CHAR_SIZE    : Field = 20;  // max(u64)  "18'446'744'073'709'551'616", 20 characters

global TRUE_ARRAY   : [Field; BOOL_CHAR_SIZE] = [0x74,0x72,0x75,0x65,BYTE_NULL];
global FALSE_ARRAY  : [Field; BOOL_CHAR_SIZE] = [0x66,0x61,0x6c,0x73,0x65];   
global ONE_ARRAY    : [Field; BOOL_CHAR_SIZE] = [0x31,BYTE_NULL,BYTE_NULL,BYTE_NULL,BYTE_NULL];   
global ZERO_ARRAY   : [Field; BOOL_CHAR_SIZE] = [0x30,BYTE_NULL,BYTE_NULL,BYTE_NULL,BYTE_NULL];
