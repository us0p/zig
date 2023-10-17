const std = @import("std");

// value assignment: (const|var) identifier[: type] = value
// type can be omitted if the data type of value can be inferred.
const constant: i32 = 5;
var variable: u32 = 5000;

// @as performs an explicit type coercion
// Variables are snake_cased.
const inferred_constant = @as(i32, 5);

// constantns and variables must have a value.
// If no known value can be given, the undefined value, which coerces
// to any type, may be used as long as a type annotation is provided.
const undefined_const: i32 = undefined;
var undefined_variable: i32 = undefined;

// const values are preferred over var values.

pub fn main() !void {
    std.debug.print("constant: i32 = {d}\n", .{constant});
    std.debug.print("variable: i32 = {d}\n", .{variable});
    std.debug.print("type coercion is done with @as(type, value)\n", .{});
    std.debug.print("undefined_const: i32 = {d}\n", .{undefined_const}); // 2157613 ?

    // Values can be ignored using _, this is not valid on the global scope,
    // and is often used to ignore the return value of a function when you don't
    // need it.
    _ = 10;
}
