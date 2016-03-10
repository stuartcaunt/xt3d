varying vec2 v_uv;
varying vec2 v_uvBlur[14];

void main() {
	// Set uv
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;

#ifdef DoF_X
	float pixelSpacing = 1.0 / u_textureWidth;

	v_uvBlur[ 0] = vec2(-7.0 * pixelSpacing, 0.0);
	v_uvBlur[ 1] = vec2(-6.0 * pixelSpacing, 0.0);
	v_uvBlur[ 2] = vec2(-5.0 * pixelSpacing, 0.0);
	v_uvBlur[ 3] = vec2(-4.0 * pixelSpacing, 0.0);
	v_uvBlur[ 4] = vec2(-3.0 * pixelSpacing, 0.0);
	v_uvBlur[ 5] = vec2(-2.0 * pixelSpacing, 0.0);
	v_uvBlur[ 6] = vec2(-1.0 * pixelSpacing, 0.0);
	v_uvBlur[ 7] = vec2( 1.0 * pixelSpacing, 0.0);
	v_uvBlur[ 8] = vec2( 2.0 * pixelSpacing, 0.0);
	v_uvBlur[ 9] = vec2( 3.0 * pixelSpacing, 0.0);
	v_uvBlur[10] = vec2( 4.0 * pixelSpacing, 0.0);
	v_uvBlur[11] = vec2( 5.0 * pixelSpacing, 0.0);
	v_uvBlur[12] = vec2( 6.0 * pixelSpacing, 0.0);
	v_uvBlur[13] = vec2( 7.0 * pixelSpacing, 0.0);
#endif

#ifdef DoF_Y
	float pixelSpacing = 1.0 / u_textureHeight;

	v_uvBlur[ 0] = vec2(0.0, -7.0 * pixelSpacing);
	v_uvBlur[ 1] = vec2(0.0, -6.0 * pixelSpacing);
	v_uvBlur[ 2] = vec2(0.0, -5.0 * pixelSpacing);
	v_uvBlur[ 3] = vec2(0.0, -4.0 * pixelSpacing);
	v_uvBlur[ 4] = vec2(0.0, -3.0 * pixelSpacing);
	v_uvBlur[ 5] = vec2(0.0, -2.0 * pixelSpacing);
	v_uvBlur[ 6] = vec2(0.0, -1.0 * pixelSpacing);
	v_uvBlur[ 7] = vec2(0.0,  1.0 * pixelSpacing);
	v_uvBlur[ 8] = vec2(0.0,  2.0 * pixelSpacing);
	v_uvBlur[ 9] = vec2(0.0,  3.0 * pixelSpacing);
	v_uvBlur[10] = vec2(0.0,  4.0 * pixelSpacing);
	v_uvBlur[11] = vec2(0.0,  5.0 * pixelSpacing);
	v_uvBlur[12] = vec2(0.0,  6.0 * pixelSpacing);
	v_uvBlur[13] = vec2(0.0,  7.0 * pixelSpacing);
#endif

	// Projected position
	gl_Position = u_modelViewProjectionMatrix * a_position;
}
