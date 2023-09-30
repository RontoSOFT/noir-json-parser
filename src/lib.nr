mod globals;
mod utils;
mod parse;
mod convert;

use crate::globals::BYTE_NULL;
use crate::utils::print_bytes;

struct Property<KEY_SIZE, VALUE_SIZE>
{
    key : [u8; KEY_SIZE],
    value : [u8; VALUE_SIZE],
}

struct UnconstrainedProperty
{
    key : [u8],
    value : [u8],
}

struct JSON
{
    doc: [ UnconstrainedProperty ]
}

impl<KEY_SIZE, VALUE_SIZE> Property<KEY_SIZE, VALUE_SIZE>
{
    unconstrained
fn new() -> Self
    {
        Property { key: [BYTE_NULL; KEY_SIZE], value: [BYTE_NULL; VALUE_SIZE] }
    }
}

impl UnconstrainedProperty
{
    unconstrained
fn new() -> Self
    {
        UnconstrainedProperty { key: [], value: [] }
    }

    unconstrained
fn print(&mut self)
    {
        print_bytes("key", self.key);
        print_bytes("value", self.value);
    }
}
