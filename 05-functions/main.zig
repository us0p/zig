const std = @import("std");
const expect = std.testing.expect;

// All function arguments are immutable;
// If a copy is desired the user must explicity make one.
// functions are camelCased.
// Recursion is allowed.

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}
// When recursion happens, the compiler is no longer able to work
// out the maximum stack size, which may result in unsafe behaviour - a stack overflow.

test "function recursion" {
    const fibo = fibonacci(10);
    try expect(@TypeOf(fibo) == u16);
    try expect(fibo == 55);
}

// Defer is used to execute a statement while exiting the current block;
test "defer" {
    var x: i16 = 5;
    {
        defer x += 2;
        try expect(x == 5);
    }
    try expect(x == 7);
}

// With multiples defers in a block, they are executed in reverse order:
test "multiple defers" {
    var x: f32 = 5;
    {
        defer x += 2;
        defer x /= 2;
        try expect(x == 5);
    }
    try expect(x == 4.5);
}
