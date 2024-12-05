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

    // link vulkan sdk
    const vk_lib_name = if (target.result.os.tag == .windows) "vulkan-1" else "vulkan";
    exe.linkSystemLibrary(vk_lib_name);
    const vk_sdk_path = std.process.getEnvVarOwned(b.allocator, "VK_SDK_PATH") catch 
        std.process.getEnvVarOwned(b.allocator, "VULKAN_SDK") catch |e| 
            std.debug.panic("Error getting VK_SDK_PATH or VULKAN_SDK env var: {}", .{e});
    defer b.allocator.free(vk_sdk_path);
    const vk_lib_path = std.fmt.allocPrint(b.allocator, "{s}/Lib/", .{ vk_sdk_path }) catch @panic("OOM");
    defer b.allocator.free(vk_lib_path);
    exe.addLibraryPath(.{ .cwd_relative = vk_lib_path });
    const vk_include_path = std.fmt.allocPrint(b.allocator, "{s}/Include/", .{ vk_sdk_path }) catch @panic("OOM");
    defer b.allocator.free(vk_include_path);
    exe.addIncludePath(.{ .cwd_relative = vk_include_path });
    // link glfw
    exe.addIncludePath(.{ .cwd_relative = "thirdparty/glfw/include/"});
    exe.addObjectFile(.{ .cwd_relative = "thirdparty/glfw/lib/glfw3.lib"});
    // link vma
    exe.addCSourceFile(.{ .file = b.path("thirdparty/vma/vk_mem_alloc.cpp"), .flags = &.{ "" } });
    exe.addIncludePath(b.path("thirdparty/vma/"));
    // link stb_image
    exe.addCSourceFile(.{ .file = b.path("thirdparty/stb/stb_image.c"), .flags = &.{ "" } });
    exe.addIncludePath(b.path("thirdparty/stb/"));

    exe.linkLibC();
    exe.linkLibCpp();

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}