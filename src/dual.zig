const std = @import("std");
const testing = std.testing;
const partial = @import("./partial.zig");

pub fn Dual(comptime T: type, comptime N: usize) type {
    // T: value type, N: dimension
    return struct { value: T, partials: [N]T };
}

fn isDual(comptime T: type) bool {
    const name: []const u8 = @typeName(T);
    for ("dual.Dual", 0..) |c, i| {
        if (name[i] != c) return false;
    }
    return true;
}

test "Test isDual" {
    const Dualf32 = Dual(f32, 2);
    try testing.expectEqual(true, isDual(Dualf32));
}

pub fn add(x: anytype, y: anytype) @TypeOf(x) {
    const Tx: type = @TypeOf(x);
    comptime {
        if (!isDual(Tx)) @compileError("add: input `x` should be a `Dual`.");
        if (Tx != @TypeOf(y)) @compileError("add: input `y` should be a `Dual`.");
    }

    const Ta: type = @typeInfo(Tx).Struct.fields[1].type;

    return .{
        .value = x.value + y.value,
        .partials = partial.add(Ta, x.partials, y.partials),
    };
}

test "Dual: add" {
    const Dualf32 = Dual(f32, 2);
    const a: Dualf32 = .{ .value = 1, .partials = .{ 1, 0 } };
    const b: Dualf32 = .{ .value = 2, .partials = .{ 0, 1 } };
    const c: Dualf32 = add(a, b);

    try testing.expectEqual(Dualf32, @TypeOf(c));
    try testing.expectEqual(3, c.value);
    for (0..2) |i| {
        try testing.expectEqual(1, c.partials[i]);
    }
}
