const std = @import("std");
const c = @cImport({
    @cInclude("glfw3.h");
    @cInclude("vulkan/vulkan.h");
    @cInclude("vk_mem_alloc.h");
    @cInclude("stb_image.h");
});

