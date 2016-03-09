// http://devlog-martinsh.blogspot.fr/2011/11/glsl-depth-of-field-with-bokeh-v21.html
// https://dl.dropboxusercontent.com/u/11542084/DoF_bokeh_2.1

varying vec2 v_uv;

#define PI  3.1415926
#define MAX_RING_SAMPLES 18

const int samples = 3; //samples on the first ring
const int rings = 5; //ring count
float maxblur = 1.25; //clamp value of max blur

bool noise = true; //use noise instead of pattern for sample dithering

vec4 color(vec2 coords,float blur)  {
	vec4 col = vec4(0.0);

	vec2 texel = vec2(1.0 / u_textureWidth, 1.0 / u_textureHeight);

	col.r = texture2D(u_texture, coords + vec2( 0.0,   1.0) * texel * u_chromaticFringe * blur).r;
	col.g = texture2D(u_texture, coords + vec2(-0.866,-0.5) * texel * u_chromaticFringe * blur).g;
	col.b = texture2D(u_texture, coords + vec2( 0.866,-0.5) * texel * u_chromaticFringe * blur).b;
	col.a = texture2D(u_texture, coords).a;

	vec4 lumcoeff = vec4(0.299, 0.587, 0.114, 0.0);
	float lum = dot(col, lumcoeff);
	float thresh = max((lum - u_highlightThreshold) * u_highlightGain, 0.0);

	return col + mix(vec4(0.0), col, thresh * blur);

//	return texture2D(u_texture, coords);
}

//generating noise/pattern texture for dithering
vec2 rand(in vec2 coord)  {
	float noiseX = ((fract(1.0 - coord.s * (u_textureWidth / 2.0)) * 0.25) + (fract(coord.t * (u_textureHeight / 2.0)) * 0.75)) * 2.0 - 1.0;
	float noiseY = ((fract(1.0 - coord.s * (u_textureWidth / 2.0)) * 0.75) + (fract(coord.t * (u_textureHeight / 2.0)) * 0.25)) * 2.0 - 1.0;

	if (noise) {
		noiseX = clamp(fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453), 0.0, 1.0) * 2.0 - 1.0;
		noiseY = clamp(fract(sin(dot(coord, vec2(12.9898, 78.233) * 2.0)) * 43758.5453), 0.0, 1.0) * 2.0 - 1.0;
	}

	return vec2(noiseX, noiseY);
}

void main() {

	float depth = vec4ToFloat(texture2D(u_depthTexture, v_uv));
	float blur = 0.0;

	blur = clamp((abs(depth - u_focalDepth) / u_focalRange), -maxblur, maxblur);

	// Damp blurring on back plane: could be optional, or we could try blurring the depth texture too
//	if (depth == 0.0) {
//		blur = 0.2 * maxblur;
//	}

	vec2 noise = rand(v_uv) * u_dither * blur;

	vec2 texel = vec2(1.0 / u_textureWidth, 1.0 / u_textureHeight);
	float w = texel.x * blur + noise.x;
	float h = texel.y * blur + noise.y;

	vec4 col = texture2D(u_texture, v_uv);
	float s = 1.0;

	int ringsamples;
	float mixFactor;
	float step;
	float pw, ph;
	int i, j;

	for (i = 1; i <= 5; i++) {
		ringsamples = i * samples;
		mixFactor = mix(1.0, (float(i)) / (float(rings)), u_edgeBias);

		for (j = 0 ; j < MAX_RING_SAMPLES ; j++) {
			if (j >= ringsamples) {
				break;
			}

			step = PI * 2.0 / float(ringsamples);
			pw = (cos(float(j) * step) * float(i));
			ph = (sin(float(j) * step) * float(i));

			col += color(v_uv + vec2(pw * w, ph * h), blur) * mixFactor;
			s += mixFactor;
		}
	}

	col /= s;

	gl_FragColor = col;
}

