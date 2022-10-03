const std = @import("std");
const utils = @import("../utils.zig");
const Ray = @import("../Ray.zig");
const Vec = @import("../Vec.zig");
const hitable = @import("../hitable.zig");
const material = @import("../material.zig");

const Self = @This();

ref_idx: f32 = undefined,
material: material.Material = undefined,

pub fn new(allocator: std.mem.Allocator, ref_idx: f32) *Self {
    var mt = allocator.create(Self) catch unreachable;
    mt.ref_idx = ref_idx;
    mt.material = .{
        .scatterFn = scatter,
    };
    return mt;
}

fn schlick(self: Self, cosine: f32) f32 {
    var r0 = (1.0 - self.ref_idx) / (1.0 + self.ref_idx);
    r0 *= r0;
    return r0 + (1.0 - r0) * std.math.pow(f32, 1 - cosine, 5);
}

fn scatter(mt: *const material.Material, ray: Ray, record: hitable.HitRecord) ?material.ScatteredRay {
    _ = ray;

    const self = @fieldParentPtr(Self, "material", mt);
    const reflected = utils.reflect(ray.direction().unit(), record.normal);
    const attenuation: Vec = Vec.new(1.0, 1.0, 1.0);
    var outward_normal: Vec = undefined;
    var ni_over_nt: f32 = undefined;
    var cosine: f32 = undefined;
    if (ray.direction().dot(record.normal) > 0) {
        outward_normal = record.normal.neg();
        ni_over_nt = self.ref_idx;
        cosine = ray.direction().dot(record.normal) * self.ref_idx / ray.direction().squaredLength();
    } else {
        outward_normal = record.normal;
        ni_over_nt = 1.0 / self.ref_idx;
        cosine = -ray.direction().dot(record.normal) / ray.direction().squaredLength();
    }
    const retracted = utils.retract(ray.direction(), outward_normal, ni_over_nt);
    if (retracted) |rt| {
        if (utils.prng.random().float(f32) < self.schlick(cosine)) {
            return material.ScatteredRay{
                .ray = Ray.new(record.p, rt),
                .attenuation = attenuation,
                .reflected = false,
                .retracted = true,
            };
        }
    }

    return material.ScatteredRay{
        .ray = Ray.new(record.p, reflected),
        .attenuation = attenuation,
        .reflected = true,
        .retracted = false,
    };
}
