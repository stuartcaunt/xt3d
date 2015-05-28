varying vec4 v_color;
varying vec2 v_uv;

void main() {

	vec4 color = v_color;

#ifdef USE_TEXTURE
	color *= texture2D(u_texture, v_uv);
	//color.a += 0.3;

#endif

	gl_FragColor = color;
	gl_FragColor.a *= u_opacity;
}


