const std = @import("std");
const Vec = @import("Vec.zig");
const Ray = @import("Ray.zig");
const material = @import("material.zig");

pub const HitRecord = struct {
    t: f32,
    p: Vec,
    normal: Vec,
    material: *const material.Material,
};

pub const Hitable = struct {
    hitFn: fn (ht: *Hitable, ray: Ray, t_min: f32, t_max: f32) ?HitRecord,

    pub fn hit(self: *Hitable, ray: Ray, t_min: f32, t_max: f32) ?HitRecord {
        return self.hitFn(self, ray, t_min, t_max);
    }
};

pub const HitableList = struct {
    const ListType = std.ArrayList(*Hitable);

    list: ListType,
    hitable: Hitable,

    pub fn new() HitableList {
        return HitableList{
            .list = ListType.init(std.heap.page_allocator),
            .hitable = .{
                .hitFn = hit,
            },
        };
    }

    pub fn addHitable(self: *HitableList, ht: ?*Hitable) void {
        self.list.append(ht.?) catch unreachable;
    }

    pub fn hit(ht: *Hitable, ray: Ray, t_min: f32, t_max: f32) ?HitRecord {
        var self = @fieldParentPtr(HitableList, "hitable", ht);
        var record: HitRecord = undefined;
        var closest_so_far = t_max;
        var hit_anything = false;
        for (self.list.items) |it| {
            const rec = it.hit(ray, t_min, closest_so_far);
            if (rec) |r| {
                hit_anything = true;
                closest_so_far = r.t;
                record = r;
            }
        }
        return if (hit_anything) record else null;
    }
};
