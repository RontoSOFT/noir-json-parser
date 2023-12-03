[![CI/CD](https://github.com/rontosoft/noir-json-parser/actions/workflows/main.yml/badge.svg)](https://github.com/rontosoft/noir-json-parser/actions/workflows/main.yml)

# Introduction

<p align="right">$''Don't\ panic\textit{!}\ Your\ JSON\ parsing\ journey\ is\ in\ good\ hands.''$</p>

Greetings!

Welcome to the `noir-json-parser`, an exclusive JSON parsing library meticulously crafted for the 🌌[Noir language](https://noir-lang.org/).
This library adheres to the revered [IETF RFC 8259](https://datatracker.ietf.org/doc/html/rfc8259) specifications, ensuring precise interpretation of JSON-friendly strings within the distinctive landscape of [Aztec](https://docs.aztec.network/)'s ZK-rollup ecosystem.

<br>

# Contents
- [Setup](#setup)
- [JSON Format Overview](#json-format-overview)
- [Project Organization](#project-organization)
    - [`globals.nr`](#globalsnr)
    - [`utils.nr`](#utilsnr)
    - [`lib.nr`](#libnr)
    - [`parse.nr`](#parsenr)
        - [Single value](#parse-example-1)
        - [Property (key) value](#parse-example-2)
    - [`convert.nr`](#convertnr)
        - [Simple Conversions](#simple-conversions)
            - [Single values](#convert-simple-example-1)
            - [Property (key) values](#convert-simple-example-2)
        - [Array Conversions](#array-conversions)
            - [Array as single value](#convert-array-example-1)
            - [Array with one object element](#convert-array-example-2)
            - [Array with multiple (empty) object elements](#convert-array-example-3)
            - [Nested arrays](#convert-array-example-4)
        - [Object Conversions](#object-conversions)
            - [Object with multiple keys and mixed values](#convert-object-example-1)
            - [Object with an object as value](#convert-object-example-2)
            - [Object with two keys with an object as value](#convert-object-example-3)
            - [Nested objects](#convert-object-example-4)
        - [Array and Object Conversions](#array-and-object-conversions)
            - [Object with mixed value type array as value](#convert-array-and-object-example-1)
            - [Object with an array containing two object elements as value](#convert-array-and-object-example-2)
- [Known Issues](#known-issues)

<br>
<br>

# Setup

<br>

1. 🧑‍🚀 Begin your preparation by creating a folder named `noir-json-parser`, which will serve as the parent for all projects: library, tests, and the (optional) examples.

    ```sh
    mkdir noir-json-parser
    cd noir-json-parser
    ```
<br>

2. 📡 Extend your comm links, connect the version control module and clone this repository under the name `lib`.

    ```sh
    git clone https://github.com/RontoSOFT/noir-json-parser lib
    ```

    Wield it further, cloning the [tests repository](https://github.com/RontoSOFT/noir-json-parser-tests) under the name `tests`.

    ```sh
    git clone https://github.com/RontoSOFT/noir-json-parser-tests tests
    ```

    [ *OPTIONAL* ] Clone the [examples repository](https://github.com/RontoSOFT/noir-json-parser-examples) in the same parent folder under the name `examples`.

    ```sh
    git clone https://github.com/RontoSOFT/noir-json-parser-examples examples
    ```
<br>

3. For smooth galactic sailing, you will need a ship 🚀. Enter [Nargo](https://noir-lang.org/getting_started/nargo_installation), the [Noir language](https://noir-lang.org/) compiler, your faithful companion on this journey. To use it, enable and run the [setup script](https://github.com/RontoSOFT/noir-json-parser/blob/main/scripts/setup.sh).

    ```sh
    chmod +x ./lib/scripts/setup.sh
    ./lib/scripts/setup.sh
    ```

<br>

4. The ship's systems need to be checked 💯 before blasting off into the great Void. Do that by running the `nargo test` command in the `tests` project directory.

    ```sh
    cd examples
    nargo test --show-output --silence-warnings
    ```

<br>

5. Grab your towel.

<br>
<br>

# JSON Format Overview

This project uses the [IETF RFC 8259](https://datatracker.ietf.org/doc/html/rfc8259) specification for interpreting JSON-friendly strings.

A [visual feast](https://www.json.org/json-en.html) of the format is also available for your ocular delight.

<br>

Seven tokens define structure in a JSON stream:

 Code              | Description          | Symbol | Unicode
:-|:-|:-:|:-:
 `BEGIN_OBJECT`    | Left curly brace     | `{` | 0x7B
 `END_OBJECT`      | Right curly brace    | `}` | 0x7D
 `BEGIN_ARRAY`     | Left square bracket  | `[` | 0x5B
 `END_ARRAY`       | Right square bracket | `]` | 0x5D
 `KEY_DELIMITER`   | Colon                | `:` | 0x3A
 `VALUE_DELIMITER` | Comma                | `,` | 0x2C
 `QUOTATION_MARK`  | Double quote         | `"` | 0x22

<br>

Whitespace characters are permitted before or after any of the seven structural tokens:

| | | | |
:-|:-|:-|:-:
 `TAB`     | Horizontal tab       | `\t` | 0x09
 `NEWLINE` | Line feed or Newline | `\n` | 0x0A
 `RETURN`  | Carriage return      | `\r` | 0x0D
 `SPACE`   | Empty space          | `  ` | 0x20


<br>

Five value types are recognized:

- `Object` - a list of comma-separated key/value pairs enclosed in a pair of curly braces `{` `}`.

    >**NOTE:** *A key is valid when it has at least one character.*<br>
    >**NOTE:** *Decisions regarding the significance of semantic ordering of the keys are left up to the implementer.*

<br>

- `Array` - a list of comma-separated values enclosed in a pair of square brackets `[` `]`, which can store values of any type, even mixed types, as well as nested arrays.

<br>

- `String` - enclosed in double quotation marks `"`, allowing (some) escaping via the backslash `\` token, and single quote tokens `'`.

<br>

- `Number` - expressed using the [scientific notation](https://www.mathsisfun.com/numbers/scientific-notation.html): a mandatory integer component that may be prefixed with an optional minus `-`, followed by an optional fraction part (defined by a point `.` and a mandatory integer component) and/or an exponent part (defined by an `e` or `E` token, an optional `+` or `-`, and a mandatory integer component).

    >**NOTE:** *Octal or hexadecimal forms, leading zeros, or special numeric values like `Infinity` or `NaN` are prohibited.*<br>
    >**NOTE:** *Floating point arithmetic is missing from Noir. While conversions are out-of-scope, floating point numbers are parsed and can be checked for equality of byte values.*

<br>

- `Literal` - specified in lowercase, with three acceptable values:
   - `false` - [ 0x66, 0x61, 0x6C, 0x73, 0x65 ]
   - `null` - [ 0x6E, 0x75, 0x6C, 0x6C]
   - `true` - [ 0x74, 0x72, 0x75, 0x65]

<br>
<br>

# Project Organization

<p align="right">$''Time\ spent\ on\ JSON\ parsing\ is\ an\ illusion.\ It\ feels\ like\ forever,\ especially\ during\ debugging.''$</p>

<a id="globalsnr"></a>

### [`globals.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/globals.nr)

Behold the foundation-shaping constants of JSON token interpretation! Your *other* faithful companions throughout the entire project.

<br>

### <a id="utilsnr"></a> [`utils.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/utils.nr)

Extend your toolbelt with methods enabling seamless comparison, casting, and printing of byte slices. These functions enhance your experience with precision and clarity.

```rust
trait ByteArrayComparisons
{
    fn eq<N>(self, other : [u8; N]) -> bool;
    fn less_than_or_eq<N>(self, other : [u8; N]) -> (bool, bool);
}

trait ByteArrayExtensions
{
    fn eq_string<N>(self, other : str<N>) -> bool;
    fn as_array<N>(bytes : [u8; N]) -> Self;
    fn print(self); // prints first 127 codepoints of the ASCII table
}
```

<br>

<a id="libnr"></a>

### [`lib.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/lib.nr)

Discover the heart of the implementation through the elegant structures and extensions concealed within.

<br>

Behold the left ventricle -- the [`Property`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/lib.nr#L6) struct:

```rust
struct Property
{
    key : [u8]
,   value : [u8]
}
```

>**NOTE:** *Functions operating on instances of this struct need to be tagged with the `unconstrained` attribute.*

<br>

Further on, the [`JSON`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/lib.nr#L14) struct uses slices of `Property` instances (aliased as `Object`) to store data:

```rust
type Object = [Property];

struct JSON
{
    doc : Object
,   children : [Object]
}
```

A `JSON` instance is generated by parsing a string (or byte array/slice) directly or by accessing the `children` property on an existing instance via the `child` method detailed below.

>**NOTE:** *Duplicated keys with value types <u>other than object</u> will have their bytes replaced in the `doc` property. For example, parsing the string `{"a": 1, "a": true}` populates the `doc` property with a single element: key bytes `a` and value bytes `true`.*<br>
>**NOTE:** *Duplicated keys with value type of <u>object</u> will store **all** the provided objects in the `children` property. For example, parsing the string `{ "a": {"key": "value"}, "a": {} }` populates the `children` property with two elements: the object `{ "key": "value" }` and an empty object `{}`.*

<br>

A JSON can be conceptualized as a tree: the root object can encompass child objects, and the children may, in turn, have nested objects of their own.

Owing to [this bug](#known-issues-2) that hampers self-referential structs in Noir, this implementation stores all of the child object instances in the `children` property of the root `JSON` instance, including those of the nested children.

In essence, this is a straightforward list. The object indices are stored in the value bytes as `{` `index: u8` `}`.

A hypothetical first child object would have a value slice of three elements: `{`, `0`, and `}`. A second child would contain the elements `{`, `1`, `}`, the third `{`, `2`, `}`, and so on. This property is meant to be accessed via the `child` method:

```rust
impl JSON
{
    fn child(self, index : u8) -> JSON { JSON { doc: self.children[index], children: self.children } }
}
```

<br>

A few extensions are provided to ease testing and debugging:

```rust
trait Extensions
{
    fn none() -> Self;          // creates an empty instance
    fn len(self) -> Field;
    fn is_none(self) -> bool;   // has 0 elements
    fn is_empty(self) -> bool;  // has 1 element with an empty key and empty value representing the empty object
    fn print(self);             // prints contents by mapping bytes to the first 127 codepoints of the ASCII table
}

impl Extensions for Object     { /* .. */ }
impl Extensions for JSON       { /* .. */ }
```

<br>

<a id="parsenr"></a>

<p align="right">$''Anyone\ capable\ of\ parsing\ complex\ JSON\ structures\ should\ on\ NO\ account\ be\ discouraged\ –\ it's\ part\ of\ the\ job\textit{!}\ ''$</p>

### [`parse.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/parse.nr)

Concealed under this banner is the discreet orchestration of the JSON parsing logic.

```rust
impl JSON
{
    fn parse<N>(string: str<N>) -> Self      { /* .. */ }          // wrap ByteArrayParser method
    fn store(self, prop: Property) -> Object { /* .. */ }          // private; stores (or replaces) a property's value bytes
    fn get<N> (self, key: str<N>) -> [u8]    { self.doc.get(key) } // wrap PropertyLookup trait getter
}

trait PropertyLookup
{
    fn get<N> (self, key: str<N>) -> [u8]; // lookup a key and return associated value's bytes

    fn linear_search<N>(self, key: [u8; N], index: Field) -> [u8]; // private
    fn binary_search<N>(self, key: [u8; N], begin: Field, end : Field) -> [u8]; // private
}

trait ByteArrayParser
{
    fn parse_list(self) -> [[u8]];  // private; parses array inputs
    fn parse(self, begin: &mut Field, end: Field, child_index: Field) -> JSON; // main parser logic
}

impl PropertyLookup for Object { /* .. */ }

impl<N> ByteArrayParser for [u8; N] { /* .. */ }
```

The [`ByteArrayParser::parse`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/parse.nr#L160) function serves as the linchpin, accepting a byte array and giving rise to a JSON list-tree. It is wrapped over by `JSON::parse` to allow natural parsing of `str` types.

Complications arise from [a known bug](#known-issues-1) hindering the re-assignment of nested slice members, while also rendering binary searching and sorting infeasible. Consequently, parsing employs a linear approach for insertion and retrieval until a solution for the issue is found.

Parsing unfolds iteratively until a secondary `{` token is detected. When spotted, the `child_index` parameter is set and stored as `{` `child_index` `}` in the value bytes of the current key, and the input bytes undergo recursive parsing.

If the child object being parsed has nested objects in turn, they are also parsed recursively. The resulting `Object` instances (references) are moved to the root `JSON` instance's `children` property.

When child object parsing concludes, the process reverts to an iterative mode, resuming at the index represented by the value of the `begin` parameter. Its type is a mutable reference precisely to prevent double iteration of input bytes.

>**NOTE:** *It is planned for the `begin` parameter to contain the error's position (if any) in the input bytes upon completion of execution.*

<br>

### Examples

#### Single value <a id="parse-example-1"></a>

```rust
unconstrained
fn parse_value()
{
    let value = "100";

    let json = JSON::parse(value);

    let bytes = json.get("");
    // or
    let bytes = json.doc[0].value; // useful when the index is known, as it skips lookup

    bytes.print(); // prints "{ 100 }" (slice contents)

    assert(bytes.eq_string(value) == true);
    // or
    assert(value.eq(bytes) == true);
    // or
    assert(bytes.eq(value.as_bytes()) == true);
}
```

<br>

#### Property (key) value <a id="parse-example-2"></a>

```rust
unconstrained
fn parse_property()
{
    let (key, value) = ("my_key", "100");

    let json = JSON::parse(r#"{"my_key" : 100}"#);

    let bytes = json.get(key);

    bytes.print(); // prints "{ 100 }" (slice contents)

    assert(bytes.eq_string(value) == true);
    // or
    assert(value.eq(bytes) == true);
    // or
    assert(bytes.eq(value.as_bytes()) == true);
}
```

<br>

<a id="convertnr"></a>

<p align="right">$''Slices\ of\ bytes,\ like\ quantum\ kittens,\ yearn\ for\ a\ coherent\ state.''$</p>

### [`convert.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/convert.nr)

Methods meticulously crafted for the seamless transformation of byte-encoded slice representations into their inherent native types.

Deliberately engineered to accommodate diverse formats, these functions elegantly employ the safety net of `Option<T>`. This judicious choice ensures error handling for types that lack a straightforward concept of "empty", such as numbers and booleans. For objects, arrays, and strings, an empty slice instance `[]` is returned.

<br>

```rust
trait FieldConversion
{
    fn get_whole(self, begin : Field, end : Field) -> Field; // converts a stream of digit bytes to Field
    fn get_offsets(self) -> [Field; 5]; // separates a scientific notation digit stream into constituent parts" (whole, fractional, exponent) index offsets
}

trait ByteArrayConversions
{
    fn as_bool(self) -> Option<bool>;
    fn as_field(self) -> Option<Field>;
    fn as_string(self) -> [u8];
    fn as_list(self) -> [[u8]];
    fn as_json(self) -> JSON;
}
```

>**NOTE:** *These methods work even when the input byte stream is flanked by quotes. Casting `"true"` with `as_bool` returns the `bool` value `true`. Casting `"125"` with `as_field` returns the `Field` value `125`.*

<br>

Wrapping over these methods for the `str` native type to ease development:

```rust
impl<N> ByteArrayConversions for str<N>
{
    fn as_bool(self) -> Option<bool>   { self.as_bytes().as_bool() }
    fn as_field(self) -> Option<Field> { self.as_bytes().as_field() }
    fn as_string(self) -> [u8]         { self.as_bytes().as_string() }
    fn as_list(self) -> [[u8]]         { self.as_bytes().as_list() }
    fn as_json(self) -> JSON           { self.as_bytes().as_json() }
}
```

<br>

The `convert` module further extends `JSON` to leverage the `ByteArrayConversions` trait extensions, connecting them with `get` from the `PropertyLookup` trait, via the `doc` property, to further simplify development:

```rust
impl JSON
{
    fn get_bool<N>  (self, key : str<N>) -> Option<bool>  { self.doc.get(key).as_bool() }
    fn get_field<N> (self, key : str<N>) -> Option<Field> { self.doc.get(key).as_field() }
    fn get_string<N>(self, key : str<N>) -> [u8]          { self.doc.get(key).as_string() }
    fn get_array<N> (self, key : str<N>) -> [[u8]]        { self.doc.get(key).as_list() }
    fn get_object<N>(self, key : str<N>) -> JSON          { /* .. */ }
}
```

<br>

### Simple Conversions

```rust
fn as_bool(self) -> Option<bool>
```

Converts *"null"* and *"false"* as the native boolean `false`, and *"true"* as the native boolean `true`, wrapped as `Option<bool>` for handling invalid inputs.

<br>

```rust
fn as_field(self) -> Option<Field>
```

Like an alchemist, it transforms digit stream representations of numbers in the language of [scientific notation](https://www.mathsisfun.com/numbers/scientific-notation.html) to the native `Field` type, also wrapped as `Option<Field>` for invalid input handling.

>**NOTE:** *Floating point support is missing from Noir. When encountering a decimal point separator token `.` the method returns `Option::none()`, even if the input byte stream is valid.*

<br>

```rust
fn as_string(self) -> [u8]
```
The minimalist poet of conversions! It removes quotes `"` `"` from surrounding a value's bytes and returns the result as a slice of bytes. Quote-less inputs return an empty slice `[]`.
For example, a stream such as `"my_string"` will be returned as `my_string`. Further casting that `as_string` will return `[]`.

<br>

### Examples

#### Single values <a id="convert-simple-example-1"></a>

```rust
unconstrained
fn convert_values()
{
    assert("false".as_bool().unwrap() == false);
    assert("100".as_field().unwrap() == 100);
    assert("\"my_string\"".as_string().eq_string("my_string") == true);

    // or

    assert(JSON::parse("false").doc[0].value.as_bool().unwrap() == false);
    assert(JSON::parse("100").doc[0].value.as_field().unwrap() == 100);
    assert(JSON::parse("\"my_string\"").doc[0].value.as_string().eq_string("my_string") == true);

    // or

    assert(JSON::parse("false").get_bool("").unwrap() == false);
    assert(JSON::parse("100").get_field("").unwrap() == 100);
    assert(JSON::parse("\"my_string\"").get_string("").eq_string("my_string") == true);
}
```

<br>

#### Property (key) values <a id="convert-simple-example-2"></a>

```rust
unconstrained
fn convert_properties()
{
    let json = JSON::parse(r#"{ "a": false, "b": 100, "c": "my_string" }"#);

    assert(json.get_bool("a").unwrap() == false);
    assert(json.get_field("b").unwrap() == 100);
    assert(json.get_string("c").eq_string("my_string") == true);
    // or
    assert("my_string".eq(json.get_string("c")) == true);

    // or

    assert(json.get("a").as_bool().unwrap() == false);
    assert(json.get("b").as_field().unwrap() == 100);
    assert(json.get("c").eq_string("\"my_string\"") == true);
    // or
    assert("\"my_string\"".eq(json.get("c")) == true);
}
```

<br>

### Array Conversions

<p align="right">$''Array,\ you're\ turning\ into\ an\ object.\ Stop\ it\textit{!}\ ''$</p>

```rust
fn as_list(self) -> [[u8]]
```

Converts the input stream to a slice-of-slices when surrounded by `[` `]`, otherwise returns an empty slice.

Its intended use is on pre-processed byte streams, which are members of a `JSON` instance resulting from a `parse` or `as_json` call.

In opposition to other converting functions, this method has more restrictions on the input. Values must be separated by comma tokens `,` and **whitespaces are prohibited**. It also **assumes the values are well-specified**, hence the need for using pre-parsed inputs.

When needing to convert a stream of bytes that is constructed manually or resulted from operations other than parsing, first parse it using `as_json`, then call `as_list`.

For example, `"[invalid]".as_list()` will create a list `[[invalid]]` and that is not intented.
The correct call is `"[invalid]".as_json().as_list()`, and this will return an empty slice `[]` due to parsing error.

>**NOTE:** *Custom input byte streams defining arrays that contain elements of `object` type **must** be parsed using `as_json`.*

<br>

### Examples <a id="convert-array-examples"></a>

#### Array as single value <a id="convert-array-example-1"></a>

```rust
unconstrained
fn convert_value_array()
{
    let array : [[u8]] = "[1,2,3]".as_list(); // the input bytes are well-formed, otherwise pre-parse them with as_json

    assert(array.len() == 3);
    assert(array[0].as_field().unwrap() == 1);
    assert(array[1].as_field().unwrap() == 2);
    assert(array[2].as_field().unwrap() == 3);
}
```

<br>

#### Array with one object element <a id="convert-array-example-2"></a>

```rust
unconstrained
fn convert_array_one_object()
{
    let json = JSON::parse("[{\"a\":1}]");
    // or
    let json = "[{\"a\":1}]".as_json(); // as_list won't work with nested objects in arrays, except when bytes are parsed beforehand OR objects are empty

    assert(json.doc.len() == 1);
    assert(json.children.len() == 1);

    let array = json.get_array("");
    // or
    let array = json.doc[0].value.as_list();

    let child = json.child(array[0][1]); // array contents are {, 0, }
    // or
    let child = json.child(0); // when index is known

    assert(child.len() == 1);
    assert(json.child(0).get_field("a").unwrap() == 1);
}
```

<br>

#### Array with multiple (empty) object elements <a id="convert-array-example-3"></a>

```rust
unconstrained
fn convert_array_empty_objects()
{
    let array = "[{},{},{}]".as_list(); // OK to split arrays with just empty objects; otherwise call as_json first, see example above

    // these calls trigger a parse underneath
    assert(array[0].as_json().is_empty() == true);
    assert(array[1].as_json().is_empty() == true);
    assert(array[2].as_json().is_empty() == true);

    // or

    let json = JSON::parse("[{},{},{}]");

    assert(json.doc.len() == 1);
    assert(json.children.len() == 3);

    // as opposed to the above, no further parsing is needed
    assert(json.child(0).is_empty() == true);
    assert(json.child(1).is_empty() == true);
    assert(json.child(2).is_empty() == true);
}
```

<br>

#### Nested arrays <a id="convert-array-example-4"></a>

```rust
unconstrained
fn convert_value_array_nested()
{
    let array : [[u8]] = "[[1,3],[2,4]]".as_list();

    assert(array.len() == 2);

    let sub_array_1 : [[u8]] = array[0].as_list();
    assert(sub_array_1.len() == 2);
    assert(sub_array_1[0].as_field().unwrap() == 1);
    assert(sub_array_1[1].as_field().unwrap() == 3);

    let sub_array_2 : [[u8]] = array[1].as_list();
    assert(sub_array_2.len() == 2);
    assert(sub_array_2[0].as_field().unwrap() == 2);
    assert(sub_array_2[1].as_field().unwrap() == 4);
}
```

<br>

### Object Conversions

<p align="right">$''Objects\ are\ like\ therapists,\ helping\ data\ cope\ with\ the\ existential\ crisis\ of\ parsing\ and\ interpretation.''$</p>

```rust
fn as_json(self) -> JSON
```

Converts the input byte stream to a `JSON` by parsing it.

Due to an extra check for input size being used to handle conversion of objects which are _quoted_, it is recommended to use `JSON::parse` for _quote-less_ input strings over `as_json`.

<br>

### Examples

#### Object with multiple keys and mixed values <a id="convert-object-example-1"></a>

```rust
unconstrained
fn convert_simple_object()
{
    let json = JSON::parse(r#"{ "name": "John Doe", "age": 30, "isEmployed": true, "pin": [1, "2", false], "location": { 'state": "Arizona", "code": "AZ" } }"#);

    // Get a byte slice representing a string
    let a_string = json.get_string("name");
    assert(a_string.eq_string("John Doe") == true);

    // Get a byte slice representing a number
    let a_field = json.get_field("age").unwrap();
    assert(a_field == 30);

    // Get a byte slice representing a literal
    let a_bool = json.get_bool("isEmployed").unwrap();
    assert(a_bool == true);

    // Get a slice of byte slices representing an array
    let a_array = json.get_array("pin");
    assert(a_array.len() == 3);

    // Convert array byte slice values as needed
    assert(a_array[0].as_field().unwrap() == 1);
    assert(a_array[1].eq_string("\"2\"") == true);
    assert(a_array[2].as_bool().unwrap() == false);

    // Get a slice of byte slices representing an object
    let a_object = json.get_object("location");
    assert(a_object.len() == 2);

    // Convert child object property value byte slices as needed
    assert(a_object.get_string("state").eq_string("Arizona") == true);
    assert(a_object.get_string("code").eq_string("AZ") == true);
}
```

<br>

#### Object with an object as value <a id="convert-object-example-2"></a>

```rust
unconstrained
fn convert_object()
{
    let json = JSON::parse(r#"{"ABC":{"a":1, "b": true, "c": "123"}}"#);
    // or
    let json = r#"{"ABC":{"a":1, "b": true, "c": "123"}}"#.as_json();

    let obj = json.get_object("ABC");
    assert(obj.get("a").eq_string("1") == true);
    assert(obj.get("b").eq_string("true") == true);
    assert(obj.get("c").eq_string("\"123\"") == true);
}
```

<br>

#### Object with two keys with an object as value <a id="convert-object-example-3"></a>

```rust
unconstrained
fn convert_two_objects()
{
    let json = JSON::parse(r#"{"obj1":{"a":1,"b":true},"obj2":{"c":"my_string"}}"#);
    // or
    let json = r#"{"obj1":{"a":1,"b":true},"obj2":{"c":"my_string"}}"#.as_json();

    let obj_1 = json.get_object("obj1");
    assert(obj_1.get("a").eq_string("1") == true);
    assert(obj_1.get("b").eq_string("true") == true);

    let obj_2 = json.get_object("obj2");
    assert(obj_2.get_string("c").eq_string("my_string") == true);
}
```

<br>

#### Nested objects <a id="convert-object-example-4"></a>

```rust
unconstrained
fn convert_two_nested_objects()
{
    let json = JSON::parse(r#"{"ABC":{"a":{"b":1}},"DEF":{"d":{"e":2}}}"#);

    assert(json.get_object("ABC").get_object("a").get("b").eq_string("1") == true);
    assert(json.get_object("DEF").get_object("d").get("e").eq_string("2") == true);
}
```
<br>

### Array and Object Conversions

The examples below illustrate the delicate interplay between array and objects.

<br>

#### Object with mixed value type array as value <a id="convert-array-and-object-example-1"></a>

```rust
unconstrained
fn convert_object_value_mixed_type_array()
{
    let json = JSON::parse(r#"{ "a": [true, 2, "my_string", 10.35e+5, null] }"#);
    let array : [[u8]] = json.get_array("a");

    assert(array.len() == 5);

    assert(array[0].as_bool().unwrap() == true);
    assert(array[1].as_field().unwrap() == 2);
    assert(array[2].as_string().eq_string("my_string") == true);
    assert(array[3].eq_string("10.35e+5")); // floating-point values are comparable by equality only
    assert(array[4].as_bool().unwrap() == false);
}
```

<br>

#### Object with an array containing two object elements as value <a id="convert-array-and-object-example-2"></a>

```rust
unconstrained
fn convert_object_array_two_objects()
{
    let json = JSON::parse(r#"{ "ABC": [{ "a": 1, "b": true }, { "c": "456" }] }"#);
    let array : [[u8]] = json.get_array("ABC");

    let obj_1 = json.child(array[0][1]);
    assert(obj_1.get_field("a").unwrap() == 1);
    assert(obj_1.get_bool("b").unwrap() == true);

    let obj_2 = json.child(array[1][1]);
    assert(obj_2.get_field("c").unwrap() == 456); // works even though the value of key "c" is a string
}
```

<br>
<br>

# Known Issues

1. <div id="known-issues-1">See <a href="https://github.com/noir-lang/noir/issues/3637">this issue</a> where changing the instance referred to by member slices of structs inside slices leads to corruption of memory.</div>

1. <div id="known-issues-2">See <a href="https://github.com/noir-lang/noir/issues/3490">this issue</a> covering self referential structs.</div>

1. <div id="known-issues-3">Floating point arithmetic is missing from Noir. Pending a solution. See (this repo)[!LINK!].</div>


<br>
<br>

# Contributing

Get in touch with the owners via [Noir Discord](https://discord.gg/JtqzkdeQ6G) to be added as a collaborator.

Use the hashtag `noir-json-parser`.


<br>
<br>
<br>

<p align="right">$''As\ you\ journey\ through\ the\ galaxy\, remember\textit{:}\ a\ towel\ might\ be\ useful,\ but\ a\ well\textit{-}parsed\ JSON\ is\ \underline{indispensable}\textit{!}\ ''$</p>
