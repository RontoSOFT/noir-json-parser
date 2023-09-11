global SINGLE_QUOTE : u8 = 0x27;    // single-quote         (')
global DOUBLE_QUOTE : u8 = 0x22;    // double-quote         (")
global COLON        : u8 = 0x3a;    // colon                (:)
global COMMA        : u8 = 0x2c;    // comma                (,)
global LEFT_BRACE   : u8 = 0x7b;    // left curly brace     ({)
global RIGHT_BRACE  : u8 = 0x7d;    // right curly brace    (})
global SPACE        : u8 = 0x20;    // space                ( )

global DIGIT_NULL_    : u32 = 10;  // value represeting 'null' for digit byte arrays
global DIGIT_NULL    : Field = 10;  // value represeting 'null' for digit byte arrays
global U32_CHAR_SIZE : Field = 10;  // string representing max(u32) is "4294967295", 10 characters long
