# Zig Concepts
This file contains some of the details of some zig concepts needed for 
`zcat` development.

## Arrays and Slices
- Both slices and arrays have boundary access check.
- `[]u8` is a slice of unsigned integers of 8 bytes that is mutable.
- `[]const u8` is also a slice but is not mutable.
- `[]u8` can be coerced to `[]const u8` but not the other way arround.

## Pointer cheatsheet
- `u8`: one `u8`
- `*u8`: pointer to one `u8`
- `[2]u8`: two `u8`
- `[*]u8`: pointer to uknown number of `u8`
- `[*]const u8`: pointer to uknown number of **immutable** `u8`
- `*[2]u8`: pointer to an array of 2 `u8`
- `*const [2]u8`: pointer to an **immutable** array of 2 `u8`
- `[]u8`: slice of `u8`
- `[]const u8`: slice of **immutable** `u8`
- Array, Slices and Pointers supports a "sentinel-terminated" notation:
    - const a: `[4:0]u32` -> 4 items array, terminated in 0.
    - const b: `[:0]const u32` -> Slice that can only point to 0 
    terminated arrays.
    - const c: `[*:0]const u32` -> many-item pointer that's guaranteed 
    to end in 0. Because of this, we can safely find the end of this 
    without knowing its length.
    - The sentinel value must be of the same type as the data being 
    terminated.

## Strings
- Literals are **constant** single-item pointers to null-terminated 
byte arrays.
- Literal strings can be coerced to both slices and null-terminated 
pointers.
- Indexing into a string containing non-ASCII bytes (0 - 255) returns 
individual bytes.
- All escape sequences are valid.
- len return the number of **bytes**.
- To create a mutable string from a string literal we need to deref the
pointer, this way we get the underying array that can be used freely.

## Errors
- An error set is similar to an `enum`, it associate the error set name 
with a sequence of unique identifiers that have an underlying `u16` value 
greather than 0. The same error can be redeclared but it always get the 
same integer value. Even though an error has an integer underlying 
representation, we must be explicit in the function signature. We can get 
the underlying integer assigned to an error with `@intFromError`.
- An Error Union Type `ErrorSet!T` is just a notation that indicates 
that the value can be an error set or the specified type. You can also 
use the notation `!T` which is the same as `anyerror!T` (note that 
`anyerror` is the global superset in Zig, so any error can be coerced 
to it).
- `errdefer` same as `defer` but only executed when the funtion returns
with an error.

## Iterators
Special interface to transform elements that are not indexable or that it's
not a range into something that we can loop over.  

Usually used with `while` loops by calling the `next()` method which 
returns `null` on end.
