#ifdef GL_ES
varying lowp vec4 v_color;
#else
varying vec4 v_color;
#endif

void main(void) {
#ifdef USE_COLOR
	v_color = a_color * u_color;
#else
	v_color = u_color;
#endif
	gl_Position = u_modelViewProjectionMatrix * a_position;
//	gl_Position.xy += a_userData;
}
