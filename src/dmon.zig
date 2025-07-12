pub const WatchID = extern struct {
    id: c_uint,
};

pub const WatchFlags = enum(c_int) {
    recursive = 0x1,
    follow_symlinks = 0x2,
    outofscope_links = 0x4,
    ignore_directories = 0x8,
};

pub const Action = enum(c_int) {
    create = 1,
    delete,
    modify,
    move,
};

pub const init = dmon_init;
extern fn dmon_init() void;

pub const deinit = dmon_deinit;
extern fn dmon_deinit() void;

pub const watch = dmon_watch;
extern fn dmon_watch(
    root_dir: [*:0]const u8,
    watch_ch: *const Callback,
    flags: c_int,
    user_data: ?*anyopaque,
) WatchID;

pub const unwatch = dmon_unwatch;
extern fn dmon_unwatch(id: WatchID) void;

pub const Callback = fn (
    watch_id: WatchID,
    action: Action,
    root_dir: [*c]const u8,
    filepath: [*c]const u8,
    old_filepath: [*c]const u8,
    user: ?*anyopaque,
) callconv(.c) void;
