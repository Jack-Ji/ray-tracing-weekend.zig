const Ray = @import("Ray.zig");
const Vec = @import("Vec.zig");
const hitable = @import("hitable.zig");

pub const ScatteredRay = struct {
    ray: Ray = undefined,
    attenuation: Vec = undefined,
    reflected: bool = undefined,
    retracted: bool = undefined,
};

pub const Material = struct {
    scatterFn: fn (mt: *const Material, ray: Ray, record: hitable.HitRecord) ?ScatteredRay,

    pub fn scatter(self: *const Material, ray: Ray, record: hitable.HitRecord) ?ScatteredRay {
        return self.scatterFn(self, ray, record);
    }
};

pub const Lambertian = @import("material/Lambertian.zig");
pub const Metal = @import("material/Metal.zig");
pub const Dielectric = @import("material/Dielectric.zig");
