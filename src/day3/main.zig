//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;
const util = @import("util");
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file("./src/day3/data.txt", alloc);
    defer file.deinit();
    var offset: usize = 0;
    var result_a: usize = 0;
    var result_b: usize = 0;
    var active = true;
    while (offset < file.data.len) {
        if (std.mem.startsWith(u8, file.data[offset..], "do()")) {
            active = true;
            offset += 4;
            continue;
        }
        if (std.mem.startsWith(u8, file.data[offset..], "don't()")) {
            active = false;
            offset += 7;
            continue;
        }
        if (std.mem.startsWith(u8, file.data[offset..], "mul(")) {
            offset += 4;
        } else {
            offset += 1;
            continue;
        }
        const o1, const mult1 = find_mul(file.data[offset..], ',') catch |err| {
            if (err == error.EndOfInput) break;
            continue;
        };
        offset += o1;
        const o2, const mult2 = find_mul(file.data[offset..], ')') catch |err| {
            if (err == error.EndOfInput) break;
            continue;
        };
        offset += o2;
        std.debug.print("{} {d}*{d}\n", .{ active, mult1, mult2 });
        if (active) result_b += mult1 * mult2;
        result_a += mult1 * mult2;
    }
    std.debug.print("Result: A:{d} b: {d}\n", .{result_a, result_b});
}

fn find_mul(data: []const u8, delimiter: u8) !struct { usize, usize } {
    var offset: usize = 0;
    var value: usize = 0;
    while (offset < data.len) {
        if (data[offset] >= '0' and data[offset] <= '9') {
            value = value * 10 + data[offset] - '0';
        } else if (data[offset] == delimiter) {
            return .{ offset + 1, value };
        } else {
            return error.IllecalCharacter;
        }
        offset += 1;
    }
    return error.EndOfInput;
}

fn find_fun(data: []const u8) !usize {
    var offset: usize = 0;
    while (offset + 4 < data.len) {
        if (std.mem.eql(u8, "mul(", data[offset .. offset + 4])) {
            return offset + 4;
        }
        offset += 1;
    }
    return error.EndOfInput;
}

test {
    std.testing.refAllDecls(@This());
}
