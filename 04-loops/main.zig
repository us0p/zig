const std = @import("std");
const expect = std.testing.expect;

// While loops has two parts: a condition and a continue expression.
// In zig we also have the continue and break keywords.

test "while without continue expression" {
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }
    try expect(i == 128);
}

test "while wih continue expression" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 10) : (i += 1) {
        sum += i;
    }
    try expect(sum == 55);
}

// For loops are used to iterate over arrays (and other types)
test "for" {
    const string = [_]u8{ 'a', 'b', 'c' };

    // Here we're running over the strings array and capturing the each character.
    for (string) |character| {
        _ = character;
    }

    // Here we're specifying the index of interation, in this case we are using the range syntax, from 0 to the end of the array.
    // With this we can capture the index of the element as a second capture value.
    for (string, 0..) |character, index| {
        std.debug.print("character: {c}, index: {d}\n", .{ character, index });
    }

    // We can also use the blank identifier
    for (string, 0..) |_, index| {
        _ = index;
    }

    // To iterage over consecutive integer we can use the range syntax:
    // this will iterate from index 0 to 9, the range is exlclusive.
    var sum: usize = 0;
    for (0..10) |integer| {
        sum += integer;
    }
    try expect(sum == 45);
}

test "multiple objects for" {
    const item1 = [_]usize{ 1, 2, 3 };
    const item2 = [_]usize{ 4, 5, 6 };
    var count: usize = 0;

    // It is algo possible to iterate over multiples objects.
    // All lengths must be equal at the start of the loop.
    // Otherwise detectable illegal behavious occurs.
    for (item1, item2) |i, j| {
        count += i + j;
    }
    try expect(count == 21);
}
