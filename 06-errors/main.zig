const std = @import("std");
const expect = std.testing.expect;

// anyerror is the global error set, which due to being the superset of all error sets,
// can have an error from any set coerced to it. Its usage should be generally avoided.

// Errors are values.
// An error set is like an enum, where each error in the set is a value.
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFount,
};

// Error sets can be merged.
const A = error{ NotDir, PathNotFound };
const B = error{ OutOfMemory, PathNotFound };
const C = A || B;

// Error coerces to their supersets.
const AllocationError = error{OutOfMemory};

test "coerce error from a subset to a super set" {
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expect(err == FileOpenError.OutOfMemory);
}

// Error union types are created as follow: err!type:
// The value will be the provided error or type.
test "error union" {
    const maybe_error: AllocationError!u16 = 10;
    // Catch here is used to provide a fallback value.
    const no_error = maybe_error catch 0;

    try expect(@TypeOf(no_error) == u16);
    try expect(no_error == 10);
}

fn failingFn() error{Oops}!void {
    return error.Oops;
}

test "returning an error" {
    failingFn() catch |err| {
        try expect(err == error.Oops);
        return;
    };
}

// try x;
// Is a shortcut for try x catch |err| return err
// And it's commonly used where handling error isn't appropriate.
fn failFn() error{Oops}!i32 {
    try failingFn();
    return 12;
}

test "try" {
    var v = failFn() catch |err| {
        try expect(err == error.Oops);
        // This return is needed because try creates its own block from when it only returns the error.
        return;
    };
    try expect(v == 12); // is never reached
}

// errdefer works like defer but only executing when the function return an error inside the errdefer block.
var problems: u32 = 98;

fn failFnCounter() error{Oops}!void {
    errdefer problems += 1;
    try failingFn();
}

test "errdefer" {
    failFnCounter() catch |err| {
        try expect(err == error.Oops);
        try expect(problems == 99);
        return;
    };
}

// If a function returns an error set without explicit defining the set.
// The error set will be inferred with all possible errors that the fn may return.
fn createFile() !void {
    return error.AccessDenied;
}

test "inferred error set" {
    //type coercion successfully takes place
    const x: error{AccessDenied}!void = createFile();

    //Zig does not let us ignore error unions via _ = x;
    //we must unwrap it with "try", "catch", or "if" by any means
    _ = x catch {};
}
