const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const opt = b.standardOptimizeOption(.{});
    
    const exe = b.addExecutable(.{
        .name = "vkzig-engine",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = opt,
    });
    
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}