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
    fn eq_string(bytes : [u8], right : str) -> bool;
    fn into_array(bytes : [u8]) -> Self;
    fn print(bytes : Self);
}

impl<SIZE> ByteArrayEqualityExtension for [u8; SIZE]
{
    unconstrained
    pub fn eq<N>(bytes : Self, right : [u8; N]) -> bool
    {
        let size = bytes.len();
        let mut result = (size == right.len());
        if (result) { for i in 0..size { result &= (bytes[i] == right[i]); } }
        result
    }

    unconstrained
    pub fn eq_string(bytes : [u8], right : str<SIZE>) -> bool { bytes.eq(right.as_bytes()) }

    unconstrained
    pub fn into_array(bytes : [u8]) -> Self
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
