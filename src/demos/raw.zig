const std = @import("std");

const zm = @import("zigmon");
const raw = zm.Raw;

fn watch_callback(
    _: raw.WatchID,
    action: raw.Action,
    _: [*c]const u8,
    file: [*c]const u8,
    _: [*c]const u8,
    _: ?*anyopaque,
) callconv(.c) void {
    std.debug.print(
        \\
        \\Something happened:
        \\ - file:   {s}
        \\ - action: {}
        \\
    , .{ file, action });
}

pub fn main() !void {
    raw.init();
    defer raw.deinit();

    const id = raw.watch(
        ".",
        &watch_callback,
        @intFromEnum(raw.WatchFlags.recursive),
        null,
    );
    defer raw.unwatch(id);

    std.debug.print("Running demo for 10 seconds.\n", .{});
    std.time.sleep(std.time.ns_per_s * 10);
}
