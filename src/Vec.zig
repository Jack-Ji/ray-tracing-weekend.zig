const std = @import("std");

const Vec = @This();

elements: [3]f32 = undefined,

pub fn zeros() Vec {
    return Vec{
        .elements = .{ 0, 0, 0 },
    };
}

pub fn ones() Vec {
    return Vec{
        .elements = .{ 1, 1, 1 },
    };
}

pub fn new(e0: f32, e1: f32, e2: f32) Vec {
    return Vec{
        .elements = .{ e0, e1, e2 },
    };
}

pub fn cross(v1: Vec, v2: Vec) Vec {
    return Vec{
        .elements = .{
            (v1.elements[1] * v2.elements[2] - v1.elements[2] * v2.elements[1]),
            -(v1.elements[0] * v2.elements[2] - v1.elements[2] * v2.elements[0]),
            (v1.elements[0] * v2.elements[1] - v1.elements[1] * v2.elements[0]),
        },
    };
}

pub fn x(self: Vec) f32 {
    return self.elements[0];
}

pub fn y(self: Vec) f32 {
    return self.elements[1];
}

pub fn z(self: Vec) f32 {
    return self.elements[2];
}

pub fn r(self: Vec) f32 {
    return self.elements[0];
}

pub fn g(self: Vec) f32 {
    return self.elements[1];
}

pub fn b(self: Vec) f32 {
    return self.elements[2];
}

pub fn neg(self: Vec) Vec {
    return new(
        -self.elements[0],
        -self.elements[1],
        -self.elements[2],
    );
}

pub fn unit(self: Vec) Vec {
    const l = self.squaredLength();
    const k = 1.0 / l;
    return new(
        self.elements[0] * k,
        self.elements[1] * k,
        self.elements[2] * k,
    );
}

pub fn squaredLength(self: Vec) f32 {
    return std.math.sqrt(
        self.elements[0] * self.elements[0] + self.elements[1] * self.elements[1] + self.elements[2] * self.elements[2],
    );
}

pub fn add(v1: Vec, v2: anytype) Vec {
    const T = @TypeOf(v2);
    return switch (T) {
        Vec => new(
            v1.elements[0] + v2.elements[0],
            v1.elements[1] + v2.elements[1],
            v1.elements[2] + v2.elements[2],
        ),
        f32 => new(
            v1.elements[0] + v2,
            v1.elements[1] + v2,
            v1.elements[2] + v2,
        ),
        else => @compileError("doesn't support " ++ @typeName(T)),
    };
}

pub fn sub(v1: Vec, v2: anytype) Vec {
    const T = @TypeOf(v2);
    return switch (T) {
        Vec => new(
            v1.elements[0] - v2.elements[0],
            v1.elements[1] - v2.elements[1],
            v1.elements[2] - v2.elements[2],
        ),
        f32 => new(
            v1.elements[0] - v2,
            v1.elements[1] - v2,
            v1.elements[2] - v2,
        ),
        else => @compileError("doesn't support " ++ @typeName(T)),
    };
}

pub fn mul(v1: Vec, v2: anytype) Vec {
    const T = @TypeOf(v2);
    return switch (T) {
        Vec => new(
            v1.elements[0] * v2.elements[0],
            v1.elements[1] * v2.elements[1],
            v1.elements[2] * v2.elements[2],
        ),
        f32 => new(
            v1.elements[0] * v2,
            v1.elements[1] * v2,
            v1.elements[2] * v2,
        ),
        comptime_float => new(
            v1.elements[0] * @as(f32, v2),
            v1.elements[1] * @as(f32, v2),
            v1.elements[2] * @as(f32, v2),
        ),
        else => @compileError("doesn't support " ++ @typeName(T)),
    };
}

pub fn div(v1: Vec, v2: anytype) Vec {
    const T = @TypeOf(v2);
    return switch (T) {
        Vec => new(
            v1.elements[0] / v2.elements[0],
            v1.elements[1] / v2.elements[1],
            v1.elements[2] / v2.elements[2],
        ),
        f32 => new(
            v1.elements[0] / v2,
            v1.elements[1] / v2,
            v1.elements[2] / v2,
        ),
        else => @compileError("doesn't support " ++ @typeName(T)),
    };
}

pub fn dot(v1: Vec, v2: Vec) f32 {
    return v1.elements[0] * v2.elements[0] + v1.elements[1] * v2.elements[1] + v1.elements[2] * v2.elements[2];
}

pub fn format(self: Vec, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;

    const allocator = std.heap.page_allocator;
    const buf = try std.fmt.allocPrint(allocator, "{f} {f} {f}", .{ self.elements[0], self.elements[1], self.elements[2] });
    defer allocator.free(buf);
    try writer.writeAll(buf);
}
