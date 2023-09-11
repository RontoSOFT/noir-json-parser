// Crash EXAMPLE 1

// struct PropertyValue<T>
// {
//     valid: bool,
//     value: T
// }

// type U32PropertyValue = PropertyValue<u32>; TODO: this crashes

// .. //


// Crash EXAMPLE 2

// unconstrained fn test1(value: Field)
// {
//     dep::std::println(value as u8); // 0x00
// }

// unconstrained fn test2(value: u8)
// {
//     dep::std::println(value);       // 0xff
// }

// #[test]
// fn test_crash()
// {
//     test1(-1);
//     test2(-1);
// }

// .. //



// Illegal definition EXAMPLE 1:

// let json = "{'name':'John Doe','age':\"30\",'isEmployed':true}";

// .. //

// Illegal definition EXAMPLE 1:

// struct ValueBytes<N>
// {
//     valid: bool,
//     bytes: [Field;N]
// }

// #[test]
// fn test_crash()
// {
//     let json = "{'name':'John Doe','age':30,'isEmployed':true}";
//     let json_bytes = json.as_bytes();
//     let expected = ValueBytes { valid: true, bytes: [0x33, 0x30]};

//     assert(getValueBytes(json_bytes, 24) == expected);    // Unsupported types for comparison: ValueBytes<2> and ValueBytes<_>
// }

// .. //

