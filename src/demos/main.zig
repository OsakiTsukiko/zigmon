const std = @import("std");
const zm = @import("zigmon");

const Watcher = zm.Watcher(i64);

fn on_change(_: Watcher, _: zm.Action, _: []const u8, _: ?[]const u8) void {
    std.debug.print("\nSomething happened:\n", .{});
}

fn on_create(watcher: Watcher, file: []const u8) void {
    std.debug.print(
        "-> Created: {s}, data: {}\n",
        .{ file, watcher.data },
    );
}

fn on_delete(watcher: Watcher, file: []const u8) void {
    std.debug.print(
        "-> Deleted: {s}, data: {}\n",
        .{ file, watcher.data },
    );
}

fn on_modify(watcher: Watcher, file: []const u8) void {
    std.debug.print(
        "-> Modified: {s}, data: {}\n",
        .{ file, watcher.data },
    );
}

fn on_move(watcher: Watcher, file: []const u8, from: []const u8) void {
    std.debug.print(
        "-> Moved: {s} to {s}, data: {}\n",
        .{ from, file, watcher.data },
    );
}

pub fn main() !void {
    zm.init();
    defer zm.deinit();

    var my_watcher: Watcher = .{
        .root = ".",
        .data = 1337,

        .on_change = on_change,
        .on_create = on_create,
        .on_delete = on_delete,
        .on_modify = on_modify,
        .on_move = on_move,
    };
    try my_watcher.watch();
    defer my_watcher.unwatch();

    std.debug.print("Running demo for 10 seconds.\n", .{});
    std.debug.print("my-watcher.data = {}\n", .{my_watcher.data});
    std.time.sleep(std.time.ns_per_s * 10);
}
