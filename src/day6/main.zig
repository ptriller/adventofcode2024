//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;
const util = @import("util");
pub fn main() !void {
    const start = std.time.milliTimestamp(); // Record start time
    // try test_a("./src/day6/test.txt");
    try test_b("./src/day6/data.txt");
    const end = std.time.milliTimestamp(); // Record end time
    const elapsed = end - start; // Calculate elapsed time in milliseconds
    std.debug.print("Execution time: {} ms\n", .{elapsed});
}

const Direction = enum(u8) { UP = '^', RIGHT = '>', DOWN = 'v', LEFT = '<' };

fn test_a(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    const fields = try process_field(file.lines, alloc);
    std.debug.print("Number of Fields: {d}\n", .{fields.count()});
    fields.deinit();
}

fn test_b(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var loops: usize = 0;
    var fields = try process_field(file.lines, alloc);
    defer fields.deinit();
    var it = fields.iterator();
    while (it.next()) |field| {
        const x, const y = field.key_ptr.*;
        if (file.lines[y][x] != '.') {
            continue;
        }
        file.lines[y][x] = '#';
        var res = process_field(file.lines, alloc);
        if (res) |_| {
            (try res).deinit();
        } else |_| {
            loops += 1;
        }
        file.lines[y][x] = '.';
    }

    std.debug.print("Number of Possibilities: {d}\n", .{loops});
}

const Step = struct { x: usize, y: usize, dir: Direction };

fn process_field(field: []const []u8, alloc: std.mem.Allocator) !std.AutoHashMap(struct { usize, usize }, void) {
    var x: usize = 0;
    var y: usize = 0;
    outer: for (field, 0..) |line, py| {
        for (line, 0..) |c, px| {
            if (c == '^') {
                x = px;
                y = py;
                break :outer;
            }
        }
    } else {
        unreachable;
    }
    var dir: Direction = Direction.UP;
    var steps = std.AutoHashMap(Step, void).init(alloc);
    defer steps.deinit();
    var fields = std.AutoHashMap(struct { usize, usize }, void).init(alloc);
    while (true) {
        const mv = move(field, x, y, dir);
        if (mv == null) break;
        x, y, dir = mv.?;
        const step: Step = .{ .x = x, .y = y, .dir = dir };
        if (steps.contains(step)) return error.LOOP;
        try steps.putNoClobber(step, {});
        try fields.put(.{ x, y }, {});
    }
    return fields;
}

fn move(data: []const []u8, px: usize, py: usize, pdir: Direction) ?struct { usize, usize, Direction } {
    var x = px;
    var y = py;
    var dir = pdir;
    if (dir == Direction.UP) {
        if (y == 0) return null;
        if (data[y - 1][x] == '#') {
            dir = turn(dir);
        } else {
            y = y - 1;
        }
    } else if (dir == Direction.RIGHT) {
        if (x == data[y].len - 1) return null;
        if (data[y][x + 1] == '#') {
            dir = turn(dir);
        } else {
            x += 1;
        }
    } else if (dir == Direction.DOWN) {
        if (y == data.len - 1) return null;
        if (data[y + 1][x] == '#') {
            dir = turn(dir);
        } else {
            y += 1;
        }
    } else if (dir == Direction.LEFT) {
        if (x == 0) return null;
        if (data[y][x - 1] == '#') {
            dir = turn(dir);
        } else {
            x -= 1;
        }
    }
    return .{ x, y, dir };
}

fn turn(dir: Direction) Direction {
    return switch (dir) {
        Direction.UP => Direction.RIGHT,
        Direction.RIGHT => Direction.DOWN,
        Direction.DOWN => Direction.LEFT,
        Direction.LEFT => Direction.UP,
    };
}

test {
    std.testing.refAllDecls(@This());
}
