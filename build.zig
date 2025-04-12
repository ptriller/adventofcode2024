const std = @import("std");
const BuildConfig = struct {
    build: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode
};

pub fn setup_day(name: []const u8, cfg: * const BuildConfig) !void {
    // We will also create a module for our other entry point, 'main.zig'.
    const file = try std.fmt.allocPrint(
        std.heap.page_allocator,
        "src/{s}/main.zig",
        .{ name },
    );
    const exe_mod = cfg.build.createModule(.{
        // `root_source_file` is the Zig "entry point" of the module. If a module
        // only contains e.g. external object files, you can make this `null`.
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = cfg.build.path(file),
        .target = cfg.target,
        .optimize = cfg.optimize,
    });

    const lib_regex = cfg.build.dependency("regex", .{});

    exe_mod.addImport("regex", lib_regex.module("regex"));

    // This creates another `std.Build.Step.Compile`, but this one builds an executable
// rather than a static library.
    const exe = cfg.build.addExecutable(.{
        .name = name,
        .root_module = exe_mod,
    });

    cfg.build.installArtifact(exe);


    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = cfg.build.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(cfg.build.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (cfg.build.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = cfg.build.step(name, "Run app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = cfg.build.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = cfg.build.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_name = try std.fmt.allocPrint(
        std.heap.page_allocator,
        "{s}_test",
        .{ name },
    );
    const test_step = cfg.build.step(test_name, "Run test");
    test_step.dependOn(&run_exe_unit_tests.step);

}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {

    const config = BuildConfig{
        .build = b,
        .target = b.standardTargetOptions(.{}),
        .optimize =  b.standardOptimizeOption(.{})
    };

    try setup_day("day1", &config);
}
