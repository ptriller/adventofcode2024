//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;
const util = @import("util");
pub fn main() !void {
    try test_a("./src/day04/data.txt");
    try test_b("./src/day04/data.txt");

}

fn test_a(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var found: usize = 0;
    for (0..file.lines.len) |y| {
        for (0..file.lines[y].len) |x| {
            found += try find(file.lines, @intCast(x), @intCast(y), "XMAS");
        }
    }
    std.debug.print("TEST-A Number of Words found {}\n", .{found});
}

fn test_b(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var found: usize = 0;
    for (1..file.lines.len - 1) |y| {
        for (1..file.lines[y].len - 1) |x| {
            if (file.lines[y][x] == 'A' and
                (
                    (file.lines[y - 1][x - 1] == 'M' and file.lines[y + 1][x + 1] == 'S')
                        or (file.lines[y - 1][x - 1] == 'S' and file.lines[y + 1][x + 1] == 'M')
                ) and
                (
                    (file.lines[y - 1][x + 1] == 'M' and file.lines[y + 1][x - 1] == 'S')
                        or (file.lines[y - 1][x + 1] == 'S' and file.lines[y + 1][x - 1] == 'M')
                )
            ) {
                found += 1;
            }
        }
    }
    std.debug.print("TEST-B Number of Words found {}\n", .{found});
}

const offsets: [3]i32 = .{ -1, 0, 1 };

fn find(data: []const []const u8, x: i32, y: i32, word: []const u8) !usize {
    var found: usize = 0;
    for (offsets) |ox| {
        for (offsets) |oy| {
            if (try trace(data, x, y, word, ox, oy)) {
                found += 1;
            }
        }
    }
    return found;
}

fn trace(data: []const []const u8, x: i32, y: i32, word: []const u8, ox: i32, oy: i32) !bool {
    var px: i32 = x;
    var py: i32 = y;
    for (word) |ch| {
        if (py < 0 or py >= @as(i32, @intCast(data.len)) or px < 0 or px >= @as(i32, @intCast(data[@intCast(py)].len))) {
            return false;
        }
        if (data[@intCast(py)][@intCast(px)] != ch) {
            return false;
        }
        px += ox;
        py += oy;
    }
    return true;
}

test {
    std.testing.refAllDecls(@This());
}
