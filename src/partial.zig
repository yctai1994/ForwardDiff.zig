const std = @import("std");
const testing = std.testing;

pub fn add(comptime T: type, x: T, y: T) T {
    var z: T = undefined;
    inline for (&z, 0..) |*p, i| p.* = x[i] + y[i];
    return z;
}

test "Test add" {
    const x: [3]f64 = .{ 1, 2, 3 };
    const y: [3]f64 = .{ 4, 3, 2 };
    const z = add([3]f64, x, y);
    try testing.expectEqual([3]f64, @TypeOf(z));
    for (z) |v| try testing.expectEqual(5, v);
}
