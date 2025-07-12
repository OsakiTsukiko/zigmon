const std = @import("std");
pub const Raw = @import("dmon.zig");

pub const init = Raw.init;
pub const deinit = Raw.deinit;

pub const Action = Raw.Action;

pub fn Watcher(comptime T: type) type {
    return struct {
        const Self = @This();

        root: [*c]const u8,
        data: T,

        // Runs on any changes
        on_change: ?*const fn (
            watcher: Self,
            action: Action,
            path: []const u8,
            old: ?[]const u8,
        ) void = null,

        // Runs on specific changes.
        on_create: ?*const fn (watcher: Self, path: []const u8) void = null,
        on_delete: ?*const fn (watcher: Self, path: []const u8) void = null,
        on_modify: ?*const fn (watcher: Self, path: []const u8) void = null,
        on_move: ?*const fn (watcher: Self, path: []const u8, old: []const u8) void = null,

        raw: ?Raw.WatchID = null,
        flags: Flags = .{}, // Cannot be changed once watch() has been ran.

        pub const Flags = packed struct(u4) {
            recursive: bool = true,
            follow_symlinks: bool = false,
            out_of_scope_links: bool = false,
            ignore_directories: bool = false,
        };

        fn rawCallback(
            _: Raw.WatchID,
            action: Raw.Action,
            _: [*c]const u8,
            raw_filepath: [*c]const u8,
            raw_old_filepath: [*c]const u8,
            user: ?*anyopaque,
        ) callconv(.c) void {
            const raw_self: *Self = @alignCast(@ptrCast(user.?));
            const self = raw_self.*;

            const filepath = std.mem.span(raw_filepath.?);
            const old_filepath: ?[]const u8 =
                if (raw_old_filepath) |r_old_filepath|
                    std.mem.span(r_old_filepath)
                else
                    null;

            if (self.on_change) |on_change|
                on_change(self, action, filepath, old_filepath);

            switch (action) {
                .create => if (self.on_create) |on_create|
                    on_create(self, filepath),

                .delete => if (self.on_delete) |on_delete|
                    on_delete(self, filepath),

                .modify => if (self.on_modify) |on_modify|
                    on_modify(self, filepath),

                .move => if (self.on_move) |on_move|
                    on_move(self, filepath, old_filepath.?),
            }
        }

        pub fn watch(watcher: *Self) !void {
            if (watcher.raw) |_|
                return error.AlreadyWatching;

            watcher.raw =
                Raw.watch(
                    watcher.root,
                    &rawCallback,
                    @intCast(@as(u4, @bitCast(watcher.flags))),
                    watcher,
                );
        }

        pub fn unwatch(self: *Self) void {
            Raw.unwatch(self.raw.?);
            self.raw = null;
        }

        pub fn isWatching(self: Self) bool {
            return if (self.raw) |_| true else false;
        }
    };
}
