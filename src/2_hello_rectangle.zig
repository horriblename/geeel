const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});
const Shader = @import("Shader.zig");

const AppError = error{
    CreateWindow,
    InitializeGLAD,
    CompileShaderFailed,
};

const vertexShaderSource: [*c]const u8 = @embedFile("vertex.glsl");
const fragShaderSource: [*c]const u8 = @embedFile("frag.glsl");
const vertexShaderFile = "src/vertex.glsl";
const fragShaderFile = "src/frag.glsl";

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

    // Prepare the Shader Program
    const shader = try Shader.fromFile(vertexShaderFile, fragShaderFile);

    // Set up vertex data
    const vertices = [_]f32{
        //x,  y,    z
        0.5,  0.5,  0.0,
        0.5,  -0.5, 0.0,
        -0.5, -0.5, 0.0,
        -0.5, 0.5,  0.0,
    };
    const indices = [_]c_int{
        0, 1, 3, // first triangle
        1, 2, 3, // second
    };

    // vao will store our vertex attribute configuration and which VBO to use.
    // usually when you have multiple objects to draw, you first generate/configure all the VAOs + the required VBO and
    // attribute pointers, and store those for later use.
    var vao: c_uint = 0;
    var vbo: c_uint = 0; // vbo contains the vertices
    var ebo: c_uint = 0; // ebo contains the indices
    c.glGenVertexArrays(1, &vao);
    c.glGenBuffers(1, &vbo);
    c.glGenBuffers(1, &ebo);
    c.glBindVertexArray(vao);

    // Initialize VAO and VBO
    {
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
        c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, c.GL_STATIC_DRAW);

        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, ebo);
        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(@TypeOf(indices)), &indices, c.GL_STATIC_DRAW);

        c.glVertexAttribPointer(
            0, // attr index
            3, // vec3
            c.GL_FLOAT,
            c.GL_FALSE, // normalize?
            3 * @sizeOf(f32), // stride
            @ptrFromInt(0), // offset
        );
        c.glEnableVertexAttribArray(0);
    }

    // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

    while (c.glfwWindowShouldClose(window) == 0) {
        // input
        processInput(window);

        // rendering commands here
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        shader.use();
        c.glBindVertexArray(vao);
        c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, @ptrFromInt(0));

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
