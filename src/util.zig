const std = @import("std");
const Regex = @import("regex").Regex;
const Allocator = std.mem.Allocator;

const TextFile = struct {
    const Self = @This();

    allocator: Allocator,
    data: [] u8,
    lines: [] const []  u8,

    pub fn deinit(self: Self) void {
        self.allocator.free(self.lines);
        self.allocator.free(self.data);
    }
};

pub fn read_file(file_name: []const u8,allocator: Allocator) !TextFile {

    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();
    var lines = std.ArrayList([]u8).init(allocator);
    errdefer lines.deinit();
    // Wrap the file reader in a buffered reader.
    // Since it's usually faster to read a bunch of bytes at once.
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();
    const file_state = try file.stat();
    var line_start: usize = 0;
    var line_end: usize = 0;
    const data = try reader.readAllAlloc(allocator,file_state.size);
    while(line_end < file_state.size) {
        if(data[line_end] == '\n') {
            try lines.append(data[line_start..line_end]);
            line_start = line_end + 1;
        }
        line_end += 1;
    }
    if(line_end > line_start) {
        try lines.append(data[line_start..line_end]);
    }
    std.debug.print("Total lines: {d}\n", .{lines.items.len});
    return .{
        .allocator= allocator,
        .data = data,
        .lines = try lines.toOwnedSlice()
    };
}


test "Read File" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const file  = try read_file("src/day01/data.txt"[0..],allocator);
    defer file.deinit();
    std.debug.print("Total lines: {d}\n", .{file.lines.len});
    var re = try Regex.compile(allocator, "(\\d+)[^\\d]+(\\d+)");
    for(file.lines) | line|  {
        const captures = try re.captures(line).?;
        const left = std.fmt.parseInt(i32, captures[0], 10);
        const right = std.fmt.parseInt(i32, captures[1], 10);
        std.debug.print("Line: {d}-{d}\n", .{left, right});

    }
}