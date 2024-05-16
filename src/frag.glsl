#version 330 core

// the fragment shader only requires one output variables: a vec4 that defines the final color output that
// we should calculate ourselves. We can declare output values with the `out` keyword.
out vec4 FragColor;
// <- we can declare output values with the `out` keyword

void main() {
	// RGBA
	FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
