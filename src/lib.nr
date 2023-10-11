mod globals;
mod utils;
mod parse;
mod convert;
mod float;

use crate::globals::BYTE_NULL;
use crate::utils::print_bytes;

struct Property
{
    key : [u8],
    value : [u8],
}

struct JSON
{
    doc: [ Property ]
}

impl Property
{
    unconstrained
    fn new() -> Self
    {
        Property { key: [], value: [] }
    }

    unconstrained
    fn print(self)
    {
        print_bytes("key", self.key);
        print_bytes("value", self.value);
    }
}
