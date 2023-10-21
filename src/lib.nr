mod globals;
mod utils;
mod parse;
mod convert;

struct Property
{
    key : [u8],
    value : [u8],
}

struct JSON
{
    doc : [Property]
}

impl Property
{
    unconstrained
    fn none() -> Self { Self { key: [], value: [] } }

    unconstrained
    fn print(self)
    {
        dep::std::println("key"); self.key.print();
        dep::std::println("value"); self.value.print();
    }
}
