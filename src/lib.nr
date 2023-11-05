mod globals;
mod parse;
mod convert;
mod utils;

use dep::std::option::Option;

use crate::globals::BEGIN_OBJECT;
use crate::globals::END_OBJECT;

struct Property
{
    key : [u8],
    value : [u8],
}

impl Property
{
    unconstrained
    fn none() -> Self { Self { key: [], value: [] } }

    unconstrained
    pub fn print(self)
    {
        dep::std::println("key");
        self.key.print();

        dep::std::println("value");
        dep::std::println("{");

        let size : u64 = (self.value.len() as u64);
        let mut object_index = false;

        for i in 0..size
        {
            if (object_index)
            {
                let index = self.value[i];
                dep::std::println(f"        {index}");
            }
            else
            {
                let s = crate::utils::chars[self.value[i] - 32];
                dep::std::println(f"    {s}");
            }

            object_index = (self.value[i] == crate::globals::BEGIN_OBJECT);
        }

        dep::std::println("}");
    }
}

trait PropertyListExtensions
{
    fn is_empty_object(self : [Property]) -> bool;

    fn getObject<N>(self : [Property], key : str<N>, parent : JSON) -> Option<[Property]>;
}

impl PropertyListExtensions for [Property]
{
    unconstrained
    pub fn is_empty_object(self) -> bool { if (self.len() == 1) { ((self[0].key.len() == 0) & (self[0].value.len() == 0)) } else { false } }

    unconstrained
    pub fn getObject<N>(self, key : str<N>, parent : JSON) -> Option<[Property]>
    {
        let value = self.bytesOf(key);

        if (value.is_some()) { value.unwrap_unchecked().asObject(parent) } else { Option::none() }
    }
}

struct JSON
{
    doc : [Property]
,   children : [[Property]]
}

impl JSON
{
    unconstrained
    fn none() -> Self { Self { doc: [], children : [] } }

    unconstrained
    pub fn child(self, index : u8) -> [Property] { self.children[index] }

    unconstrained
    pub fn getObject<N>(self, key : str<N>) -> Option<[Property]>
    {
        let value = self.bytesOf(key);

        if (value.is_some()) { value.unwrap_unchecked().asObject(self) } else { Option::none() }
    }

    unconstrained
    pub fn print(self)
    {
        for prop in self.doc { prop.print(); }

        for i in 0..self.children.len()
        {
            dep::std::println(f"-- child #{i} --");
            for prop in self.children[i] { prop.print(); }
        }
    }
}
