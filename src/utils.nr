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

unconstrained pub fn print_bytes<N>(label : str<N>, bytes : [u8])
{
    dep::std::println(label);
    dep::std::println("{");
    for j in 0..bytes.len() { let s = chars[bytes[j] - 32]; dep::std::println(f"    {s}"); }
    dep::std::println("}");
}

// converting negative Field or unsinged type values to signed integer
// value is first truncated to fit an unsiged 126 bit value
// then cast to a signed 127 bit value
unconstrained pub fn int127FromUnsigned(x: u126) -> i127 { x as i127 }
unconstrained pub fn int127FromField(x: Field) -> i127 { (x as u126) as i127 }
