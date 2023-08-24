use dep::std;

fn parse_json<N>(aStr : str<N>) {
    std::println(aStr);

    let size = N;
    std::println(size);

    let str_bytes = aStr.as_bytes();
    std::println(str_bytes);
    for i in str_bytes//0..size
    {
        // std::println(aStr[i]);
        std::println(i);
    }
}

fn main()
{
    parse_json("abcde");
}

#[test]
fn test_main() {
    main();
    // main(["a", "b", "c", "d", "e"]);
}
