varying vec2 v_uv;

void main() {
	// Set uv
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;

	// Projected position
	gl_Position = u_modelViewProjectionMatrix * a_position;
}
