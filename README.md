# Zig bindings for the C library [dmon](https://github.com/septag/dmon).

## Getting started
```
zig fetch --save git+https://github.com/OsakiTsukiko/zigmon
```

Then in your `build.zig` add:
```zig
const zigmon = b.dependency("zigmon", .{});
exe.root_module.addImport("zigmon", zigmon.module("zigmon"));
```

## Example Code
```zig
const std = @import("std");
const zm = @import("zigmon");

const Watcher = zm.Watcher(i64);

fn on_change(watcher: Watcher, _: zm.Action, _: []const u8, _: ?[]const u8) void {
    std.debug.print("\nSomething happened ({}):\n", .{watcher.data});
}

pub fn main() !void {
    zm.init();
    defer zm.deinit();

    var my_watcher: Watcher = .{
        .root = ".",
        .data = 1337,

        .on_change = on_change,
    };
    try my_watcher.watch();
    defer my_watcher.unwatch();
}
```

## Demos
```shell
# Will run src/demos/main.zig (wrapper)
zig build demo

# Will run src/demos/raw.zig (native)
zig build demo-raw
```

## Useful
To better understand how to use, look into `src/demos/main.zig` and `src/demos/raw.zig` (for the raw version of this binding).

> **Note:** Used by [Makko](https://forge.starlightnet.work/Team/Makko)
