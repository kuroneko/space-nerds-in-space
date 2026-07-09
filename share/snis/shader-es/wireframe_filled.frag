/*
 * Copyright © 2010-2011 Alexandros Frantzis
 *
 * This file is part of the glmark2 OpenGL (ES) 2.0 benchmark.
 *
 * glmark2 is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * glmark2 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * glmark2.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *  Alexandros Frantzis (glmark2)
 */

#ifdef GL_NV_shader_noperspective_interpolation
#extenstion GL_NV_shader_noperspective_interpolation : enable
  noperspective varying mediump vec4 dist;
#else
varying mediump vec4 dist;
#endif

uniform lowp vec3 line_color;
uniform lowp vec3 triangle_color;

void main(void)
{
	// Get the minimum distance of this fragment from a triangle edge.
#ifdef GL_NV_shader_noperspective_interpolation
	mediump float d = min(dist.x, min(dist.y, dist.z));

#else
	// We need to multiply with dist.w to undo the workaround we had
	// to perform to get linear interpolation (instead of perspective correct).
	mediump float d = min(dist.x * dist.w, min(dist.y * dist.w, dist.z * dist.w));
#endif

	// Get the intensity of the wireframe line
	lowp float i = exp2(-2.0 * d * d);

	gl_FragColor = vec4(mix(triangle_color, line_color, i), 1.0);
}

