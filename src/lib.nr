mod globals;
mod parse;
mod convert;
mod utils;

struct Property
{
    key : [u8]
,   value : [u8]
}

type Object = [Property];

struct JSON
{
    doc : Object
,   children : [Object]
}

trait Extensions
{
    fn none() -> Self;
    fn is_none(self) -> bool;
    fn is_empty(self) -> bool;
    fn print(self);
}

impl Property
{
    unconstrained
    fn none() -> Self { Self { key: [], value: [] } }

    unconstrained
    pub fn is_none(self) -> bool { (self.key.len() == 0) & (self.value.len() == 0) }

    unconstrained
    pub fn print(self) { self.print_index(0); }

    unconstrained
    fn print_index(self, index: Field)
    {
        dep::std::print("    \"");
        self.key.print();
        dep::std::print("\": ");

        let mut object = false;
        for byte in self.value
        {
            if (object & (byte != globals::END_OBJECT) & (byte != globals::BACKSLASH))
            {
                dep::std::print(byte);
            }
            else
            {
                dep::std::print(utils::chars[byte]);

                object = (byte == globals::BEGIN_OBJECT);
            }
        }

        dep::std::println("");
    }
}

impl Extensions for Object
{
    unconstrained
    fn none() -> Self { [] }

    unconstrained
    pub fn is_none(self) -> bool { self.len() == 0 }

    unconstrained
    pub fn is_empty(self) -> bool { if (self.len() == 1) { self[0].is_none() } else { false } }

    unconstrained
    pub fn print(self)
    {
        dep::std::println("{");
        for i in 0..self.len() { self[i].print_index(i); }
        dep::std::println("}");
    }
}

impl Extensions for JSON
{
    unconstrained
    fn none() -> Self { Self { doc: [], children : [] } }

    unconstrained
    pub fn is_none(self) -> bool { self.doc.len() == 0 }

    unconstrained
    pub fn is_empty(self) -> bool { self.doc.is_empty() }

    unconstrained
    pub fn print(self)
    {
        dep::std::println("\ndoc");
        self.doc.print();
        dep::std::println("");

        for i in 0..self.children.len()
        {
            let i : u64 = i as u64;
            dep::std::println(f"-- {{i}} --");
            self.children[i].print();
        }
    }
}

impl JSON
{
    unconstrained
    pub fn child(self, index : u8) -> JSON { JSON { doc: self.children[index], children: self.children } }
}
