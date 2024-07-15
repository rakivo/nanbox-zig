const std = @import("std");

pub const Type = enum(u8) {
    I64,
    U64,
    F64
};

pub const NaNBox = union {
    v: f64,

    const Self = @This();

    const EXP_MASK: u64   = ((1 << 11) - 1) << 52;
    const TYPE_MASK: u64  = ((1 << 4) - 1) << 48;
    const VALUE_MASK: u64 = (1 << 48) - 1;

    const SUPPORTED_TYPES_MSG = "Supported types: " ++ @typeName(i64) ++ ", " ++ @typeName(u64) ++ ", " ++ @typeName(f64);

    inline fn mkInf() f64 {
        return @bitCast(EXP_MASK);
    }

    fn setType(x: f64, nanboxType: Type) f64 {
        var bits: u64 = @bitCast(x);
        const tv: u64 = @intFromEnum(nanboxType);
        bits = (bits & ~TYPE_MASK) | ((tv & 0xF) << 48);
        return @bitCast(bits);
    }

    pub fn getType(self: NaNBox) Type {
        if (!self.isNaN()) return .F64;
        return comptime switch ((@as(u64, self.value) & TYPE_MASK) >> 48) {
            1    => .F64,
            2    => .I64,
            3    => .U64,
            else => @compileError("Unsupported type")
        };
    }

    fn setValue(x: f64, value: i64) f64 {
        var bits: u64 = @bitCast(x);
        bits = (bits & ~VALUE_MASK) | (@abs(value) & VALUE_MASK) | if (value < 0) @as(u64, 1 << 63) else 0;
        return @bitCast(bits);
    }

    fn getValue(self: NaNBox) i64 {
        const bits: u64 = @bitCast(self.v);
        const value: i64 = @bitCast(bits & VALUE_MASK);
        return if ((bits & (1 << 63)) != 0) -value else value;
    }

    pub inline fn isF64(self: NaNBox) bool {
        return !self.isNaN();
    }

    pub inline fn isI64(self: NaNBox) bool {
        return self.isNaN() and self.getType() == .I64;
    }

    pub inline fn isU64(self: NaNBox) bool {
        return self.isNaN() and self.getType() == .U64;
    }

    pub fn as(self: Self, comptime T: type) T {
        return switch (T) {
            f64  => self.v,
            i64  => self.getValue(),
            u64  => @bitCast(self.getValue()),
            else => @compileError("Unsupported type: " ++ @typeName(T) ++ "\n" ++ SUPPORTED_TYPES_MSG),
        };
    }

    pub fn from(comptime T: type, v: T) NaNBox {
        return switch (T) {
            f64  => .{ .v = v },
            u64  => .{ .v = NaNBox.setType(NaNBox.setValue(NaNBox.mkInf(), @as(i64, @intCast(v))), .U64) },
            i64  => .{ .v = NaNBox.setType(NaNBox.setValue(NaNBox.mkInf(), v), .I64) },
            else => @compileError("Unsupported type: " ++ @typeName(T) ++ "\n" ++ SUPPORTED_TYPES_MSG),
        };
    }
};
