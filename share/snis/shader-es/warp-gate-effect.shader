

#if defined(INCLUDE_VS)
	varying lowp vec4 v_TintColor;
	varying mediump vec2 v_TexCoord;      // This will be passed into the fragment shader.

	uniform highp mat4 u_MVPMatrix;  // A constant representing the combined model/view/projection matrix.
	uniform lowp vec4 u_TintColor;

	attribute highp vec3 a_Position; // Per-vertex position information we will pass in.
	attribute mediump vec2 a_TexCoord; // Per-vertex texture coord we will pass in.
	uniform mediump vec2 u_u1v1;

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
	uniform mediump vec2 u_u1v1;
	
	mediump float map(in mediump float x, mediump float min1, mediump float max1, mediump float min2, mediump float max2)
	{
		return min2 + (x - min1) * (max2 - min2) / (max1 - min1);
	}

	void main()
	{
		mediump vec2 texcoord = vec2(map(v_TexCoord.x, 0.0, 1.0, u_u1v1.x, u_u1v1.y), v_TexCoord.y);
		gl_FragColor = texture2D(u_AlbedoTex, texcoord);
		/* tint with alpha pre multiply */
		gl_FragColor.rgb *= v_TintColor.rgb;
		gl_FragColor *= v_TintColor.a;
		gl_FragColor = filmic_tonemap(gl_FragColor);
		gl_FragColor *= 0.25f * (1.0f + sin(10.0f * 3.1415927f * (abs(u_u1v1.x - 0.5f) + 0.5f) * v_TexCoord.x)) +
				0.25f * (1.0f + cos(5.0f * u_u1v1.y * 0.1f * v_TexCoord.y));
	}
#endif

