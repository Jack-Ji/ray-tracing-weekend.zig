const std = @import("std");
const utils = @import("utils.zig");
const Ray = @import("Ray.zig");
const Vec = @import("Vec.zig");

const Camera = @This();

origin: Vec = undefined,
lower_left_corner: Vec = undefined,
horizontal: Vec = undefined,
vertical: Vec = undefined,
u: Vec = undefined,
v: Vec = undefined,
w: Vec = undefined,
lens_radius: f32 = undefined,

pub fn new(lookfrom: Vec, lookat: Vec, vup: Vec, vfov: f32, aspect: f32, aperture: f32, focus_dist: f32) Camera {
    const lens_radius = aperture / 2;
    const w = lookfrom.sub(lookat).unit();
    const u = vup.cross(w).unit();
    const v = w.cross(u);
    const theta = vfov * @as(f32, std.math.pi) / 180.0;
    const half_height = std.math.tan(theta / 2);
    const half_width = aspect * half_height;
    return Camera{
        .origin = lookfrom,
        .lower_left_corner = lookfrom
            .sub(u.mul(half_width).mul(focus_dist))
            .sub(v.mul(half_height).mul(focus_dist))
            .sub(w.mul(focus_dist)),
        .horizontal = u.mul(2 * half_width * focus_dist),
        .vertical = v.mul(2 * half_height * focus_dist),
        .u = u,
        .v = v,
        .w = w,
        .lens_radius = lens_radius,
    };
}

pub fn getRay(self: Camera, s: f32, t: f32) Ray {
    const rd = utils.randomInUnitDisk().mul(self.lens_radius);
    const offset = self.u
        .mul(rd.x())
        .add(self.v.mul(rd.y()));
    return Ray.new(
        self.origin.add(offset),
        self.lower_left_corner
            .add(self.horizontal.mul(s))
            .add(self.vertical.mul(t))
            .sub(self.origin)
            .sub(offset),
    );
}
