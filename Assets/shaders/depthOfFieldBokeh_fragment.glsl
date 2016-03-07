// http://devlog-martinsh.blogspot.fr/2011/11/glsl-depth-of-field-with-bokeh-v21.html
// https://dl.dropboxusercontent.com/u/11542084/DoF_bokeh_2.1

varying vec2 v_uv;

#define PI  3.1415926
#define MAX_RING_SAMPLES 18

const int samples = 3; //samples on the first ring
const int rings = 5; //ring count

float range = 0.2; //focal range
float maxblur = 1.25; //clamp value of max blur

float threshold = 0.5; //highlight threshold;
float gain = 10.0; //highlight gain;

float bias = 0.4; //bokeh edge bias
float fringe = 0.5; //bokeh chromatic aberration/fringing

bool noise = true; //use noise instead of pattern for sample dithering
float namount = 0.0001; //dither amount

//processing the sample
vec3 color(vec2 coords,float blur)  {
	vec3 col = vec3(0.0);

	vec2 texel = vec2(1.0 / u_textureWidth, 1.0 / u_textureHeight);

	col.r = texture2D(u_texture, coords + vec2(0.0,1.0) * texel * fringe * blur).r;
	col.g = texture2D(u_texture, coords + vec2(-0.866,-0.5) * texel * fringe * blur).g;
	col.b = texture2D(u_texture, coords + vec2(0.866,-0.5) * texel * fringe * blur).b;

	vec3 lumcoeff = vec3(0.299,0.587,0.114);
	float lum = dot(col.rgb, lumcoeff);
	float thresh = max((lum-threshold)*gain, 0.0);
	return col+mix(vec3(0.0),col,thresh*blur);


	return texture2D(u_texture, coords).rgb;
}

//generating noise/pattern texture for dithering
vec2 rand(in vec2 coord)  {
	float noiseX = ((fract(1.0 - coord.s * (u_textureWidth / 2.0)) * 0.25) + (fract(coord.t * (u_textureHeight / 2.0)) * 0.75)) * 2.0 - 1.0;
	float noiseY = ((fract(1.0 - coord.s * (u_textureWidth / 2.0)) * 0.75) + (fract(coord.t * (u_textureHeight / 2.0)) * 0.25)) * 2.0 - 1.0;

	if (noise) {
		noiseX = clamp(fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453), 0.0, 1.0) * 2.0 - 1.0;
		noiseY = clamp(fract(sin(dot(coord, vec2(12.9898, 78.233) * 2.0)) * 43758.5453), 0.0, 1.0) * 2.0 - 1.0;
	}

	return vec2(noiseX,noiseY);
}

void main() {

	float depth = vec4ToFloat(texture2D(u_depthTexture, v_uv));
	float blur = 0.0;

	blur = clamp((abs(depth - u_focalDepth) / range), -maxblur, maxblur);

	vec2 noise = rand(v_uv) * namount * blur;

	vec2 texel = vec2(1.0 / u_textureWidth, 1.0 / u_textureHeight);
	float w = texel.x * blur + noise.x;
	float h = texel.y * blur + noise.y;

	vec3 col = texture2D(u_texture, v_uv).rgb;
	float s = 1.0;

	int ringsamples;

	for (int i = 1; i <= 5; i++) {
		ringsamples = i * samples;

		for (int j = 0 ; j < MAX_RING_SAMPLES ; j++) {
			if (j >= ringsamples) {
				break;
			}

			float step = PI * 2.0 / float(ringsamples);
			float pw = (cos(float(j) * step) * float(i));
			float ph = (sin(float(j) * step) * float(i));
			float p = 1.0;

			col += color(v_uv + vec2(pw * w, ph * h), blur) * mix(1.0, (float(i)) / (float(rings)), bias) * p;
			s += 1.0 * mix(1.0, (float(i)) / (float(rings)), bias) * p;
		}
	}

	col /= s;

	gl_FragColor.rgb = col;
	gl_FragColor.a = 1.0;

	//gl_FragColor = texture2D(u_texture, v_uv);
}

