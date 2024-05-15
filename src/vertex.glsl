// use OpenGL 3.3, core profile
#version 330 core

layout (location = 0) in vec3 aPos;
//      ^^^^^^^^^^^^  ^^ ^^^^
//            │        │   └── GLSL has vec1 ~ vec4 vector datatypes
//            │        └─ "in" means input
//            └─ TBD

// vec4 values can be accessed via vec.x, vec.y, vec.z and vec.w
// Note that vec.w is not used as a position in space, but for perspective division (more later)

void main() {
	// predefined var gl_Position is used to set the output of the vertex shader
	gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
	
}
