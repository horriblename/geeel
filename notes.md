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
