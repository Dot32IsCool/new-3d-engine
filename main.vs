uniform mat4 model;
uniform mat4 projection;
uniform mat4 view;

vec4 position(mat4 _, vec4 vertex_position)
{
		return projection * view * model * vertex_position;
}