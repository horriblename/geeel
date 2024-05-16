const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "geeel",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "geeel",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // GLAD
    const glad = b.addStaticLibrary(.{
        .name = "glad",
        .target = target,
        .optimize = optimize,
    });
    glad.linkLibC();
    // glad.force_pic = true;
    glad.addCSourceFile(.{
        .file = .{ .cwd_relative = "glad/src/glad.c" },
    });
    glad.addIncludePath(.{ .cwd_relative = "glad/include" });

    const glad_step = b.step("glad", "build glad");
    glad_step.dependOn(&glad.step);

    const triangleBuilder = TriangleBuilder{
        .target = target,
        .optimize = optimize,
        .glad = glad,
    };
    triangleBuilder.build(b, "triangle", "src/1_hello_triangle.zig");

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

const TriangleBuilder = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    glad: *std.Build.Step.Compile,

    fn build(self: TriangleBuilder, b: *std.Build, comptime name: []const u8, path: []const u8) void {
        const one = b.addExecutable(.{
            .name = "hello_triangle",
            .root_source_file = b.path(path),
            .target = self.target,
            .optimize = self.optimize,
        });
        one.linkLibrary(self.glad);
        one.addIncludePath(.{ .cwd_relative = "glad/include" });
        one.linkSystemLibrary("glfw");
        if (self.target.result.os.tag == .macos) {
            one.linkFramework("OpenGL");
        } else{
            one.linkSystemLibrary("gl");
        }
        one.linkLibC();
        b.installArtifact(one);

        const run_cmd1 = b.addRunArtifact(one);
        run_cmd1.step.dependOn(b.getInstallStep());

        const build1 = b.step(name, "Build " ++ name);
        build1.dependOn(&one.step);

        const run_step1 = b.step("run-" ++ name, "Run " ++ name);
        run_step1.dependOn(&run_cmd1.step);
    }
};
