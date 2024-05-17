// helper struct for compiling shaders
const std = @import("std");
const c = @import("gl.zig").c;
const Self = @This();
const global_allocator = std.heap.page_allocator;

pub const Error = error{
    VertexCompileError,
    FragmentCompileError,
    ProgramLinkError,
};

program: c_uint,

pub fn fromFile(vertexPath: []const u8, fragPath: []const u8) !Self {
    const allocator = global_allocator;
    const vertex_source = try readFile(allocator, vertexPath);
    defer allocator.free(vertex_source);

    // Compile vertex shader
    const vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(vertexShader, 1, @ptrCast(&vertex_source), null);
    c.glCompileShader(vertexShader);

    // Check for errors
    var ok: c_int = 0;
    var infoLog = std.mem.zeroes([512]u8);
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &ok);
    if (ok == 0) {
        c.glGetShaderInfoLog(vertexShader, 512, null, &infoLog);
        std.log.err("compiling vertex shader: {any}", .{infoLog});
        return Error.VertexCompileError;
    }
    defer c.glDeleteShader(vertexShader);

    const frag_source = try readFile(allocator, fragPath);
    defer allocator.free(frag_source);

    // Compile fragment shader
    const fragShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(fragShader, 1, @ptrCast(&frag_source), null);
    c.glCompileShader(fragShader);

    // Check for errors
    c.glGetShaderiv(fragShader, c.GL_COMPILE_STATUS, &ok);
    if (ok == 0) {
        c.glGetShaderInfoLog(fragShader, 512, null, &infoLog);
        std.log.err("compiling fragment shader: {any}", .{infoLog});
        return Error.VertexCompileError;
    }
    defer c.glDeleteShader(fragShader);

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
        return Error.ProgramLinkError;
    }

    return Self{ .program = shaderProgram };
}

// activate the shader
pub fn use(self: Self) void {
    c.glUseProgram(self.program);
}

pub fn setBool(self: Self, name: [*c]const u8, value: bool) void {
    c.glUniformli(c.glGetUniformLocation(self.program, name), value);
}

pub fn setInt(self: Self, name: [*c]const u8, value: bool) void {
    c.glUniformli(c.glGetUniformLocation(self.program, name), value);
}

pub fn setFloat(self: Self, name: [*c]const u8, value: f32) void {
    c.glUniformlf(c.glGetUniformLocation(self.program, name), value);
}

fn readFile(allocator: std.mem.Allocator, path: []const u8) ![:0]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    return try file.readToEndAllocOptions(allocator, 1 << 30, null, @alignOf(u8), 0);
}
