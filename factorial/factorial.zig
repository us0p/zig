const std = @import("std");

pub fn main() !void {
    const number = 5;

    var result: i32 = 1;

    var i: i32 = 0;

    while (i < number) {
        result *= number - i;
        i += 1;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Factorial of {d} is {d}\n", .{ number, result });
}
