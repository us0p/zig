const std = @import("std");

const array = [5]u8{ 'h', 'e', 'l', 'l', 'o' };
// For arrays literals, N may be replaced by _ to infer the size of the array.
const inferred_len_array = [_]u8{ "w", "o", "r", "l", "d" };

const array_len = array.len;
