pub const ZigMon = extern struct {
    pub const WatchID = extern struct {
        id: c_uint,
    };
    
    pub const WatchFlags = enum(c_int) {
        recursive = 0x1,
        follow_symlinks = 0x2,
        outofscope_links = 0x4,
        ignore_directories = 0x8,
    };

    pub const Actions = enum(c_int) {
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
        watch_ch: *const anyopaque,
        flags: WatchFlags,
        user_data: ?*anyopaque,
    ) ZigMon.WatchID;

    pub const callback = fn (
        watch_id: WatchID, 
        action: Actions,
        root_dir: [*:0]const u8,
        filepath: [*:0]const u8,
        old_filepath: [*:0]const u8,
        user: ?*anyopaque,
    ) void;
};