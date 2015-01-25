#ifdef GL_ES
varying lowp vec4 v_color;
#else
varying vec4 v_color;
#endif

void main(void) {
	v_color = a_color;
	gl_Position = u_MVPMatrix * a_position;
}
