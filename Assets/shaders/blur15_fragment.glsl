varying vec2 v_uv;
varying vec2 v_uvBlur[14];

void main() {
//	gl_FragColor = texture2D(u_texture, v_uv;


	gl_FragColor = vec4(0.0);
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 0]) * 0.0044299121055113265;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 1]) * 0.00895781211794;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 2]) * 0.0215963866053;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 3]) * 0.0443683338718;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 4]) * 0.0776744219933;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 5]) * 0.115876621105;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 6]) * 0.147308056121;
	gl_FragColor += texture2D(u_texture, v_uv		 ) * 0.159576912161;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 7]) * 0.147308056121;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 8]) * 0.115876621105;
	gl_FragColor += texture2D(u_texture, v_uvBlur[ 9]) * 0.0776744219933;
	gl_FragColor += texture2D(u_texture, v_uvBlur[10]) * 0.0443683338718;
	gl_FragColor += texture2D(u_texture, v_uvBlur[11]) * 0.0215963866053;
	gl_FragColor += texture2D(u_texture, v_uvBlur[12]) * 0.00895781211794;
	gl_FragColor += texture2D(u_texture, v_uvBlur[13]) * 0.0044299121055113265;

}

