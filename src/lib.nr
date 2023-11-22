mod globals;
mod parse;
mod convert;
mod utils;

struct Property
{
    id : Field, // u127
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

trait Extensions
{
    fn none() -> Self;
    fn len(self) -> Field { self.doc.len() }
    fn is_none(self) -> bool { self.len() == 0 }
    fn is_empty(self) -> bool { self.doc.is_empty() }
    fn print(self);
}

impl Property
{
    unconstrained
    fn none() -> Self { Self { id : 0, value: [] } }

    unconstrained
    pub fn is_none(self) -> bool { (self.id == 0) & (self.value.len() == 0) }

    unconstrained
    pub fn print(self) { self.print_index(0); }

    unconstrained
    fn print_index(self, index: Field)
    {
        dep::std::println(f"key {index}");
        dep::std::println(self.id);
        // self.key.print();

        dep::std::println("value");
        dep::std::println("{");

        let mut object = false;
        for byte in self.value
        {
            if (object & (byte != globals::END_OBJECT) & (byte != globals::BACKSLASH))
            {
                dep::std::println(f"        {byte}");
            }
            else
            {
                let c = utils::chars[byte];
                dep::std::println(f"    {c}");

                object = (byte == globals::BEGIN_OBJECT);
            }
        }

        dep::std::println("}");
    }
}

impl Extensions for [Property]
{
    unconstrained
    fn none() -> Self { [] }

    unconstrained
    pub fn is_none(self) -> bool { self.len() == 0 }

    unconstrained
    pub fn len(self) -> Field { self.len() }

    unconstrained
    pub fn is_empty(self) -> bool { if (self.len() == 1) { self[0].is_none() } else { false } }

    unconstrained
    pub fn print(self) { for i in 0..self.len() { self[i].print_index(i); } }
}

impl Extensions for Object
{
    unconstrained
    fn none() -> Self { Self { parent: dep::std::unsafe::zeroed(), doc : [] } }

    unconstrained
    pub fn print(self) { self.doc.print(); }
}

impl Extensions for JSON
{
    unconstrained
    fn none() -> Self { Self { doc: [], children : [] } }

    unconstrained
    pub fn print(self)
    {
        self.doc.print();

        for i in 0..self.children.len()
        {
            dep::std::println(f"-- child {i} --");
            for prop in self.children[i] { prop.print(); }
        }
    }
}

impl JSON
{
    unconstrained
    pub fn child(self, index : u8) -> Object { Object { parent: self, doc: self.children[index] } }
}
