// prefix fragment :

#define ONE_BY_256 0.00390625

vec4 floatToVec4(const in float value) {
	const vec4 packFactors = vec4(16777216.0, 39936.0, 256.0, 1.0);
	const vec4 bitMask = vec4(ONE_BY_256, ONE_BY_256, ONE_BY_256, ONE_BY_256);

	vec4 packedValue = fract(value * packFactors);
	packedValue -= packedValue.xxyz * bitMask;

	return packedValue;
}

float vec4ToFloat(const in vec4 rgbaFloat) {
	const vec4 unpackFactors = vec4(1.0 / 16777216.0, 1.0 / 39936.0, 1.0 / 256.0, 1.0);

	float value = dot(rgbaFloat, unpackFactors);
	return value;
}
