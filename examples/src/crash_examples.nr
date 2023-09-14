// EXAMPLE 1

fn test_Field(value: Field)
{
    dep::std::println(value as u8); // 0x00
}

fn test_u8(value: u8)
{
    dep::std::println(value);       // 0xff
}

fn test_u4(value: u4)
{
    dep::std::println(value);       // 0x0f
}

#[test]
fn test_crash()
{
    test_Field(-1);
    test_u8(-1);
    test_u4(-1);
}

// .. //
