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
const fragShaderSource: [*c]const u8 =
    \\#version 330 core
    \\out vec4 FragColor;
    \\uniform vec4 ourColor;
    \\void main() {
    \\  FragColor = ourColor;
    \\}
;

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
    const shaderProgram = shaderProg: {
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

        // Compile fragment shader
        const fragShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
        c.glShaderSource(fragShader, 1, &fragShaderSource, null);
        c.glCompileShader(fragShader);

        // Check for errors
        c.glGetShaderiv(fragShader, c.GL_COMPILE_STATUS, &ok);
        if (ok == 0) {
            c.glGetShaderInfoLog(fragShader, 512, null, &infoLog);
            std.log.err("compiling fragment shader: {any}", .{infoLog});
            return AppError.CompileShaderFailed;
        }

        // Link Shader program
        const shaderProgram = c.glCreateProgram();
        c.glAttachShader(shaderProgram, vertexShader);
        c.glAttachShader(shaderProgram, fragShader);
        c.glLinkProgram(shaderProgram);

        // Check for errors
        c.glGetProgramiv(shaderProgram, c.GL_LINK_STATUS, &ok);
        if (ok == 0) {
            c.glGetProgramInfoLog(shaderProgram, 512, null, &infoLog);
            std.log.err("compiling shader program: {any}", .{infoLog});
            return AppError.CompileShaderFailed;
        }

        c.glDeleteShader(vertexShader);
        c.glDeleteShader(fragShader);

        break :shaderProg shaderProgram;
    };

    // Set up vertex data
    const vertices = [_]f32{
        //x,  y,    z
        0,    0.5,  0.0,
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
    };

    // vao will store our vertex attribute configuration and which VBO to use.
    // usually when you have multiple objects to draw, you first generate/configure all the VAOs + the required VBO and
    // attribute pointers, and store those for later use.
    var vao: c_uint = 0;
    var vbo: c_uint = 0; // vbo contains the vertices
    c.glGenVertexArrays(1, &vao);
    c.glGenBuffers(1, &vbo);
    c.glBindVertexArray(vao);

    // Initialize VAO and VBO
    {
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
        c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, c.GL_STATIC_DRAW);

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

        const time = c.glfwGetTime();
        const greenValue = std.math.sin(time) / 2.0 + 0.5;
        const vertexColorLocation = c.glGetUniformLocation(shaderProgram, "ourColor");

        c.glUseProgram(shaderProgram);
        c.glUniform4f(vertexColorLocation, 0.0, @floatCast(greenValue), 0.0, 1.0);

        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

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
