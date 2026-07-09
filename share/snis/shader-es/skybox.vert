
uniform highp mat4 MVP;

attribute highp vec3 vertex;
varying mediump vec3 texCoord;

void main() {
	texCoord = vertex;
	gl_Position = MVP * vec4(vertex, 1.0);
}

