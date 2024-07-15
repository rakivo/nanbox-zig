const std = @import("std");

const exit = std.process.exit;
const print = std.debug.print;

const NaNBox = @import("NaNBox.zig").NaNBox;

fn nan_check(comptime T: type, value: T) !void {
    const nan = NaNBox.from(T, value);
    print("nan: {d}\n", .{nan.as(T)});

    if (nan.as(T) != value or @sizeOf(@TypeOf(nan)) != 8) {
        print("`TEST FAILED`\n", .{});
        exit(1);
    } else {
        print("`OK`\n", .{});
    }
}

pub fn main() !void {
    try nan_check(u64, 69);
    try nan_check(i64, -69);
    try nan_check(f64, 420.69);
}
