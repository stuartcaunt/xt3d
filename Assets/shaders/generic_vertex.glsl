//#ifdef GL_ES
//varying lowp vec4 v_color;
//#else
varying vec4 v_color;
//#endif

#ifdef USE_TEXTURE
varying vec2 v_uv;
#endif /* USE_TEXTURE */

void main(void) {

#ifdef USE_VERTEX_COLOR
	v_color = a_color * u_color;
#else
	v_color = u_color;
#endif /* USE_VERTEX_COLOR */

#ifdef USE_TEXTURE
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;
#endif /* USE_TEXTURE */

//	vec4 mvPosition = u_modelViewMatrix * a_position;
//	gl_Position = u_projectionMatrix * mvPosition;

	gl_Position = u_modelViewProjectionMatrix * a_position;
//	gl_Position.xy += a_userData;
}
