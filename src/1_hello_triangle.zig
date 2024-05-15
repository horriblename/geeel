const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const AppError = error{
    CreateWindow,
    InitializeGLAD,
};

pub fn main() !void {
    _ = c.glfwInit();
    _ = c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    _ = c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    _ = c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(800, 600, "LearnOpenGL", null, null) orelse {
        return AppError.CreateWindow;
    };

    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@as(c.GLADloadproc, @ptrCast(&c.glfwGetProcAddress))) == 0) {
        return AppError.InitializeGLAD;
    }

    c.glViewport(0, 0, 800, 600);
    _ = c.glfwSetFramebufferSizeCallback(window, &framebuffer_size_callback);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    _ = c.glfwTerminate();
}

fn framebuffer_size_callback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}
