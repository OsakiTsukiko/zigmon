const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
     const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("root", .{
        .root_source_file = b.path("src/zigmon.zig"),
    });

    const lib = b.addStaticLibrary(.{
        .name = "zigmon",
        // .root_source_file = b.path("src/zigmon.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(b.path("libs/dmon"));
    lib.addCSourceFile(.{
        .file = b.path("libs/dmon/dmon.c"),
        .flags = &.{ 
            // "-std=c99", 
            "-fno-sanitize=undefined" 
        },
    });
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_unit_tests.linkLibrary(lib);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
