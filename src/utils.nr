global chars =
[
    "\0","\0","\0","\0","\0","\0","\0","\0","\0","\t","\n","\0","\0","\r","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0",
    " ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/",
    "0","1","2","3","4","5","6","7","8","9",
    ":",";","<","=",">","?","@",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "[","\\","]","^","_","`",
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
    "{","|","}","~"
];

trait ByteArrayEqualityExtension
{
    fn eq<N>(bytes : Self, right : [u8; N]) -> bool;
    fn less_than_or_eq<N>(bytes : Self, right : [u8; N]) -> (bool, bool);
}

trait ByteArrayExtensions
{
    fn eq_string<N>(bytes : Self, right : str<N>) -> bool;
    fn as_array<N>(bytes : [u8; N]) -> Self;
    fn print(bytes : Self);
}

impl<SIZE> ByteArrayEqualityExtension for str<SIZE>
{
    unconstrained
    pub fn eq<N>(string : Self, right : [u8; N]) -> bool { string.as_bytes().eq(right) }

    unconstrained
    pub fn less_than_or_eq<N>(string : Self, right : [u8; N]) -> (bool, bool) { string.as_bytes().less_than_or_eq(right) }
}

impl<SIZE> ByteArrayEqualityExtension for [u8; SIZE]
{
    unconstrained
    pub fn eq<N>(bytes : Self, right : [u8; N]) -> bool
    {
        let size : Field = bytes.len();
        let mut result = (size == right.len());
        if (result) { for i in 0..size { result &= (bytes[i] == right[i]); } }
        result
    }

    unconstrained
    pub fn less_than_or_eq<N>(bytes : Self, right : [u8; N]) -> (bool, bool)
    {
        let size_self : Field = bytes.len();
        let size_right : Field = right.len();

        if (size_self == size_right)
        {
            let mut less_than = false;
            let mut equal = true;
            for i in 0..size_self { if (equal & (bytes[i] != right[i])) { less_than = (bytes[i] < right[i]); equal = false; } }

            (less_than, equal)
        }
        else { (((size_self as u64) < (size_right as u64)), false) }
    }
}

impl<SIZE> ByteArrayExtensions for [u8; SIZE]
{
    unconstrained
    pub fn eq_string<N>(bytes : Self, right : str<N>) -> bool { right.eq(bytes) }

    unconstrained
    pub fn as_array<N>(bytes : [u8; N]) -> Self
    {
        let mut array : Self = [0; SIZE];
        let mut size : u64 = (bytes.len() as u64);
        if (SIZE < size) { size = SIZE; }
        for i in 0..size { array[i] = bytes[i]; }
        array
    }

    unconstrained
    pub fn print(bytes : Self)
    {
        dep::std::println("{");
        for byte in bytes { let c = chars[byte]; dep::std::println(f"    {c}"); }
        dep::std::println("}");
    }
}
