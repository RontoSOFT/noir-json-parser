use dep::noir::parse::JSON;
use dep::noir::convert::BytesU8;

// uncomment for crash examples
// mod crash_examples;

// uncomment for illegal (but valid?) syntax examples
// mod illegal_examples;

fn main()
{
    // let json = JSON::new("{'age':'30'}");
    // let json = JSON::new("{'name':'John Doe','age':30,'isEmployed':true}");
    let json = JSON::new("{'name':'John Doe','age':30,'isEmployed':true,'salary':50000.75,'address':'0xd8da6bf26964af9d7eed9e03e53415d37aa96045'}");
    let prop = "age";

    let bytes : BytesU8 = json.bytesOf(prop);

    dep::std::println( bytes.asField() );
}

#[test]
fn test_main()
{
    main();
}
