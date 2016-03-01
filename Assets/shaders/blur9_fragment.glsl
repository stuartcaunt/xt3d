varying vec2 v_uv;
varying vec2 v_uvBlur[8];

void main() {
//	gl_FragColor = texture2D(u_texture, v_uv;


	gl_FragColor = vec4(0.0);
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 0]) * 0.0162162162;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 1]) * 0.0540540541;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 2]) * 0.1216216216;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 3]) * 0.1945945946;
	gl_FragColor += texture2D(u_texture, v_uv		 ) * 0.2270270270;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 4]) * 0.1945945946;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 5]) * 0.1216216216;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 6]) * 0.0540540541;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 7]) * 0.0162162162;

}

