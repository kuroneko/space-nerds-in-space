
uniform highp mat4 u_MVPMatrix;  // A constant representing the combined model/view/projection matrix.
uniform highp mat4 u_MVMatrix;   // A constant representing the combined model/view matrix.
uniform mediump mat3 u_NormalMatrix;
uniform lowp vec3 u_Color;      // Per-object color information we will pass in.
uniform lowp float u_in_shade;  // 1.0 means in full shade.  0.0 means not in shade.
			   // This is used for macro shading of whole objects
			   // e.g. a ship shaded by a planet
uniform lowp float u_Ambient;   // Ambient light, 0.1 is ok value

uniform highp vec3 u_LightPos;   // The position of the light in eye space.

attribute highp vec4 a_Position; // Per-vertex position information we will pass in.
attribute mediump vec3 a_Normal;   // Per-vertex normal information we will pass in.

varying lowp vec3 v_Color;      // This will be passed into the fragment shader.

void main()                // The entry point for our vertex shader.
{
	// Transform the vertex into eye space.
	highp vec3 modelViewVertex = vec3(u_MVMatrix * a_Position);

	// Transform the normal's orientation into eye space.
	mediump vec3 modelViewNormal = normalize(u_NormalMatrix * a_Normal);

	// Get a lighting direction vector from the light to the vertex.
	mediump vec3 lightVector = normalize(u_LightPos - modelViewVertex);

	// Calculate the dot product of the light vector and vertex normal. If the normal and light vector are
	// pointing in the same direction then it will get max illumination.
	lowp float dotV = (1.0 - u_in_shade) * dot(modelViewNormal, lightVector);

	// mimic the original snis software render lighting
	/* dotV = (dotV + 1.0) / 2.0; */

	// ambient
	lowp float diffuse = max(dotV, u_Ambient);

	// Multiply the color by the illumination level. It will be interpolated across the triangle.
	v_Color = u_Color * diffuse;

	// gl_Position is a special variable used to store the final position.
	// Multiply the vertex by the matrix to get the final point in normalized screen coordinates.
	gl_Position = u_MVPMatrix * a_Position;
}

