const std = @import("std");
const utils = @import("../utils.zig");
const Ray = @import("../Ray.zig");
const Vec = @import("../Vec.zig");
const hitable = @import("../hitable.zig");
const material = @import("../material.zig");

const Self = @This();

albedo: Vec = undefined,
material: material.Material = undefined,

pub fn new(allocator: std.mem.Allocator, a: Vec) *Self {
    var mt = allocator.create(Self) catch unreachable;
    mt.albedo = a;
    mt.material = .{
        .scatterFn = scatter,
    };
    return mt;
}

fn scatter(mt: *const material.Material, ray: Ray, record: hitable.HitRecord) ?material.ScatteredRay {
    _ = ray;

    const self = @fieldParentPtr(Self, "material", mt);
    const target = record.p
        .add(record.normal)
        .add(utils.randomInUnitSphere());
    return material.ScatteredRay{
        .ray = Ray.new(record.p, target.sub(record.p)),
        .attenuation = self.albedo,
        .reflected = false,
        .retracted = false,
    };
}
