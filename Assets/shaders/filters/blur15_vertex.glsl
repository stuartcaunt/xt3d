varying vec2 v_uv;
varying vec2 v_uvBlur[14];

void main() {

	// Set uv
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;


#ifdef BLUR_X
	// Spread: equals the pixel spacing for the sampling
	float pixelSpacing = u_spread / u_textureWidth;

	v_uvBlur[ 0] = v_uv + vec2(-7.0 * pixelSpacing, 0.0);
	v_uvBlur[ 1] = v_uv + vec2(-6.0 * pixelSpacing, 0.0);
	v_uvBlur[ 2] = v_uv + vec2(-5.0 * pixelSpacing, 0.0);
	v_uvBlur[ 3] = v_uv + vec2(-4.0 * pixelSpacing, 0.0);
	v_uvBlur[ 4] = v_uv + vec2(-3.0 * pixelSpacing, 0.0);
	v_uvBlur[ 5] = v_uv + vec2(-2.0 * pixelSpacing, 0.0);
	v_uvBlur[ 6] = v_uv + vec2(-1.0 * pixelSpacing, 0.0);
	v_uvBlur[ 7] = v_uv + vec2( 1.0 * pixelSpacing, 0.0);
	v_uvBlur[ 8] = v_uv + vec2( 2.0 * pixelSpacing, 0.0);
	v_uvBlur[ 9] = v_uv + vec2( 3.0 * pixelSpacing, 0.0);
	v_uvBlur[10] = v_uv + vec2( 4.0 * pixelSpacing, 0.0);
	v_uvBlur[11] = v_uv + vec2( 5.0 * pixelSpacing, 0.0);
	v_uvBlur[12] = v_uv + vec2( 6.0 * pixelSpacing, 0.0);
	v_uvBlur[13] = v_uv + vec2( 7.0 * pixelSpacing, 0.0);
#endif

#ifdef BLUR_Y
	// Spread: equals the pixel spacing for the sampling
	float pixelSpacing = u_spread / u_textureHeight;

	v_uvBlur[ 0] = v_uv + vec2(0.0, -7.0 * pixelSpacing);
	v_uvBlur[ 1] = v_uv + vec2(0.0, -6.0 * pixelSpacing);
	v_uvBlur[ 2] = v_uv + vec2(0.0, -5.0 * pixelSpacing);
	v_uvBlur[ 3] = v_uv + vec2(0.0, -4.0 * pixelSpacing);
	v_uvBlur[ 4] = v_uv + vec2(0.0, -3.0 * pixelSpacing);
	v_uvBlur[ 5] = v_uv + vec2(0.0, -2.0 * pixelSpacing);
	v_uvBlur[ 6] = v_uv + vec2(0.0, -1.0 * pixelSpacing);
	v_uvBlur[ 7] = v_uv + vec2(0.0,  1.0 * pixelSpacing);
	v_uvBlur[ 8] = v_uv + vec2(0.0,  2.0 * pixelSpacing);
	v_uvBlur[ 9] = v_uv + vec2(0.0,  3.0 * pixelSpacing);
	v_uvBlur[10] = v_uv + vec2(0.0,  4.0 * pixelSpacing);
	v_uvBlur[11] = v_uv + vec2(0.0,  5.0 * pixelSpacing);
	v_uvBlur[12] = v_uv + vec2(0.0,  6.0 * pixelSpacing);
	v_uvBlur[13] = v_uv + vec2(0.0,  7.0 * pixelSpacing);
#endif

	gl_Position = u_modelViewProjectionMatrix * a_position;
}
