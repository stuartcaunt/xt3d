varying vec2 v_uv;

void main() {
	vec4 floatRGBA = texture2D(u_texture, v_uv);

	float depth = vec4ToFloat(floatRGBA);

	gl_FragColor = vec4(depth, depth, depth, 1.0);
}

