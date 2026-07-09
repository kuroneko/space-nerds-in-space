
uniform lowp float u_Invert;

#if defined(INCLUDE_VS)
	varying lowp vec4 v_TintColor;
	varying lowp float v_EyeDot;
	#if defined(TEXTURED_ALPHA_BY_NORMAL)
	varying mediump vec2 v_TexCoord;      // This will be passed into the fragment shader.
	#endif

	uniform highp mat4 u_MVPMatrix;  // A constant representing the combined model/view/projection matrix.
	uniform highp mat4 u_MVMatrix;
	uniform lowp vec4 u_TintColor;
	uniform mediump mat3 u_NormalMatrix;

	attribute highp vec4 a_Position; // Per-vertex position information we will pass in.
	attribute mediump vec3 a_Normal;
#if defined(TEXTURED_ALPHA_BY_NORMAL)
	attribute mediump vec2 a_TexCoord; // Per-vertex texture coord we will pass in.
#endif
	void main()
	{
		// Transform the vertex into eye space.
		highp vec3 modelViewVertex = vec3(u_MVMatrix * a_Position);

		// Transform the normal's orientation into eye space.
		highp vec3 modelViewNormal = normalize(u_NormalMatrix * a_Normal);

		highp vec3 eyeVector = normalize(-modelViewVertex);
		v_EyeDot = dot(modelViewNormal, eyeVector);

		v_TintColor = u_TintColor;
#if defined(TEXTURED_ALPHA_BY_NORMAL)
		v_TexCoord = a_TexCoord;
#endif
		gl_Position = u_MVPMatrix * a_Position;
	}
#endif

#if defined(INCLUDE_FS)
	varying lowp vec4 v_TintColor;
	varying lowp float v_EyeDot;
	#if defined(TEXTURED_ALPHA_BY_NORMAL)
	varying mediump vec2 v_TexCoord;      // This will be passed into the fragment shader.
	#endif

#if defined(TEXTURED_ALPHA_BY_NORMAL)
	uniform lowp sampler2D u_AlbedoTex;
#endif

	

	void main()
	{
#if defined(TEXTURED_ALPHA_BY_NORMAL)
		gl_FragColor = texture2D(u_AlbedoTex, v_TexCoord);
#else
		gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
#endif
		gl_FragColor.rgb = vec3(1.0, 1.0, 1.0);
		gl_FragColor.rgb *= v_TintColor.rgb; /* tint with alpha pre multiply */
		/* This max/min gets rid of back faces (maps negatives to 0.0)) */
		lowp float factor = max(min(sign(v_EyeDot), v_EyeDot * v_EyeDot * v_EyeDot), 0.0);
		lowp float alpha = v_TintColor.a * (factor * u_Invert +
			(1.0 - u_Invert) * (1.0 - factor));
		gl_FragColor *= alpha;
		// gl_FragColor *= v_TintColor.a * (v_EyeDot * (1.0 - u_Invert) + u_Invert * (1.0 - v_EyeDot));
		// gl_FragColor *= v_TintColor.a * max((1.0 - abs(v_EyeDot)), 0.2);
	}
#endif

