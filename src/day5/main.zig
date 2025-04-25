//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;
const util = @import("util");
pub fn main() !void {
    const start = std.time.milliTimestamp(); // Record start time
    try test_ab("./src/day5/data.txt");
    const end = std.time.milliTimestamp(); // Record end time
    const elapsed = end - start; // Calculate elapsed time in milliseconds
    std.debug.print("Execution time: {} ms\n", .{elapsed});
}

fn test_ab(file_name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();
    const rules, const data = try read_data(file_name, alloc);
    var a_result:usize = 0;
    var b_result:usize = 0;
    outer:
    for (data.items) |line| {
        var idx = line.items.len - 1;
        while (idx > 0) {
            const oc = line.items[idx];
            idx -= 1;
            const d = rules.get(oc);
            if (d != null) {
                for (line.items[0..idx+1]) |c| {
                    if (d != null and d.?.contains(c)) {
                        b_result += try sort_line(rules, line.items);
                        continue :outer;
                    }
                }
            }
        }
        a_result += line.items[line.items.len/2];
    }
    std.debug.print("Result A: {d}\n", .{a_result});
    std.debug.print("Result B: {d}\n", .{b_result});
}

const OrderMap = std.AutoHashMap(usize, NodeList);
const NodeList = std.AutoHashMap(usize, void);

fn test_b(file_name: []const u8) !void {
    _ = file_name;
    return error.S;
}

fn sort_line(smap: std.AutoHashMap(usize, NodeList), line: []const usize) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    var lineset = NodeList.init(alloc);
    var result = std.ArrayList(usize).init(alloc);
    for (line) |num| {
        try lineset.put(num, {});
    }
    defer arena.deinit();
    var lmap = OrderMap.init(alloc);
    var stack = std.ArrayList(usize).init(alloc);
    for (line) |num| {
        const val = smap.getPtr(num);
        if (val != null) {
            var lst = NodeList.init(alloc);
            var it = val.?.*.keyIterator();
            while (it.next()) |v| {
                if (lineset.contains(v.*)) {
                    try lst.put(v.*, {});
                }
            }
            if (lst.count() > 0) {
                try lmap.put(num, lst);
            } else {
                try result.append(num);
                try stack.append(num);
            }
        } else {
            try result.append(num);
            try stack.append(num);
        }
    }

    while (stack.pop()) |item| {
        _ = lmap.remove(item);
        var it = lmap.iterator();
        while (it.next()) |entry| {
            if (entry.value_ptr.*.contains(item)) {
                _ = entry.value_ptr.*.remove(item);
                if (entry.value_ptr.*.count() == 0) {
                    try stack.append(entry.key_ptr.*);
                    try result.append(entry.key_ptr.*);
                }
            }
        }
    }
    return result.items[result.items.len / 2];
}

fn read_data(file_name: []const u8, alloc: std.mem.Allocator) !struct { OrderMap, std.ArrayList(std.ArrayList(usize)) } {
    var file = try util.read_file(file_name, alloc);
    defer file.deinit();
    var i: usize = 0;
    var map = OrderMap.init(alloc);
    while (file.lines[i].len > 0) {
        var it = std.mem.splitScalar(u8, file.lines[i], '|');
        const left = try std.fmt.parseInt(usize, it.next().?, 10);
        const right = try std.fmt.parseInt(usize, it.next().?, 10);
        if (it.next() != null) {
            return error.FileFormat;
        }
        const gop = try map.getOrPut(left);
        if (!gop.found_existing) {
            gop.value_ptr.* = NodeList.init(alloc);
        }
        try gop.value_ptr.*.put(right, {});
        i += 1;
    }
    i += 1;
    var result = std.ArrayList(std.ArrayList(usize)).init(alloc);
    while (i < file.lines.len) {
        var line = std.ArrayList(usize).init(alloc);
        var it = std.mem.splitScalar(u8, file.lines[i], ',');
        while (it.next()) |n| {
            const num = try std.fmt.parseInt(usize, n, 10);
            try line.append(num);
        }
        try result.append(line);
        i += 1;
    }
    return .{ map, result };
}

test {
    std.testing.refAllDecls(@This());
}
