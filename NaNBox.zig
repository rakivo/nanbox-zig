// Copyright 2024 Mark Tyrkba <marktyrkba456@gmail.com>

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

const std = @import("std");

pub const Type = enum(u8) {
    I64,
    U64,
    F64
};

pub const NaNBox = union {
    v: f64,

    const Self = @This();

    const EXP_MASK: u64 = ((1 << 11) - 1) << 52;
    const TYPE_MASK: u64 = ((1 << 4) - 1) << 48;
    const VALUE_MASK: u64 = (1 << 48) - 1;

    const SUPPORTED_TYPES_MSG = "Supported types: " ++ @typeName(i64) ++ ", " ++ @typeName(u64) ++ ", " ++ @typeName(f64);

    inline fn mkInf() f64 {
        return @bitCast(EXP_MASK);
    }

    inline fn isNaN(self: Self) bool {
        return self.v != self.v;
    }

    fn setType(x: f64, ty: Type) f64 {
        var bits: u64 = @bitCast(x);
        const tv: u64 = @intFromEnum(ty);
        bits = (bits & ~TYPE_MASK) | ((tv & 0xF) << 48);
        return @bitCast(bits);
    }

    pub fn getType(self: Self) Type {
         if (!self.isNaN()) return .F64;
        const bits: u64 = @bitCast(self.v);
        return @enumFromInt((bits & TYPE_MASK) >> 48);
    }

    fn setValue(x: f64, value: i64) f64 {
        var bits: u64 = @bitCast(x);
        bits = (bits & ~VALUE_MASK) | (@abs(value) & VALUE_MASK) | if (value < 0) @as(u64, 1 << 63) else 0;
        return @bitCast(bits);
    }

    fn getValue(self: Self) i64 {
        const bits: u64 = @bitCast(self.v);
        const value: i64 = @intCast(bits & VALUE_MASK);
        return if ((bits & (1 << 63)) != 0) -value else value;
    }

    pub fn is(self: Self, comptime T: type) bool {
        return switch (T) {
            f64 => !self.isNaN(),
            i64 => self.isNaN() and self.getType() == .I64,
            u64 => self.isNaN() and self.getType() == .U64,
            inline else => @compileError("Unsupported type: " ++ @typeName(T) ++ "\n" ++ SUPPORTED_TYPES_MSG)
        };
    }

    pub fn as(self: Self, comptime T: type) T {
        return switch (T) {
            f64 => self.v,
            i64 => self.getValue(),
            u64 => @intCast(self.getValue()),
            inline else => @compileError("Unsupported type: " ++ @typeName(T) ++ "\n" ++ SUPPORTED_TYPES_MSG),
        };
    }

    pub fn from(comptime T: type, v: T) Self {
        return switch (T) {
            f64 => .{ .v = v },
            u64 => .{ .v = Self.setType(Self.setValue(Self.mkInf(), @as(i64, @intCast(v))), .U64) },
            i64 => .{ .v = Self.setType(Self.setValue(Self.mkInf(), v), .I64) },
            inline else => @compileError("Unsupported type: " ++ @typeName(T) ++ "\n" ++ SUPPORTED_TYPES_MSG),
        };
    }
};
