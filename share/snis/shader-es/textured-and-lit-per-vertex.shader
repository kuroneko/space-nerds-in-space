

#if defined(INCLUDE_VS)
	varying lowp vec3 v_LightColor;
	varying mediump vec2 v_TexCoord;
	uniform highp mat4 u_MVPMatrix;  // A constant representing the combined model/view/projection matrix.
	uniform highp mat4 u_MVMatrix;   // A constant representing the combined model/view matrix.
	uniform mediump mat3 u_NormalMatrix;
	uniform highp vec3 u_LightPos;   // The position of the light in eye space.
	uniform lowp float u_Ambient;

	attribute highp vec4 a_Position; // Per-vertex position information we will pass in.
	attribute mediump vec3 a_Normal;   // Per-vertex normal information we will pass in.
	attribute mediump vec2 a_TexCoord; // Per-vertex texture coord we will pass in.

	void main()
	{
		// Transform the vertex into eye space.
		highp vec3 position = vec3(u_MVMatrix * a_Position);

		// Transform the normal's orientation into eye space.
		mediump vec3 normal = normalize(u_NormalMatrix * a_Normal);

		// Get a lighting direction vector from the light to the vertex.
		mediump vec3 light_dir = normalize(u_LightPos - position);

		// Calculate the dot product of the light vector and vertex normal. If the normal and light vector are
		// pointing in the same direction then it will get max illumination.
		lowp float diffuse = max(u_Ambient, dot(normal, light_dir));

		// Multiply the color by the illumination level. It will be interpolated across the triangle.
		v_LightColor = vec3(diffuse);

		v_TexCoord = a_TexCoord;
		gl_Position = u_MVPMatrix * a_Position;
	}
#endif

#if defined(INCLUDE_FS)
	varying lowp vec3 v_LightColor;
	varying mediump vec2 v_TexCoord;
	uniform lowp sampler2D u_AlbedoTex;
	uniform lowp vec4 u_TintColor;

	void main()
	{
		gl_FragColor = vec4(v_LightColor, 1.0f) * texture2D(u_AlbedoTex, v_TexCoord);

		/* tint with alpha pre multiply */
		gl_FragColor.rgb *= u_TintColor.rgb;
		gl_FragColor *= u_TintColor.a;
	}
#endif

