varying vec2 v_uv;

void main() {
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;

	gl_Position = u_modelViewProjectionMatrix * a_position;
}
