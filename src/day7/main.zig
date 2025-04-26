//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;
const util = @import("util");
pub fn main() !void {
    const start = std.time.milliTimestamp(); // Record start time
    try test_a("./src/day7/data.txt");
    const end = std.time.milliTimestamp(); // Record end time
    const elapsed = end - start; // Calculate elapsed time in milliseconds
    std.debug.print("Execution time: {} ms\n", .{elapsed});
}

fn test_a(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var factors = std.ArrayList(usize).init(alloc);
    defer factors.deinit();
    var result: usize = 0;
    for (file.lines) |line| {
        factors.clearRetainingCapacity();
        var s1 = std.mem.splitScalar(u8, line, ':');
        const sum = try std.fmt.parseInt(usize, s1.next().?, 10);
        var s2 = std.mem.splitScalar(u8, s1.rest()[1..], ' ');
        while (s2.next()) |x| {
            try factors.append(try std.fmt.parseInt(usize, x, 10));
        }
        if (calc_factor(sum, factors.items[0], factors.items[1..])) {
            result += sum;
        }
    }
    std.debug.print("Result: {d}\n", .{result});
}

fn calc_factor(target: usize, current: usize, factors: []const usize) bool {
    if (current > target) return false;
    if (factors.len == 0) return target == current;
    if (calc_factor(target, current + factors[0], factors[1..])) return true;
    if (calc_factor(target, current * factors[0], factors[1..])) return true;
    return calc_factor(target, elephant(current, factors[0]), factors[1..]);
}

fn elephant(a: usize, b: usize) usize {
    var fac: usize = 1;
    while (fac <= b) {
        fac *= 10;
    }
    return a * fac + b;
}

test {
    std.testing.refAllDecls(@This());
}
