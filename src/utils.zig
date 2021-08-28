const std = @import("std");
const Vec = @import("Vec.zig");

pub var prng = std.rand.DefaultPrng.init(0);

pub fn randomInUnitSphere() Vec {
    var p: Vec = undefined;
    while (true) {
        p = Vec.new(
            prng.random.float(f32),
            prng.random.float(f32),
            prng.random.float(f32),
        ).mul(2.0).sub(Vec.ones());
        if (p.squaredLength() < 1.0) break;
    }
    return p;
}

pub fn randomInUnitDisk() Vec {
    var p: Vec = undefined;
    while (true) {
        p = Vec.new(
            prng.random.float(f32),
            prng.random.float(f32),
            0,
        ).mul(2.0).sub(Vec.new(1, 1, 0));
        if (p.dot(p) < 1.0) break;
    }
    return p;
}

pub fn reflect(v: Vec, n: Vec) Vec {
    return v.sub(n.mul(v.dot(n) * 2.0));
}

pub fn retract(v: Vec, n: Vec, ni_over_nt: f32) ?Vec {
    const uv = v.unit();
    const dt = uv.dot(n);
    const discriminant = 1.0 - ni_over_nt * ni_over_nt * (1 - dt * dt);
    return if (discriminant > 0)
        uv.sub(n.mul(dt))
            .mul(ni_over_nt)
            .sub(n.mul(std.math.sqrt(discriminant)))
    else
        null;
}
