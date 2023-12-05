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

trait ByteArrayComparisons
{
    fn eq<N>(self, other : [u8; N]) -> bool;
    fn less_than_or_eq<N>(self, other : [u8; N]) -> (bool, bool);
}

trait ByteArrayExtensions
{
    fn eq_string<N>(self, other : str<N>) -> bool;
    fn as_array<N>(bytes : [u8; N]) -> Self;
    fn print(self);
}

impl<SIZE> ByteArrayComparisons for str<SIZE>
{
    unconstrained
    pub fn eq<N>(self, other : [u8; N]) -> bool { self.as_bytes().eq(other) }

    unconstrained
    pub fn less_than_or_eq<N>(self, other : [u8; N]) -> (bool, bool) { self.as_bytes().less_than_or_eq(other) }
}

impl<SIZE> ByteArrayComparisons for [u8; SIZE]
{
    unconstrained
    pub fn eq<N>(self, other : [u8; N]) -> bool
    {
        let size : Field = self.len();
        let mut result = (size == other.len());
        if (result) { for i in 0..size { result &= (self[i] == other[i]); } }
        result
    }

    unconstrained
    pub fn less_than_or_eq<N>(self, other : [u8; N]) -> (bool, bool)
    {
        let size_self : Field = self.len();
        let size_right : Field = other.len();

        if (size_self == size_right)
        {
            let mut less_than = false;
            let mut equal = true;
            for i in 0..size_self { if (equal & (self[i] != other[i])) { less_than = (self[i] < other[i]); equal = false; } }

            (less_than, equal)
        }
        else { (((size_self as u64) < (size_right as u64)), false) }
    }
}

impl<SIZE> ByteArrayExtensions for [u8; SIZE]
{
    unconstrained
    pub fn eq_string<N>(self, other : str<N>) -> bool { other.eq(self) }

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
    pub fn print(self) { for byte in self { dep::std::print(chars[byte]); } }
}
