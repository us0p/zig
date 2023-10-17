const std = @import("std");
const expect = std.testing.expect;

// Switches works as both statement and expression.
// The types of all branches must coerce to the type which is being switched upon.
// All possible values must have an associated branch.
// Cases cannot fall through the other branches.

test "switch statement" {
    var x: i8 = 10;
    switch (x) {
        // between these numbers, inclusive
        -5...5 => {
            x = -x;
        },
        // one or the other
        10, 100 => {
            // special considerations must be made
            // when dividing signed integers
            x = @divExact(x, 10);
        },
        else => {},
    }
    try expect(x == 1);
}

test "switch expression" {
    var x: i8 = 10;
    x = switch (x) {
        -5...5 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    try expect(x == 1);
}
