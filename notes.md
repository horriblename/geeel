# Vertex Buffer Objects (VBO)

Used to store large number of vertices in the GPU's memory.

OpenGL has many types of buffer objects and the buffer type of a VBO is `GL_ARRAY_BUFFER`.

OpenGL allows to bind to several buffers at once as long as they have a different buffer type. We
can bind the newly created buffer to the GL_ARRAY_BUFFER target with `glBindBuffer`

# Shader Program and linking

A shader program object is the final linked version of multiple shaders combines. To use our
compiled shaders we have to _link_ them to a shader program object, and activate this shader
program when rendering obejcts.

```c
unsigned int shaderProgram = glCreateProgram();

// linking shaders
glAttachShader(shaderProgram, vertexShader);
glAttachShader(shaderProgram, fragmentShader);
glLinkProgram(shaderProgram);
```

# Vertex Attributes

The vertex shader allows us to specify any input we want in the form of vertex attributes and while
this allows for great flexibility, we have to manually specify what part of our input data goes to
which vertex attribute in the vertex shader. This means we have to specify **how OpenGL should
interpret the vertex data** before rendering.

# Vertex Array Object (VAO)

VAO can be bound just like a VBO.

> Core OpenGL requires VAO so it knows what to do with our vertex inputs

VAO stores:

- calls to `glEnableVertexAttribArray` or `glDisableVertexAttribArray`
- Vertex attribute configurations via glVertexAttribPointer.
- Vertex buffer objects associated with vertex attributes by calls to glVertexAttribPointer

# Element Buffer Objectss (EBO)

Suppose we want to draw a rectangle instead of a triangle. We can draw a rectangle using two
triangles - 6 vertices, 2 vertices from each triangle overlap. Instead, we can use an EBO to store
the unique vertices then specify the order to draw the vertices in.

```c
// Using VBO to draw 2 triangles:
float vertices[] = {
    // first triangle
    0.5f, 0.5f, 0.0f, // top right
    0.5f, -0.5f, 0.0f, // bottom right
    -0.5f, 0.5f, 0.0f, // top left
    // second triangle
    0.5f, -0.5f, 0.0f, // bottom right
    -0.5f, -0.5f, 0.0f, // bottom left
    -0.5f, 0.5f, 0.0f // top left
};

// Using EBO to draw 2 triangles:
float vertices[] = {
    0.5f, 0.5f, 0.0f, // top right
    0.5f, -0.5f, 0.0f, // bottom right
    -0.5f, -0.5f, 0.0f, // bottom left
    -0.5f, 0.5f, 0.0f // top left
};

unsigned int indices[] = { // note that we start from 0!
    0, 1, 3, // first triangle
    1, 2, 3 // second triangle
};

// ...
unsigned int EBO;
glGenBuffers(1, &EBO);

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
```
