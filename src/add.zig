const std = @import("std");
const testing = std.testing;

fn Dual(comptime V: type, comptime D: usize) type { // V: value type, D: dimension
    return struct { value: V, partial: [D]V };
}

fn isDual(comptime T: type) bool {
    const name: []const u8 = @typeName(T);
    if (name[4] != 'D') return false;
    if (name[5] != 'u') return false;
    if (name[6] != 'a') return false;
    if (name[7] != 'l') return false;
    return true;
}

fn add(x: anytype, y: anytype) @TypeOf(x) {
    const Tx: type = @TypeOf(x);
    if (comptime !isDual(Tx)) @compileError("add: @TypeOf(x) should be a `Dual`.");
    if (Tx != @TypeOf(y)) @compileError("add: @TypeOf(y) should be a `Dual`.");

    const fields = @typeInfo(Tx).Struct.fields;

    switch (fields[0].type) {
        f16, f32, f64, f80, f128 => {},
        else => @compileError("add: `x`'s value type is invalid."),
    }

    var partial: fields[1].type = undefined;

    inline for (&partial, 0..) |*val, index| {
        val.* = x.partial[index] + y.partial[index];
    }

    return Tx{ .value = x.value + y.value, .partial = partial };
}

test "test: add()" {
    const Dualf32 = Dual(f32, 2);
    const a = Dualf32{ .value = 1.0, .partial = .{ 1.0, 0.0 } };
    const b = Dualf32{ .value = 1.0, .partial = .{ 0.0, 1.0 } };
    const c = add(a, b);
    try testing.expectEqual(true, isDual(@TypeOf(c)));
    try testing.expectEqual(2.0, c.value);
    try testing.expectEqual(1.0, c.partial[0]);
    try testing.expectEqual(1.0, c.partial[1]);
}
