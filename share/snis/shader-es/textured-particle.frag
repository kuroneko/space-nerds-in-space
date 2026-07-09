
uniform lowp sampler2D u_AlbedoTex;

varying mediump vec2 v_TexCoord;
varying lowp vec4 v_TintColor;

void main()
{
	gl_FragColor = filmic_tonemap(v_TintColor * texture2D(u_AlbedoTex, v_TexCoord));
}

