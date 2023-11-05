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

trait ByteSliceExtensions
{
    fn eq(self, right : [u8]) -> bool;
    fn eq_array<N>(self, right : [u8; N]) -> bool;
    fn eq_string<N>(self, right : str<N>) -> bool;
    fn print(self);
    // fn to_array<N>(self) -> [u8; N];
}

impl ByteSliceExtensions for [u8]
{
    unconstrained
    pub fn eq(self, right : [u8]) -> bool
    {
        let N = self.len();
        let mut result = (N == right.len());
        if (result) { for i in 0..N { result &= (self[i] == right[i]); } }
        result
    }

    unconstrained
    pub fn eq_array<N>(self, right : [u8; N]) -> bool
    {
        let mut result = (self.len() == N);
        if (result) { for i in 0..N { result &= (self[i] == right[i]); } }
        result
    }

    unconstrained
    pub fn eq_string<N>(self, right : str<N>) -> bool { self.eq_array(right.as_bytes()) }

    unconstrained
    pub fn print(self)
    {
        dep::std::println("{");
        for byte in self { let s = chars[byte - 32]; dep::std::println(f"    {s}"); }
        dep::std::println("}");
    }

    // unconstrained
    // pub fn to_array<N>(self) -> [u8; N]
    // {
    //     let mut bytes : [u8; N] = [0; N];
    //     let mut len : u64 = (self.len() as u64);
    //     if (N < len) { len = N; }
    //     for i in 0..len { bytes[i] = self[i]; }
    //     bytes
    // }
}
