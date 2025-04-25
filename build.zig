const std = @import("std");
const BuildConfig = struct { build: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode };

pub fn setup_day(name: []const u8, cfg: *const BuildConfig) !void {
    const file = cfg.build.fmt(
        "src/{s}/main.zig",
        .{name},
    );
    const exe_mod = cfg.build.createModule(.{
        .root_source_file = cfg.build.path(file),
        .target = cfg.target,
        .optimize = cfg.optimize,
    });

    const lib_regex = cfg.build.dependency("regex", .{});

    exe_mod.addImport("regex", lib_regex.module("regex"));
    exe_mod.addImport("util", cfg.build.createModule((.{
        .root_source_file = cfg.build.path("src/util.zig"),
        .target = cfg.target,
        .optimize = cfg.optimize,
    })));
    const exe = cfg.build.addExecutable(.{
        .name = name,
        .root_module = exe_mod,
    });

    cfg.build.installArtifact(exe);

    const run_cmd = cfg.build.addRunArtifact(exe);
    run_cmd.step.dependOn(cfg.build.getInstallStep());
    if (cfg.build.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = cfg.build.step(name,
        cfg.build.fmt("Run app for day {s}", .{name}));
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = cfg.build.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = cfg.build.addRunArtifact(exe_unit_tests);

    const test_name = cfg.build.fmt(
        "{s}_test",
        .{name},
    );
    const test_step = cfg.build.step(test_name,
        cfg.build.fmt("Run test for {s}", .{name}));
    test_step.dependOn(&run_exe_unit_tests.step);
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const config = BuildConfig{
        .build = b,
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{
            .preferred_optimize_mode = std.builtin.OptimizeMode.Debug
        })
    };
    try setup_day("day1", &config);
    try setup_day("day2", &config);
    try setup_day("day3", &config);
    try setup_day("day4", &config);
    try setup_day("day5", &config);

}
