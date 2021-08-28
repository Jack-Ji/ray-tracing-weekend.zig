const Ray = @This();
const Vec = @import("Vec.zig");

a: Vec = undefined,
b: Vec = undefined,

pub fn new(a: Vec, b: Vec) Ray {
    return Ray{
        .a = a,
        .b = b,
    };
}

pub fn origin(self: Ray) Vec {
    return self.a;
}

pub fn direction(self: Ray) Vec {
    return self.b;
}

pub fn pointAtParameter(self: Ray, t: f32) Vec {
    return self.b.mul(t).add(self.a);
}
