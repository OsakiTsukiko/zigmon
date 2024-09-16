# Zig bindings for the C library [dmon](https://github.com/septag/dmon).
## Getting started
Copy (or use git submodule) `zigmon` to a subdirectory of your project and add the following to your `build.zig.zon` .dependencies:
```zig
    .zigmon = .{ .path = "libs/zigmon" },
```
Then in your `build.zig` add:
```zig
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{ ... });

    const zigmon = b.dependency("zigmon", .{});
    exe.root_module.addImport("zigmon", zigmon.module("root"));
    exe.linkLibrary(zigmon.artifact("zigmon"));
}
```
## Example Code
```zig
const std = @import("std");
const zm = @import("zigmon").ZigMon;

fn watch_callback(
    _: zm.WatchID, // watch_id
    _: zm.Actions, // action
    // if you know what you are doing you can change the
    // type of the following 3 arguments to `[*:0]const`
    // only use `old_filepath` for `move` action
    // it will be null otherwise
    _: ?[*:0]const u8, // root_dir
    _: ?[*:0]const u8, // filepath
    _: ?[*:0]const u8, // old_filepath
    _: ?*anyopaque, // user
) void {
    std.debug.print("NEW EVENT\n", .{});
}


pub fn main() !void {
    zm.init();

    _ = zm.watch(
        "/path/to/directory", 
        @as(*const anyopaque, @ptrCast(&watch_callback)),
        .recursive,
        null,
    );

    while (true) {}

    zm.deinit();
}
```
## Useful
To better understand how to use, look into `src/zigmon.zig` and `libs/dmon/dmon.h`.
