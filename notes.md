# Vertex Buffer Objects (VBO)

Used to store large number of vertices in the GPU's memory.

OpenGL has many types of buffer objects and the buffer type of a VBO is `GL_ARRAY_BUFFER`.

OpenGL allows to bind to several buffers at once as long as they have a different buffer type. We
can bind the newly created buffer to the GL_ARRAY_BUFFER target with `glBindBuffer`
