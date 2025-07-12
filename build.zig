const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("root", .{
        .root_source_file = b.path("src/zigmon.zig"),
    });

    const lib = b.addStaticLibrary(.{
        .name = "zigmon",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(b.path("src/dmon"));
    lib.addCSourceFile(.{
        .file = b.path("src/dmon/dmon.c"),
        .flags = &.{
            // "-std=c99",
            "-fno-sanitize=undefined",
        },
    });

    module.linkLibrary(lib);

    {
        const demo_raw_mod = b.createModule(.{
            .root_source_file = b.path("src/demos/raw.zig"),
            .target = target,
            .optimize = optimize,
        });

        const demo_raw = b.addExecutable(.{
            .name = "zigmod-demo-raw",
            .root_module = demo_raw_mod,
        });

        demo_raw.root_module.addImport("zigmon", module);

        b.installArtifact(demo_raw);

        const demo_cmd = b.addRunArtifact(demo_raw);
        demo_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            demo_cmd.addArgs(args);
        }

        const demo_step = b.step("demo-raw", "Run the raw binding demo");
        demo_step.dependOn(&demo_cmd.step);
    }

    {
        const demo_raw = b.createModule(.{
            .root_source_file = b.path("src/demos/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        const demo = b.addExecutable(.{
            .name = "zigmod-demo",
            .root_module = demo_raw,
        });

        demo.root_module.addImport("zigmon", module);

        b.installArtifact(demo);

        const demo_cmd = b.addRunArtifact(demo);
        demo_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            demo_cmd.addArgs(args);
        }

        const demo_step = b.step("demo", "Run the demo");
        demo_step.dependOn(&demo_cmd.step);
    }
}
