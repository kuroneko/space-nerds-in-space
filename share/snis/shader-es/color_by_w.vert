
uniform highp mat4 u_MVPMatrix;  // A constant representing the combined model/view/projection matrix.

// color bands by w
uniform lowp vec3 u_NearColor;
uniform highp float u_NearW;
uniform lowp vec3 u_CenterColor;
uniform highp float u_CenterW;
uniform lowp vec3 u_FarColor;
uniform highp float u_FarW;

attribute vec4 a_Position; // Per-vertex position information we will pass in.

varying vec3 v_Color;

void main()
{
	gl_Position = u_MVPMatrix * a_Position;

	if (gl_Position.w < u_CenterW) {
		lowp float t = (clamp(gl_Position.w, u_NearW, u_CenterW) - u_NearW) / (u_CenterW - u_NearW);
		v_Color = mix(u_NearColor, u_CenterColor, t);
	} else {
		lowp float t = (clamp(gl_Position.w, u_CenterW, u_FarW) - u_CenterW) / (u_FarW - u_CenterW);
		v_Color = mix(u_CenterColor, u_FarColor, t);
	}
}

