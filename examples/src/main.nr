use dep::noir_json_parser;

// uncomment for crash examples
// mod crash_examples;

// uncomment for illegal (but valid?) syntax examples
// mod illegal_examples;

fn main()
{
    // let json = "{'age':'30''}";
    // let json = "{'name':'John Doe','age':30,'isEmployed':true}";
    let json = "{'name':'John Doe','age':30,'isEmployed':true,'salary':50000.75,'address':'0xd8da6bf26964af9d7eed9e03e53415d37aa96045'}";
    let prop_name = "age";

    let res = noir_json_parser::parsing::getValueU32(json, prop_name);
    dep::std::println(res);
}

#[test]
fn test_main()
{
    main();
}
