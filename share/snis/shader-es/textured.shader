

#if defined(INCLUDE_VS)
	varying lowp vec4 v_TintColor;
	varying mediump vec2 v_TexCoord;      // This will be passed into the fragment shader.

	uniform highp mat4 u_MVPMatrix;  // A constant representing the combined model/view/projection matrix.
	uniform lowp vec4 u_TintColor;

	attribute highp vec3 a_Position; // Per-vertex position information we will pass in.
	attribute mediump vec2 a_TexCoord; // Per-vertex texture coord we will pass in.

	void main()
	{
		v_TintColor = u_TintColor;
		v_TexCoord = a_TexCoord;
		gl_Position = u_MVPMatrix * vec4(a_Position, 1.0);
	}
#endif

#if defined(INCLUDE_FS)
	varying lowp vec4 v_TintColor;
	varying mediump vec2 v_TexCoord;      // This will be passed into the fragment shader.
	uniform lowp sampler2D u_AlbedoTex;

	void main()
	{
		gl_FragColor = texture2D(u_AlbedoTex, v_TexCoord);

		/* tint with alpha pre multiply */
		gl_FragColor.rgb *= v_TintColor.rgb;
		gl_FragColor *= v_TintColor.a;
		gl_FragColor = filmic_tonemap(gl_FragColor);
	}
#endif

