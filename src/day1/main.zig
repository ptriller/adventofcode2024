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
    var file = try util.read_file("./src/day1/data.txt", alloc);
    defer file.deinit();
    var re = try Regex.compile(alloc, "(\\d+)[^\\d]+(\\d+)");
    defer re.deinit();
    var alist = try alloc.alloc(u32, file.lines.len);
    var blist = try alloc.alloc(u32, file.lines.len);
    for(0.., file.lines) | idx, line | {
        const captures = (try re.captures(line)).?;
        const left = try std.fmt.parseInt(u32, captures.sliceAt(1).?, 10);
        const right = try std.fmt.parseInt(u32, captures.sliceAt(2).?, 10);
        alist[idx] = left;
        blist[idx] = right;
    }
    std.mem.sort(u32, alist, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, blist, {}, comptime std.sort.asc(u32));
    defer alloc.free(alist);
    defer alloc.free(blist);
    var diff: usize = 0;
    for(alist, blist) | l, r | {
        diff += @abs(@max(l,r) - @min(l,r));
    }
    std.debug.print("Diff: {d}\n", .{diff});
    var similarity: usize = 0;
    for(alist) | l | {
        var count: usize = 0;
        var pos = std.sort.lowerBound(u32, blist, l,order32);
        while(pos < blist.len and blist[pos] == l) {
            count += 1;
            pos+= 1;
        }
        std.debug.print("Add: {d}\n", .{count*l});
        similarity += count*l;
    }
    std.debug.print("Similarity: {d}\n", .{similarity});
}

fn order32(l: u32, r: u32) std.math.Order {
    return std.math.order(l,r);
}

test {
    std.testing.refAllDecls(@This());
}