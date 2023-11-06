mod globals;
mod parse;
mod convert;
mod utils;

use dep::std::option::Option;

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

type Object = [Property];

trait ObjectExtensions
{
    fn is_none(self : Object) -> bool;

    fn get_child_object<N>(self : Object, key : str<N>, parent : JSON) -> Option<Object>;
}

impl ObjectExtensions for Object
{
    unconstrained
    pub fn is_none(self) -> bool { if (self.len() == 1) { ((self[0].key.len() == 0) & (self[0].value.len() == 0)) } else { false } }

    unconstrained
    pub fn get_child_object<N>(self, key : str<N>, parent : JSON) -> Option<Object>
    {
        let value = self.get(key);

        if (value.is_some()) { value.unwrap_unchecked().as_object(parent) } else { Option::none() }
    }
}

struct JSON
{
    doc : Object
,   children : [Object]
}

impl JSON
{
    unconstrained
    fn none() -> Self { Self { doc: [], children : [] } }

    unconstrained
    pub fn child(self, index : u8) -> Object { self.children[index] }

    unconstrained
    pub fn get_object<N>(self, key : str<N>) -> Option<Object>
    {
        let value = self.get(key);

        if (value.is_some()) { value.unwrap_unchecked().as_object(self) } else { Option::none() }
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
