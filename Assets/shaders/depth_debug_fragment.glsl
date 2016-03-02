varying vec2 v_uv;

void main() {
	float depth = vec4ToFloat(texture2D(u_texture, v_uv));

	gl_FragColor = vec4(depth, depth, depth, 1.0);
}

