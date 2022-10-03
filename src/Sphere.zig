const std = @import("std");
const Vec = @import("Vec.zig");
const Ray = @import("Ray.zig");
const hitable = @import("hitable.zig");
const material = @import("material.zig");
const Sphere = @This();

center: Vec = undefined,
radius: f32 = undefined,
hitable: hitable.Hitable = undefined,
material: *const material.Material = undefined,

pub fn new(allocator: std.mem.Allocator, cen: Vec, r: f32, mt: ?*const material.Material) *Sphere {
    var s = allocator.create(Sphere) catch unreachable;
    s.center = cen;
    s.radius = r;
    s.hitable = .{
        .hitFn = hit,
    };
    s.material = mt.?;
    return s;
}

fn hit(ht: *hitable.Hitable, ray: Ray, t_min: f32, t_max: f32) ?hitable.HitRecord {
    const self = @fieldParentPtr(Sphere, "hitable", ht);
    const oc = ray.origin().sub(self.center);
    const a = ray.direction().dot(ray.direction());
    const b = oc.dot(ray.direction());
    const c = oc.dot(oc) - self.radius * self.radius;
    const discriminant = b * b - a * c;
    if (discriminant > 0) {
        var record: hitable.HitRecord = undefined;
        var temp = (-b - std.math.sqrt(discriminant)) / a;
        if (temp > t_min and temp < t_max) {
            record.t = temp;
            record.p = ray.pointAtParameter(temp);
            record.normal = record.p.sub(self.center).div(self.radius);
            record.material = self.material;
            return record;
        }

        temp = (-b + std.math.sqrt(discriminant)) / a;
        if (temp > t_min and temp < t_max) {
            record.t = temp;
            record.p = ray.pointAtParameter(temp);
            record.normal = record.p.sub(self.center).div(self.radius);
            record.material = self.material;
            return record;
        }
    }
    return null;
}
