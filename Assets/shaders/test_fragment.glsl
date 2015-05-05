varying vec4 v_color;
varying vec2 v_uv;

uniform sampler2D u_texture;

void main() {

	vec4 color = v_color;

#ifdef USE_TEXTURE
	color *= texture2D(u_texture, v_uv);
#endif

	gl_FragColor = color;
}


