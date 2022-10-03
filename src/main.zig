const std = @import("std");
const out = std.io.getStdOut().writer();

const Camera = @import("Camera.zig");
const Ray = @import("Ray.zig");
const Vec = @import("Vec.zig");
const Sphere = @import("Sphere.zig");
const material = @import("material.zig");
const hitable = @import("hitable.zig");
const utils = @import("utils.zig");
const randFloat = utils.prng.random().float;

fn color(ray: Ray, world: *hitable.Hitable, depth: i32) Vec {
    var record = world.hit(ray, 0.001, std.math.f32_max);
    if (record) |rec| {
        const scattered = rec.material.scatter(ray, rec);
        if (scattered) |sc| {
            return if (depth < 50)
                sc.attenuation.mul(color(sc.ray, world, depth + 1))
            else
                Vec.zeros();
        } else {
            return Vec.zeros();
        }
    }

    const unit_direction = ray.direction().unit();
    const t = 0.5 * (unit_direction.y() + 1.0);
    return Vec.ones().mul(1.0 - t)
        .add(Vec.new(0.5, 0.7, 1.0).mul(t));
}

fn randomScene() hitable.HitableList {
    var allocator = std.heap.page_allocator;
    var world = hitable.HitableList.new();
    var sphere = Sphere.new(
        allocator,
        Vec.new(0, -1000, 0),
        1000,
        &material.Lambertian.new(allocator, Vec.new(0.5, 0.5, 0.5)).material,
    );
    world.addHitable(&sphere.hitable);

    var a: i32 = -11;
    while (a < 11) : (a += 1) {
        var b: i32 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = randFloat(f32);
            const center = Vec.new(
                @intToFloat(f32, a) + 0.9 * randFloat(f32),
                0.2,
                @intToFloat(f32, b) + 0.9 * randFloat(f32),
            );
            if (center.sub(Vec.new(4, 0.2, 0)).squaredLength() > 0.9) {
                if (choose_mat < 0.5) { // diffuse
                    sphere = Sphere.new(
                        allocator,
                        center,
                        0.2,
                        &material.Lambertian.new(
                            allocator,
                            Vec.new(
                                randFloat(f32) * randFloat(f32),
                                randFloat(f32) * randFloat(f32),
                                randFloat(f32) * randFloat(f32),
                            ),
                        ).material,
                    );
                } else if (choose_mat < 0.75) { // metal
                    sphere = Sphere.new(
                        allocator,
                        center,
                        0.2,
                        &material.Metal.new(
                            allocator,
                            Vec.new(
                                0.5 * (1 + randFloat(f32)),
                                0.5 * (1 + randFloat(f32)),
                                0.5 * (1 + randFloat(f32)),
                            ),
                            0.5 * randFloat(f32),
                        ).material,
                    );
                } else { //glass
                    sphere = Sphere.new(
                        allocator,
                        center,
                        0.2,
                        &material.Dielectric.new(allocator, 1.5).material,
                    );
                }
                world.addHitable(&sphere.hitable);
            }
        }
    }

    sphere = Sphere.new(
        allocator,
        Vec.new(0, 1, 0),
        1,
        &material.Dielectric.new(allocator, 1.5).material,
    );
    world.addHitable(&sphere.hitable);
    sphere = Sphere.new(
        allocator,
        Vec.new(-4, 1, 0),
        1,
        &material.Lambertian.new(allocator, Vec.new(0.4, 0.2, 0.1)).material,
    );
    world.addHitable(&sphere.hitable);
    sphere = Sphere.new(
        allocator,
        Vec.new(4, 1, 0),
        1,
        &material.Metal.new(allocator, Vec.new(0.7, 0.6, 0.5), 0).material,
    );
    world.addHitable(&sphere.hitable);
    return world;
}

pub fn main() anyerror!void {
    const nx = 640;
    const ny = 320;
    const ns = 100;

    // setup scene
    var world = randomScene();

    // setup camera
    const lookfrom = Vec.new(16, 2, 4);
    const lookat = Vec.new(0, 0, 0);
    const vfov = 12;
    const dist_to_focus = lookfrom.sub(lookat).squaredLength();
    const aperture = 0.2;
    const camera = Camera.new(
        lookfrom,
        lookat,
        Vec.new(0, 1, 0),
        vfov,
        @intToFloat(f32, nx) / @intToFloat(f32, ny),
        aperture,
        dist_to_focus,
    );

    // start rendering
    try out.print("P3\n{d} {d}\n255\n", .{ nx, ny });
    var j: i32 = ny - 1;
    while (j >= 0) : (j -= 1) {
        var i: i32 = 0;
        while (i < nx) : (i += 1) {
            var col = Vec.zeros();
            var s: i32 = 0;
            while (s < ns) : (s += 1) {
                const u = (@intToFloat(f32, i) + randFloat(f32)) / @intToFloat(f32, nx);
                const v = (@intToFloat(f32, j) + randFloat(f32)) / @intToFloat(f32, ny);
                const ray = camera.getRay(u, v);
                col = col.add(color(ray, &world.hitable, 0));
            }

            col = col.div(@intToFloat(f32, ns));
            col = Vec.new(
                std.math.sqrt(col.r()),
                std.math.sqrt(col.g()),
                std.math.sqrt(col.b()),
            );
            const ir = @floatToInt(i32, 255.99 * col.r());
            const ig = @floatToInt(i32, 255.99 * col.g());
            const ib = @floatToInt(i32, 255.99 * col.b());
            try out.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }
}
