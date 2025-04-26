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
    var file = try util.read_file("./src/day02/data.txt", alloc);
    defer file.deinit();
    var simple_count: usize = 0;
    var complex_count: usize = 0;
    var row = std.ArrayList(i32).init(alloc);
    for(file.lines) | l | {
        var it = std.mem.splitScalar(u8, l, ' ');
        row.clearRetainingCapacity();
        while(it.next()) | num | {
            try row.append(try std.fmt.parseInt(i32, num, 10));
        }
        damper:
        for(0..row.items.len+1) | s | {
            var last: ?i32 = null;
            var sign: ?i32 = null;
            const skip: i32 =  @as(i32, @intCast(s)) - 1;
            for(0..row.items.len, row.items) |idx, x| {
                if(idx == skip) {
                    continue;
                }
                if(last != null) {
                    const diff = x - last.?;
                    const nsign = std.math.sign(diff);
                    if(sign == null) {
                        sign = nsign;
                    }
                    if(sign.? != nsign) {
                        continue :damper;
                    }
                    const adiff = @abs(diff);
                    // std.debug.print("diff: {d}, Sign {d}, Nsign {d}", .{ adiff, sign.?, nsign });
                    if(adiff < 1 or adiff > 3 ) {
                        continue :damper;
                    }
                }
                last = x;
            }
            if(skip == -1) {
                simple_count += 1;
            }
            complex_count += 1;
            break;
        }
    }
    std.debug.print("Simple valid lines: {d}\n", .{simple_count});
    std.debug.print("Complex valid lines: {d}\n", .{complex_count});
}

test {
    std.testing.refAllDecls(@This());
}