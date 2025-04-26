//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;
const util = @import("util");
pub fn main() !void {
    const start = std.time.milliTimestamp(); // Record start time
    // try test_a("./src/day09/data.txt");
    try test_b("./src/day09/test.txt");
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
    var block: usize = 0;
    var idx: usize = 0;
    var data = file.data;
    var checksum: usize = 0;
    for (0..data.len) |i| {
        data[i] = data[i] - '0';
    }
    outer: while (idx < data.len) {
        if (idx % 2 == 0) {
            const id = idx / 2;
            for (0..@intCast(data[idx])) |_| {
                checksum += id * block;
                block += 1;
            }
        } else {
            var fill = data[idx];
            while (fill > 0) {
                if (data[data.len - 1] > 0) {
                    const id = (data.len - 1) / 2;
                    checksum += id * block;
                    block += 1;
                    data[data.len - 1] -= 1;
                    fill -= 1;
                } else {
                    if (data.len - 2 <= idx) break :outer;
                    data = data[0 .. data.len - 2];
                }
            }
        }
        idx += 1;
    }
    std.debug.print("Checksum: {d}\n", .{checksum});
}

fn test_b(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var block: usize = 0;
    var idx: usize = 0;
    var data = std.DoublyLinkedList(u8){};
    var checksum: usize = 0;

    for (data) |c| {
        data.append(.{ .data = c - '0' });
    }
    var goffset = data.len - 1;
    while (idx < data.len) {
        if (idx % 2 == 0) {
            const id = idx / 2;
            for (0..@intCast(data[idx])) |_| {
                checksum += id * block;
                std.debug.print("{d}", .{id});
                block += 1;
            }
        } else {
            var offset = goffset;
            var space = data[idx];
            while (offset > idx) {
                const id = offset / 2;
                if (data[offset] > 0 and data[offset] <= space) {
                    for (0..@intCast(data[offset])) |i| {
                        checksum += id * (block + i);
                        std.debug.print("{d}", .{id});
                        space -= 1;
                    }
                    goffset = offset;
                    block += data[idx];
                    data[offset - 1] += data[offset];
                    data[offset] = 0;
                    if (space == 0) {
                        break;
                    }
                }
                offset -= 2;
            }
            for (0..space) |_| {
                std.debug.print("0", .{});
            }
        }
        idx += 1;
    }
    std.debug.print("\nChecksum: {d}\n", .{checksum});
}

test {
    std.testing.refAllDecls(@This());
}
