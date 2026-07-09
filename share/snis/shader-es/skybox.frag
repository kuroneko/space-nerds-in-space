
uniform lowp samplerCube s_texture;

varying mediump vec3 texCoord;

void main (void) {
	gl_FragColor = filmic_tonemap(textureCube(s_texture, texCoord));
}

