
float getDepth(sampler2D depthTex, vec2 coord) {
	float depth = vec4ToFloat(texture2D(depthTex, coord));

	float z = depth * 2.0 - 1.0;

	return (2.0 * u_depthNear * u_depthFar) / (u_depthFar + u_depthNear - z * (u_depthFar - u_depthNear));
}
