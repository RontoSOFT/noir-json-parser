[![CI/CD](https://github.com/rontosoft/noir-json-parser/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/rontosoft/noir-json-parser/actions/workflows/main.yml)

# noir-json-parser
A JSON parsing library for the Noir language, tests, and examples on how to use it.

<br>

## Table of Contents
- [Setup](#setup)
- [JSON Format Overview](#json-format-overview)
    - [Structural Characters](#structural-characters)
    - [Whitespaces](#whitespaces)
    - [Value Types](#value-types)
- [Project Structure](#project-structure)
    - [`globals.nr`](#global-constants-globalsnr)
    - [`utils.nr`](#utilities-utilitiesnr)
    - [`parse.nr`](#parse-module-parsenr)
    - [`convert.nr`](#convert-module-convertnr)

<br>

## Setup

1. Public repo available [here](https://github.com/RontoSOFT/noir-json-parser-tests). Clone it in a folder, under the name `tests`.
2. Clone this repo in the same parent folder, under the name `lib`
3. Install the Noir language [compiler](https://github.com/noir-lang/noir/releases) (see [here](https://noir-lang.org/getting_started/nargo_installation)). The version used for this project is specified in [Nargo.toml](https://github.com/RontoSOFT/noir-json-parser-tests/blob/main/Nargo.toml).
4. Run the `noir test` command in the `tests` project directory.

<br>

### JSON Format Overview

#### Structural Characters

The module defines the six structural characters used in JSON:

- `BEGIN_ARRAY` (0x5B) - `[` (left square bracket)
- `BEGIN_OBJECT` (0x7B) - `{` (left curly bracket)
- `END_ARRAY` (0x5D) - `]` (right square bracket)
- `END_OBJECT` (0x7D) - `}` (right curly bracket)
- `KEY_DELIMITER` (0x3A) - `:` (colon)
- `VALUE_DELIMITER` (0x2C) - `,` (comma)

#### Whitespaces

Whitespace is allowed before or after any of the six structural characters. The following whitespace characters are supported:

- Space (0x20)
- Horizontal tab (0x09)
- Line feed or New line (0x0A)
- Carriage return (0x0D)

#### Value Types

The module handles various JSON value types:

1. **Strings**: JSON strings are enclosed in quotation marks (`"`) and support escaping using the backslash (`\`) character. Single quotes (`'`) are also supported within strings.

2. **Literals**: JSON literals must be lowercase and only these values are allowed:
   - `false` : [ 0x66, 0x61, 0x6c, 0x73, 0x65 ]
   - `null` : [ 0x6e, 0x75, 0x6c, 0x6c]
   - `true` : [ 0x74, 0x72, 0x75, 0x65]

3. **Numbers**: JSON numbers consist of an integer component that may be prefixed with an optional `MINUS` (-) sign, followed by an optional fraction part and/or an exponent part. JSON does not allow octal or hexadecimal forms, leading zeros, or special numeric values like Infinity or NaN.

<br>

## Project Structure

### `globals.nr`

The file contains global constants used in the `convert.nr` module. These constants define characters, literals, and delimiters used in the numeric representation.

<br>

### `utils.nr`

The file provides utility functions used in the `convert.nr` module. These functions help with printing byte values and converting numeric types.

<br>

### `parse.nr`

The `parse.nr` module contains the implementation of the JSON parsing logic. It defines the structure of JSON objects and arrays and provides parsing functions to extract data from JSON strings.

The main parsing function, `parse`, accepts a byte array and returns a slice of `Property` structs. Each `Property` represents a key-value pair in the JSON object and they are stored as byte slices.

The parsing process considers various JSON syntax rules, including checking for correct nesting of objects and arrays, handling escaped characters within strings, and validating the structure of numeric values.

#### Example

You can use the `JSON` struct to parse JSON strings and extract values from keys via the `bytesOf` method:

```rust
unconstrained fn check_my_key()
{
    let (key, value) = ("my_key", "100");

    let bytes = JSON::parse("{'my_key' : 100}").bytesOf(key);

    assert(bytes.eq_string(value) == true);
    assert(bytes.eq_array(value.as_bytes()) == true);
}
```

You can access `get*` methods directly:

```rust
unconstrained fn check_my_key_unconstrained()
{
    let (key, value) = ("my_key", "100");

    let field = JSON::parse("{'my_key' : 100}").getField(key);

    assert(field == 100);
}
```

<br>

### `convert.nr`

The `convert.nr` module provides utility functions for converting numeric representations encoded in byte arrays to their respective numeric types. These functions are designed to handle different numeric formats and return `Option<T>` values for safe error handling.

#### `asBool(bytes: [u8]) -> Option<bool>`

This function attempts to parse a byte slice as a boolean value and returns an `Option<bool>`. It recognizes common boolean literals such as `null`, `true`, and `false`.

#### `asField(bytes: [u8]) -> Option<Field>`

The `asField` function parses a byte slice as a numeric field and returns an `Option<Field>`. It can handle signed and unsigned numbers.

#### `asInteger(bytes: [u8]) -> Option<i127>`

The `asInteger` function parses a byte slice as an integer value and returns an `Option<i127>`. It can handle negative integers and converts them to signed integers.

#### Example

```rust
let bytes = JSON::parse("{'my_key' : 100}").bytesOf("my_key");
let result = convert::asField(bytes); //asBool, asInteger

assert(result.is_some());
assert(result.unwrap_unchecked() == 30);
```

<br>
