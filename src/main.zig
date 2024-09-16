const std = @import("std");
const testing = std.testing;

const zm = @import("./zigmon.zig").ZigMon;

fn watch_callback(
    _: zm.WatchID, 
    _: zm.Actions,
    _: *const u8,
    _: *const u8,
    _: *const u8,
    _: ?*anyopaque,
) void {
    std.debug.print("NEW EVENT\n", .{});
}

test "simple test" {
    zm.init();

    _ = zm.watch(
        "/home/osaki/test", 
        @as(*const anyopaque, @ptrCast(&watch_callback)),
        .recursive,
        null,
    );

    zm.deinit();
}