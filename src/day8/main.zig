//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;
const util = @import("util");
pub fn main() !void {
    const start = std.time.milliTimestamp(); // Record start time
    try test_a("./src/day8/data.txt");
    try test_b("./src/day8/data.txt");
    const end = std.time.milliTimestamp(); // Record end time
    const elapsed = end - start; // Calculate elapsed time in milliseconds
    std.debug.print("Execution time: {} ms\n", .{elapsed});
}

const Point = struct { x: i64, y: i64 };

fn test_a(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var map = std.AutoHashMap(u8, std.ArrayList(Point)).init(alloc);
    for (file.lines, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c != '.') {
                var entry = map.getPtr(c);
                if (entry == null) {
                    try map.put(c, std.ArrayList(Point).init(alloc));
                    entry = map.getPtr(c);
                }
                try entry.?.append(.{ .x = @intCast(x), .y = @intCast(y) });
            }
        }
    }
    var result = std.AutoHashMap(Point, void).init(alloc);
    var it = map.iterator();
    while (it.next()) |entry| {
        for (entry.value_ptr.items) |left| {
            for (entry.value_ptr.items) |right| {
                if (left.x == right.x and left.y == right.y) continue;
                const dx = left.x - right.x;
                const dy = left.y - right.y;
                const pt: Point = .{ .x = left.x + dx, .y = left.y + dy };
                if (is_valid(file.lines, pt)) {
                    try result.put(pt, {});
                }
            }
        }
    }
    std.debug.print("Number of Fields (A): {d}\n", .{result.count()});
}

fn test_b(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var map = std.AutoHashMap(u8, std.ArrayList(Point)).init(alloc);
    for (file.lines, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c != '.') {
                var entry = map.getPtr(c);
                if (entry == null) {
                    try map.put(c, std.ArrayList(Point).init(alloc));
                    entry = map.getPtr(c);
                }
                try entry.?.append(.{ .x = @intCast(x), .y = @intCast(y) });
            }
        }
    }
    var result = std.AutoHashMap(Point, void).init(alloc);
    var it = map.iterator();
    while (it.next()) |entry| {
        for (entry.value_ptr.items) |left| {
            for (entry.value_ptr.items) |right| {
                if (left.x == right.x and left.y == right.y) continue;
                const dx = left.x - right.x;
                const dy = left.y - right.y;
                var pt: Point = .{ .x = left.x, .y = left.y };
                while (is_valid(file.lines, pt)) {
                    try result.put(pt, {});
                    pt.x += dx;
                    pt.y += dy;
                }
            }
        }
    }
    std.debug.print("Number of Fields (B): {d}\n", .{result.count()});
}

fn is_valid(lines: []const []const u8, point: Point) bool {
    return !(point.x < 0 or point.y < 0 or point.y >= lines.len or point.x >= lines[@intCast(point.y)].len);
}

test {
    std.testing.refAllDecls(@This());
}
