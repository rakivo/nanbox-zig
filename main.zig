const std = @import("std");

const print = std.debug.print;

const Type = @import("Type.zig").Type;
const NaNBox = @import("NaNBox.zig").NaNBox;

pub fn main() !void {
    const nan_u64 = NaNBox.from(u64, 69);
    print("nan_u64: {d}\n", .{nan_u64.as(u64)});
    print("nan_u64 size: {}\n", .{@sizeOf(@TypeOf(nan_u64))});

    const nan_i64 = NaNBox.from(i64, -69);
    print("\nnan_i64: {d}\n", .{nan_i64.as(i64)});
    print("nan_i64 size: {}\n", .{@sizeOf(@TypeOf(nan_i64))});

    const nan_f64 = NaNBox.from(f64, 420.69);
    print("\nnan_f64: {d}\n", .{nan_f64.as(f64)});
    print("nan_f64 size: {}\n", .{@sizeOf(@TypeOf(nan_f64))});
}
