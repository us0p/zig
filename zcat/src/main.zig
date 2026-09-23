const std = @import("std");

const kb = 1024;

pub fn main(init: std.process.Init) u8 {
    const io = init.io;
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = init.minimal.args.toSlice(allocator) catch |err| {
        std.log.err("{}\n", .{err});
        return 1;
    };

    return read(io, args[1..]);
}

fn read(io: std.Io, args: []const []const u8) u8 {
    var exitCode: u8 = 0;
    if (args.len == 0) {
        readStdin(io) catch |err| {
            std.log.err("{}\n", .{err});
            exitCode = 1;
        };
        return exitCode;
    }

    for (args) |arg| {
        readFile(io, arg) catch |err| {
            std.log.err("{}\n", .{err});
            exitCode = 1;
        };
    }
    return exitCode;
}

/// Read buffered bytes from stdin, wating for user input when executed without parameters.
fn readStdin(io: std.Io) !void {
    var buf: [kb]u8 = undefined;
    var stdinReader = std.Io.File.stdin().reader(io, &buf);
    const stdin = &stdinReader.interface;

    while (true) {
        if (stdin.takeDelimiterInclusive('\n')) |userInput| {
            try std.Io.File.stdout().writeStreamingAll(io, userInput);
        } else |err| switch (err) {
            error.EndOfStream => break,
            error.StreamTooLong => {
                try std.Io.File.stdout().writeStreamingAll(io, &buf);
                stdin.tossBuffered();
            },
            else => |general_err| {
                return general_err;
            },
        }
    }
}

/// Read buffered bytes from files until number of bytes read is 0.
fn readFile(io: std.Io, filePath: []const u8) !void {
    var file: std.Io.File = undefined;

    if (std.fs.path.isAbsolute(filePath)) {
        file = try std.Io.Dir.openFileAbsolute(io, filePath, .{});
    } else {
        file = try std.Io.Dir.cwd().openFile(io, filePath, .{});
    }
    defer file.close(io);

    var buf: [kb]u8 = undefined;
    var fileReader = file.reader(io, &buf);
    const reader = &fileReader.interface;

    while (true) {
        var chunk: [kb]u8 = undefined;
        const bytesRead = try reader.readSliceShort(&chunk);
        if (bytesRead == 0) break;

        try std.Io.File.stdout().writeStreamingAll(io, chunk[0..bytesRead]);
    }
}
