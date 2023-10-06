global chars =
[
    " ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/",
    "0","1","2","3","4","5","6","7","8","9",
    ":",";","<","=",">","?","@",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "[","\\","]","^","_","`",
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
    "{","|","}","~"
];

unconstrained
pub fn print_bytes<N>(label : str<N>, bytes : [u8])
{
    if (N != 0) { dep::std::println(label); }

    dep::std::println("{");
    for i in 0..bytes.len() { let s : str<1> = chars[bytes[i] - 32]; dep::std::println(f"    {s}"); }
    dep::std::println("}");
}

unconstrained
pub fn to_array<N>(sl : [u8]) -> [u8; N]
{
    let index = if ((N as u64) <= (sl.len() as u64)) { N } else { sl.len() };

    let mut bytes : [u8; N] = [0; N];
    for i in 0..index { bytes[i] = sl[i]; }
    bytes
}

trait ByteArraySliceEquality
{
    fn eq_array(self, right : [u8]) -> bool;
    fn eq_string(self, right : str) -> bool;
}

impl ByteArraySliceEquality for [u8]
{
    unconstrained
    pub fn eq_array<N>(self, right : [u8; N]) -> bool
    {
        if (self.len() != N) { false }
        else
        {
            let mut equal = true;
            for i in 0..N { equal &= (self[i] == right[i]); }
            equal
        }
    }

    unconstrained
    pub fn eq_string<N>(self, right : str<N>) -> bool
    {
        self.eq_array(right.as_bytes())
    }
}
