const std = @import("std");
const utils = @import("../utils.zig");
const Ray = @import("../Ray.zig");
const Vec = @import("../Vec.zig");
const hitable = @import("../hitable.zig");
const material = @import("../material.zig");

const Self = @This();

albedo: Vec = undefined,
fuzz: f32 = undefined,
material: material.Material = undefined,

pub fn new(allocator: std.mem.Allocator, a: Vec, fuzz: f32) *Self {
    var mt = allocator.create(Self) catch unreachable;
    mt.albedo = a;
    mt.fuzz = if (fuzz < 1) fuzz else 1;
    mt.material = .{
        .scatterFn = scatter,
    };
    return mt;
}

fn scatter(mt: *const material.Material, ray: Ray, record: hitable.HitRecord) ?material.ScatteredRay {
    _ = ray;

    const self = @fieldParentPtr(Self, "material", mt);
    const reflected = utils.reflect(ray.direction().unit(), record.normal);
    const scattered = Ray.new(
        record.p,
        reflected.add(utils.randomInUnitSphere().mul(self.fuzz)),
    );
    if (scattered.direction().dot(record.normal) > 0) {
        return material.ScatteredRay{
            .ray = scattered,
            .attenuation = self.albedo,
            .reflected = true,
            .retracted = false,
        };
    }
    return null;
}
