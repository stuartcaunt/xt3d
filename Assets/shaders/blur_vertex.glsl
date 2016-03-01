varying vec2 v_uv;
varying vec2 v_uvBlur[14];

void main() {

	// Set uv
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;

#ifdef BLUR_X
	v_uvBlur[ 0] = v_uv + vec2(-0.028, 0.0);
	v_uvBlur[ 1] = v_uv + vec2(-0.024, 0.0);
	v_uvBlur[ 2] = v_uv + vec2(-0.020, 0.0);
	v_uvBlur[ 3] = v_uv + vec2(-0.016, 0.0);
	v_uvBlur[ 4] = v_uv + vec2(-0.012, 0.0);
	v_uvBlur[ 5] = v_uv + vec2(-0.008, 0.0);
	v_uvBlur[ 6] = v_uv + vec2(-0.004, 0.0);
	v_uvBlur[ 7] = v_uv + vec2( 0.004, 0.0);
	v_uvBlur[ 8] = v_uv + vec2( 0.008, 0.0);
	v_uvBlur[ 9] = v_uv + vec2( 0.012, 0.0);
	v_uvBlur[10] = v_uv + vec2( 0.016, 0.0);
	v_uvBlur[11] = v_uv + vec2( 0.020, 0.0);
	v_uvBlur[12] = v_uv + vec2( 0.024, 0.0);
	v_uvBlur[13] = v_uv + vec2( 0.028, 0.0);
#endif

#ifdef BLUR_Y
	v_uvBlur[ 0] = v_uv + vec2(0.0, -0.028);
	v_uvBlur[ 1] = v_uv + vec2(0.0, -0.024);
	v_uvBlur[ 2] = v_uv + vec2(0.0, -0.020);
	v_uvBlur[ 3] = v_uv + vec2(0.0, -0.016);
	v_uvBlur[ 4] = v_uv + vec2(0.0, -0.012);
	v_uvBlur[ 5] = v_uv + vec2(0.0, -0.008);
	v_uvBlur[ 6] = v_uv + vec2(0.0, -0.004);
	v_uvBlur[ 7] = v_uv + vec2(0.0,  0.004);
	v_uvBlur[ 8] = v_uv + vec2(0.0,  0.008);
	v_uvBlur[ 9] = v_uv + vec2(0.0,  0.012);
	v_uvBlur[10] = v_uv + vec2(0.0,  0.016);
	v_uvBlur[11] = v_uv + vec2(0.0,  0.020);
	v_uvBlur[12] = v_uv + vec2(0.0,  0.024);
	v_uvBlur[13] = v_uv + vec2(0.0,  0.028);
#endif

	gl_Position = u_modelViewProjectionMatrix * a_position;
}
