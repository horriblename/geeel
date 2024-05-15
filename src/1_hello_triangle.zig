const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const AppError = error{
    CreateWindow,
    InitializeGLAD,
    CompileShaderFailed,
};

const vertexShaderSource: [*c]const u8 = @embedFile("vertex.glsl");

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

    // Normalized Device Coordinates(NDC): x, y, z range from -1.0 to 1.0, coordinates outside are clipped
    //
    // The NDC coordinates will be transformed to screen-space coordinates via the viewport transform using
    // data from glViewport
    const vertices = [_]f32{
        //x,  y,    z
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        0.0,  0.5,  0.0,
    };

    var vbo: c_uint = 0;
    c.glGenBuffers(1, &vbo);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);

    // glBufferData is used to copy user-defined data into the currently bound buffer
    //
    // The fourth parameter specifies how we want the graphics card to manage the data, one of:
    // - GL_STREAM_DRAW: the data is set only once and used by the GPU at most a few times.
    // - GL_STATIC_DRAW: the data is set only once and used many times.
    // - GL_DYNAMIC_DRAW: the data is changed a lot and used many times.
    c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len, &vertices, c.GL_STATIC_DRAW);

    // Compile vertex shader
    const vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(vertexShader, 1, &vertexShaderSource, null);
    c.glCompileShader(vertexShader);

    // Check for errors
    var ok: c_int = 0;
    var infoLog = std.mem.zeroes([512]u8);
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &ok);
    if (ok == 0) {
        c.glGetShaderInfoLog(vertexShader, 512, null, &infoLog);
        std.log.err("compiling vertex shader: {any}", .{infoLog});
        return AppError.CompileShaderFailed;
    }

    while (c.glfwWindowShouldClose(window) == 0) {
        // input
        processInput(window);

        // rendering commands here
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        // check and call events and swap the buffers
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    _ = c.glfwTerminate();
}

fn framebuffer_size_callback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}

fn processInput(window: *c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, 1);
    }
}
