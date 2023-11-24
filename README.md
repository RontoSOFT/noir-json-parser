[![CI/CD](https://github.com/rontosoft/noir-json-parser/actions/workflows/main.yml/badge.svg)](https://github.com/rontosoft/noir-json-parser/actions/workflows/main.yml)

<style>
  .grid {
    display: grid;
    grid-template-columns: 2fr 2fr 1fr 1fr;
    text-align: center;
    width: 500px;
  }

  .header {
    border: 1px solid #AAA;
    padding: 6px;
    font-weight: bold;
  }

  .row {
    border: 1px outset #666;
    padding: 6px;
    display: flex;

    justify-content: left;
    align-items: left;
  }

  .center {
    justify-content: center;
    align-items: center;
  }

</style>

# noir-json-parser

Welcome!

This is a JSON parsing library designed specifically for the Noir language.

It follows the [IETF RFC 8259](https://datatracker.ietf.org/doc/html/rfc8259) specification for interpreting JSON-friendly strings. The library provides a set of functionalities to parse JSON strings and convert them into a structured format within Noir.

<br>

# Table of Contents
- [Setup](#setup)
- [JSON Format Overview](#json-format-overview)
   - [Structural Characters](#structural-characters)
   - [Whitespaces](#whitespaces)
   - [Value Types](#value-types)
- [Project Structure](#project-structure)
   - [`globals.nr`](#globalsnr)
   - [`utils.nr`](#utilssnr)
   - [`lib.nr`](#libnr)
   - [`parse.nr`](#parsenr)
     - [Examples](#examples2)
   - [`convert.nr`](#convertnr)
        - [Simple Conversions](#simple-conversions) and [Examples](#convert-simple-examples)
        - [Array and Object Conversions](#array-and-object-conversions) and [Examples](#convert-array-object-examples)
- [Known Issues](#known-issues)

<br>

# Setup

1. Create a folder named `noir-json-parser`. This will be the parent of both projects (the library and these examples).

    ```sh
    mkdir noir-json-parser
    cd noir-json-parser
    ```

2. Clone this repository in the same parent folder under the name `lib`.

    ```sh
    git clone https://github.com/RontoSOFT/noir-json-parser lib
    ```

3. Clone the [tests repo](https://github.com/RontoSOFT/noir-json-parser-tests) in the parent folder under the name `tests`.

    ```sh
    git clone https://github.com/RontoSOFT/noir-json-parser-tests tests
    ```

4. [ *OPTIONAL* ] Clone the [examples repository](https://github.com/RontoSOFT/noir-json-parser-tests) in the same parent folder under the name `examples`.

    ```sh
    git clone https://github.com/RontoSOFT/noir-json-parser-examples examples
    ```

5. Install the Noir language [compiler](https://github.com/noir-lang/noir/releases) (see [here](https://noir-lang.org/getting_started/nargo_installation)). The version used for this project is specified in [Nargo.toml](https://github.com/RontoSOFT/noir-json-parser/blob/main/Nargo.toml).

6. Run the `noir test` command in the `tests` project directory.

    ```sh
    cd examples
    nargo test --show-output --silence-warnings
    ```

<br>
<br>

# JSON Format Overview

This project uses the [IETF RFC 8259](https://datatracker.ietf.org/doc/html/rfc8259) specification for intepreting JSON-friendly strings.

A [visual presentation](https://www.json.org/json-en.html) of the format is also available for your reference.

<br>

Six tokens define structure in a JSON stream:

<div class="grid">
  <div class="row"><code>BEGIN_ARRAY</code></div>
  <div class="row">Left square bracket</div>
  <div class="row center"><b>[</b></div>
  <div class="row center">0x5B</div>
</div>
<div class="grid">
  <div class="row"><code>BEGIN_OBJECT</code></div>
  <div class="row">Left curly brace</div>
  <div class="row center"><b>{</b></div>
  <div class="row center">0x7B</div>
</div>
<div class="grid">
  <div class="row"><code>END_ARRAY</code></div>
  <div class="row">Right square bracket</div>
  <div class="row center"><b>]</b></div>
  <div class="row center">0x5D</div>
</div>
<div class="grid">
  <div class="row"><code>END_OBJECT</code></div>
  <div class="row">Right curly brace</div>
  <div class="row center"><b>}</b></div>
  <div class="row center">0x7D</div>
</div>
<div class="grid">
  <div class="row"><code>KEY_DELIMITER</code></div>
  <div class="row">Colon</div>
  <div class="row center"><b>:</b></div>
  <div class="row center">0x3A</div>
</div>
<div class="grid">
  <div class="row"><code>VALUE_DELIMITER</code></div>
  <div class="row">Comma</div>
  <div class="row center"><b>,</b></div>
  <div class="row center">0x2C</div>
</div>

<br>

<br>

Whitespace characters are permitted before or after any of the six structural tokens:

<div class="grid">
  <div class="row"><code>TAB</code></div>
  <div class="row">Horizontal tab</div>
  <div class="row center"><b>\t</b></div>
  <div class="row center">0x09</div>
</div>
<div class="grid">
  <div class="row"><code>NEWLINE</code></div>
  <div class="row">Line feed or Newline</div>
  <div class="row center"><b>\n</b></div>
  <div class="row center">0x0A</div>
</div>
<div class="grid">
  <div class="row"><code>RETURN</code></div>
  <div class="row">Carriage return</div>
  <div class="row center"><b>\r</b></div>
  <div class="row center">0x0D</div>
</div>
<div class="grid">
  <div class="row"><code>SPACE</code></div>
  <div class="row">Empty space </div>
  <div class="row center"><p style="background-color:gray; width:12px; height: 16px; margin:0;"/></div>
  <div class="row center">0x20</div>
</div>

<br>

<br>

Five value types are allowed:

1. `Object` - a list of comma-separated key/value pairs enclosed in a pair of curly braces `{` `}`.

    **NOTE:** *A key is valid when it has at least one character.*

    **NOTE:** *Decisions regarding the significance of semantic ordering of the keys are left up to the implementer.*

<br>

2. `Array` - a list of comma-separated values enclosed in a pair of square brackets `[` `]`, which can store any of the other values-types, even mixed types.

<br>

3. `String` - enclosed in double quotation marks `"`, allowing (some) escaping via the backslash `\` token. Single quote tokens `'` are allowed within strings.

    **NOTE:** *Using token `'` instead of `"` to define a string value until [raw string support](#known-issues-2) is enabled in Noir.*

<br>

4. `Number` - defined by scientific notation: a mandatory integer component that may be prefixed with an optional minus `-`, followed by an optional fraction part (defined by a point `.` and a mandatory integer component) and/or an exponent part (defined by an `e` or `E` token, an optional `+` or `-`, and a mandatory integer component).

    **NOTE:** *Octal or hexadecimal forms, leading zeros, or special numeric values like `Infinity` or `NaN` are prohibited.*

    **NOTE:** *Floating point arithmetic is missing from Noir; conversions to float are out-of-scope.*

<br>

5. `Literal` - specified in lowercase and only these values are allowed:
   - `false` [ 0x66, 0x61, 0x6C, 0x73, 0x65 ]
   - `null` &nbsp;&nbsp;[ 0x6E, 0x75, 0x6C, 0x6C]
   - `true` &nbsp;&nbsp;[ 0x74, 0x72, 0x75, 0x65]

<br>
<br>

# Project Organization

### [`globals.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/globals.nr)

Contains global constants for (some of) the JSON tokens described earlier. They're used throughout the project.

<br>

### [`utils.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/utils.nr)

Provides utility extension functions for comparing, casting and printing byte arrays/slices.

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

### [`lib.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/lib.nr)

Contains specifications for the structs used in the project and defines extensions for initialization and debugging.

<br>

The backbone to the implementation is the [`Property`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/lib.nr#L6)
 struct:

```rust
struct Property
{
    key : [u8]
,   value : [u8]
}
```

<br>

Further on, the [`JSON`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/lib.nr#L14) struct uses lists of `Property` instances (aliased as `Object`) to store data:

```rust
type Object = [Property];

struct JSON
{
    doc : Object
,   children : [Object]
}
```

A `JSON` instance is generated by parsing a string (or byte array/slice) directly or by accessing children on an existing instance.

**NOTE:** *Because it contains slices, functions operating on instances of this struct need to be tagged with the `unconstrained` attribute.*

**NOTE:** *Duplicated keys with value types *other than object* will have their bytes replaced in the `doc` property. For example, parsing the string `{"a": 1, "a":true}` populates the `doc` property with a single element: key bytes `a` and value bytes `true`.*

**NOTE:** *Duplicated keys with value type of *object* will store all the provided objects in the `children` property. For example, parsing the string `{"a": {"key": "value"}, "a":{}}` populates the `children` property with two elements: the object `{"key":"value"}` and an empty object `{}`.*

<br>

A JSON is like a tree: objects can contain child objects. The children may further have child objects of their own.

In this implementation, all of the child object instances are stored in the `children` property of the root `JSON` instance, including those of the children.

Effectively this is a simple list. The object indices are stored in the value bytes as `{` `u8` `}`. A hypothetical first child object would have a value slice of three elements: `{`, `0`, and `}`. A second child would contain the elements `{1}`, the third `{2}`, and so on. This property is meant to be accessed via the `child` method:

```rust
impl JSON
{
    unconstrained
    pub fn child(self, index : u8) -> JSON { JSON { doc: self.children[index], children: self.children } }
}
```

<br>

Some extensions are provided:

```rust
trait Extensions
{
    fn none() -> Self;          // creates an empty instance
    fn len(self) -> Field;
    fn is_none(self) -> bool;   // has 0 elements
    fn is_empty(self) -> bool;  // has 1 element with empty key and empty value representing the empty object
    fn print(self);             // prints contents by mapping byte values to the first 127 codes of the ASCII table
}

impl Extensions for Object     { /* .. */ }
impl Extensions for JSON       { /* .. */ }
```

<br>

### [`parse.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/parse.nr)

Contains the implementation of the JSON parsing logic.

The parsing process considers various syntax rules defining the structure of a JSON and provides parsing functions to convert its data to byte slice representations.

```rust
impl JSON
{
    unconstrained
    pub fn parse<SIZE>(string: str<SIZE>) -> Self { /* .. */ } // wrapper to allow calls like JSON::parse("a JSON string")

    unconstrained
    fn store(self, prop: Property) -> Object { /* .. */ } // private, stores (or replaces) a property's value bytes

    unconstrained
    pub fn get<N> (self, key: str<N>) -> [u8] { self.doc.get(key) } // wrap trait method
}

trait PropertyLookup
{
    fn get<N> (self, key: str<N>) -> [u8]; // key lookup and return associated value's bytes

    fn linear_search<N>(self, key: [u8; N], index: Field) -> [u8]; // private
    fn binary_search<N>(self, key: [u8; N], begin: Field, end : Field) -> [u8]; // private
}

trait ByteArrayParser
{
    fn parse_list(self) -> [[u8]];  // private, parses array inputs (can be quoted)
    fn parse(self, begin: &mut Field, end: Field, child_index: Field) -> JSON; // main parser logic
}
```

The [`parse`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/parse.nr#L160) function accepts a byte array and creates a JSON "tree".

Parsing is done via linear insertion and retrieveal due to [this bug](#known-issues-1) that prevents replacement of nested slices and makes binary searching infeasible.

The `begin` parameter is a mutable reference to prevent double iteration of children due to the method using an iterative (as opposed to recursive) approach.

**NOTE:** *It is planned for the `begin` parameter to contain upon completion the error's position (if any) in the input bytes.*

The input bytes are recursively parsed upon encountering a secondary `{` token. The `child_index` parameter set and stored in the value bytes of the key holding the secondary object as value. Its secondary objects references will be copied inside the root `JSON` instance's `children` property.

<br>

### Examples <a name="parse-examples"></a>

#### Singular values

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

#### Property (key) value

```rust
unconstrained
fn parse_property()
{
    let (key, value) = ("my_key", "100");

    let json = JSON::parse("{'my_key' : 100}");

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

### [`convert.nr`](https://github.com/RontoSOFT/noir-json-parser/blob/main/src/convert.nr)

Provides utility functions for converting representations encoded in byte slices to their respective native types.

These functions are designed to handle different formats, returning `Option<T>` for safe error handling of types that are missing the concept of "empty" (numbers, booleans), or empty slice instances (for objects, arrays, strings).

```rust
trait FieldConversion
{
    fn get_whole(self, begin : Field, end : Field) -> Field; // converts a stream of digit bytes to Field
    fn get_offsets(self) -> [Field; 5]; // separates a scientific notation digit stream into constituent parts' (whole, fractional, exponent) index offsets
}

trait ByteArrayConversions
{
    fn as_bool(self) -> Option<bool>;
    fn as_field(self) -> Option<Field>;
    fn as_string(self) -> [u8];
    fn as_list(self) -> [[u8]];
    fn as_object(self) -> JSON;
}
```

**NOTE:** *Inputs to these methods work even when string quoted. Casting `'true'` through `as_bool` returns the `bool` value `true`. Casting `'125'` through `as_field` returns the `Field` value 125.*

<br>

Wrapping over these methods for the `str` native type to ease development:

```rust
impl<N> ByteArrayConversions for str<N>
{
    fn as_bool(self) -> Option<bool>   { self.as_bytes().as_bool() }
    fn as_field(self) -> Option<Field> { self.as_bytes().as_field() }
    fn as_list(self) -> [[u8]]         { self.as_bytes().as_list() }
    fn as_string(self) -> [u8]         { self.as_bytes().as_slice() }
    fn as_object(self) -> JSON         { self.as_bytes().as_object() }
}
```

<br>

The module also extends `JSON`, adding wrappers over these trait methods to ease development:

```rust
impl JSON
{
    fn get_bool<N>  (self, key : str<N>) -> Option<bool>  { self.doc.get(key).as_bool() }
    fn get_field<N> (self, key : str<N>) -> Option<Field> { self.doc.get(key).as_field() }
    fn get_string<N>(self, key : str<N>) -> [u8]          { self.doc.get(key).as_string() }
    fn get_array<N> (self, key : str<N>) -> [[u8]]        { self.doc.get(key).as_list() }

    unconstrained
    pub fn get_object<N>(self, key : str<N>) -> JSON { /* .. */ }
}
```

<br>

### Simple Conversions
<br>

```rust
fn as_bool(self) -> Option<bool>
```

Converts values
- <code>null</code> and <code>false</code> as the native boolean <code style="color:#569CD6">false</code>
- <code>true</code> as the native boolean <code style="color:#569CD6">true</code>

Returns an `Option<bool>` for handling invalid inputs.

<br>
<br>

```rust
fn as_field(self) -> Option<Field>
```

Converts scientific notation digit streams representations to the native `Field` type, wrapped into `Option` for handling invalid inputs.

**NOTE:** *Floating point support is missing from Noir. When encountering a decimal point separator token `.` the method returns `Option::none()`, even if the stream is valid.*

<br>
<br>

```rust
fn as_string(self) -> [u8]
```

Removes quotes `''` from surrounding a value's bytes and returns the arraying byte slice. For example, a stream such as `'my_string'` will be returned as `my_string`.

<br>

### Examples <a name="convert-simple-examples"></a>

#### Singular values

```rust
unconstrained
fn convert_values()
{
    assert("false").as_bool().unwrap() == false);
    assert("100").as_field().unwrap() == 100);
    assert("'my_string'").as_string().eq_string("my_string") == true);

    // or

    assert(JSON::parse("false").doc[0].value.as_bool().unwrap() == false);
    assert(JSON::parse("100").doc[0].value.as_field().unwrap() == 100);
    assert(JSON::parse("'my_string'").doc[0].value.as_string().eq_string("my_string") == true);

    // or

    assert(JSON::parse("false").get_bool("").unwrap() == false);
    assert(JSON::parse("100").get_field("").unwrap() == 100);
    assert(JSON::parse("'my_string'").get_string("").eq_string("my_string") == true);
}
```

<br>

#### Property (key) values

```rust
unconstrained
fn convert_properties()
{
    let json = JSON::parse("{ 'a': false, b: 100, c: 'my_string' }");

    assert(json.get_bool("a").unwrap() == false);
    assert(json.get_field("b").unwrap() == 100);
    assert(json.get_string("c").eq_string("my_string") == true);
    // or
    assert("my_string".eq(json.get_string("c")) == true);

    // or

    assert(json.get("a").as_bool().unwrap() == false);
    assert(json.get("b").as_field().unwrap() == 100);
    assert(json.get("c").eq("'my_string'") == true);
    // or
    assert("'my_string'".eq(json.get("c")) == true);
}
```

<br>

### Array and Object Conversions

<br>

```rust
fn as_list(self) -> [[u8]]
```

Converts the input stream to a slice-of-slices when surrounded by `[]`, otherwise returns an empty slice. Should be used with pre-processed byte streams, which are members of `JSON` instances resulting from `JSON::parse` or `as_object`.

Values must be separated by comma tokens `,` . Whitespaces are **NOT** tolerated.

**NOTE:** *Input byte streams defining arrays containing `object` type elements **MUST** be parsed using `as_object`.*

<br>
<br>

```rust
fn as_object(self) -> JSON
```

Converts the input byte stream to a `JSON` by parsing it.

Employs an extra check for input size to convert quoted objects, so it is preferred to use `JSON::parse` for quote-less input bytes.

<br>

### Examples <a name="convert-array-object-examples"></a>

#### Value as an array

```rust
unconstrained
fn convert_value_array()
{
    let array : [[u8]] = "[1,2,3]".as_list();

    assert(array.len() == 3);
    assert(array[0].as_field().unwrap() == 1);
    assert(array[1].as_field().unwrap() == 2);
    assert(array[2].as_field().unwrap() == 3);
}
```

<br>

#### Value as nested arrays

```rust
unconstrained
fn convert_value_array_nested()
{
    let array : [[u8]] = "[[1,3],[2,4]]".as_list();

    assert(array.len() == 3);

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

#### Key with mixed value type arrays as value

```rust
unconstrained
fn convert_property_value_mixed_type_array()
{
    let array : [[u8]] = JSON::parse("{ 'a': [true, 2, 'my_string', 10.35e+5, null] }").get_array("a");

    assert(array.len() == 4);

    assert(array[0].as_bool().unwrap() == true);
    assert(array[1].as_field("2") == true);
    assert(array[2].as_string("'my_string'").eq_string("my_string") == true);
    assert(array[3].eq_string("10.35e+5")); // floating-point values are comparable by equality only
    assert(array[4].as_bool().unwrap() == false); // null is false
}
```

<br>

#### Key with object as value

```rust
unconstrained
fn convert_object()
{
    let json = JSON::parse("{'abc':{'a':1,'b':true,'c':'123'}}");
    // or
    let json = "{'abc':{'a':1,'b':true,'c':'123'}}".as_object();

    let obj = json.get_object("abc");
    assert(obj.get("a").eq_string("1") == true);
    assert(obj.get("b").eq_string("true") == true);
    assert(obj.get("c").eq_string("'123'") == true);
}
```

<br>

#### Two keys with object as value

```rust
unconstrained
fn convert_two_objects()
{
    let json = JSON::parse("{'obj1':{'a':1,'b':true},'obj2':{'c':'my_string'}}");
    // or
    let json = "{'obj1':{'a':1,'b':true},'obj2':{'c':'my_string'}}".as_object();

    let obj_1 = json.get_object("obj1");
    assert(obj_1.get("a").eq_string("1") == true);
    assert(obj_1.get("b").eq_string("true") == true);

    let obj_2 = json.get_object("obj2");
    assert(obj_2.get_string("c").eq_string("my_string") == true);
}
```

<br>

#### Nested objects

```rust
unconstrained
fn convert_two_nested_objects()
{
    let json = JSON::parse("{'abc':{'a':{'b':1}},'def':{'d':{'e':2}}}");

    assert(json.get_object("abc").get_object("a").get("b").eq_string("1") == true);
    assert(json.get_object("def").get_object("d").get("e").eq_string("2") == true);
}
```

<br>

#### Array with one object element

```rust
unconstrained
fn value_array_one_object()
{
    let json = JSON::parse("[{'a':1}]");
    // or
    let json = "[{'a':1}]".as_object(); // as_list won't work with nested objects in arrays

    assert(json.doc.len() == 1);
    assert(json.children.len() == 1);

    let array = json.get_array("");
    //
    let array = json.doc[0].value;

    assert(json.child(array[0][1]).len() == 1);
    assert(json.child(0).get_field("a") == 1);
}
```

<br>

#### Array with multiple (empty) object elements

```rust
unconstrained
fn value_array_empty_objects()
{
    let json = JSON::parse("[{},{},{}]");
    // or
    let json = "[{},{},{}]".as_object(); // as_list won't work with nested objects in arrays

    assert(json.doc.len() == 1);
    assert(json.children.len() == 3);

    assert(json.child(0).is_empty() == true);
    assert(json.child(1).is_empty() == true);
    assert(json.child(2).is_empty() == true);
}
```

<br>

#### Key with a value of an array containing two object elements

```rust
unconstrained
fn convert_object_array_two_objects()
{
    let json = JSON::parse("{ 'abc': [{ 'a': 1, 'b': true }, { 'c': '456' }] }");
    let array : [[u8]] = json.get_array("abc");

    let obj_1 = json.child(array[0][1]);
    assert(obj_1.get_field("a").unwrap() == 1);
    assert(obj_1.get_bool("b").unwrap() == true);

    let obj_2 = json.child(array[1][1]);
    assert(obj_2.get_field("c") == 456); // works even though value of 'c' is a string
}
```

<br>

# Known Issues

1. <div id="known-issues-1">See <a href="https://github.com/noir-lang/noir/issues/3363">this issue</a> covering nested slices access.</div>

1. <div id="known-issues-2">See <a href="https://github.com/noir-lang/noir/issues/3475">this issue</a> covering raw string support.</div>

1. <div id="known-issues-3">Floating point arithmetic is missing from Noir. Pending a solution. See (this repo)[!LINK!].</div>
