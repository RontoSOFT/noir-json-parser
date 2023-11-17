use dep::std::option::Option;

mod globals;
mod parse;
mod convert;
mod utils;

struct Property
{
    key : [u8],
    value : [u8],
}

struct Object
{
    parent : JSON
,   doc : [Property]
}

struct JSON
{
    doc : [Property]
,   children : [[Property]]
}

impl Property
{
    unconstrained
    fn none() -> Self { Self { key: [], value: [] } }

    unconstrained
    pub fn is_none(self) -> bool { (self.key.len() == 0) & (self.value.len() == 0) }

    unconstrained
    pub fn print(self)
    {
        dep::std::println("key");
        self.key.print();

        dep::std::println("value");
        dep::std::println("{");

        let size : Field = self.value.len();
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
                let s = crate::utils::chars[self.value[i]];
                dep::std::println(f"    {s}");
            }

            object_index = (self.value[i] == crate::globals::BEGIN_OBJECT);
        }

        dep::std::println("}");
    }
}

impl Object
{
    unconstrained
    fn none() -> Self { Self { parent: dep::std::unsafe::zeroed(), doc : [] } }

    unconstrained
    pub fn is_none(self) -> bool { self.doc.len() == 0 }

    unconstrained
    pub fn is_empty(self) -> bool { if (self.doc.len() == 1) { self.doc[0].is_none() } else { false } }

    unconstrained
    pub fn len(self) -> Field { self.doc.len() }

    unconstrained
    pub fn print(self) { for prop in self.doc { prop.print(); } }
}

impl JSON
{
    unconstrained
    fn none() -> Self { Self { doc: [], children : [] } }

    unconstrained
    pub fn is_none(self) -> bool { self.doc.len() == 0 }

    unconstrained
    pub fn is_empty(self) -> bool { if (self.doc.len() == 1) { self.doc[0].is_none() } else { false } }

    unconstrained
    pub fn len(self) -> Field { self.doc.len() }

    unconstrained
    pub fn child(self, index : u8) -> Object { Object { parent: self, doc: self.children[index] } }

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
