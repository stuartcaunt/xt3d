varying vec2 v_uv;
varying vec2 v_uvBlur[14];

float maxblur = 2.0; //clamp value of max blur

void main() {
	float depth = vec4ToFloat(texture2D(u_depthTexture, v_uv));

	float blur = clamp((abs(depth - u_focalDepth) / u_focalRange), 0.0, maxblur);

	// Damp blurring on back plane: could be optional, or we could try blurring the depth texture too
	if (depth == 0.0) {
		blur = 0.2 * maxblur;
	}

	gl_FragColor = vec4(0.0);
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 0] * blur) * 0.0044299121055113265;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 1] * blur) * 0.00895781211794;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 2] * blur) * 0.0215963866053;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 3] * blur) * 0.0443683338718;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 4] * blur) * 0.0776744219933;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 5] * blur) * 0.115876621105;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 6] * blur) * 0.147308056121;
	gl_FragColor += texture2D(u_texture, v_uv		               ) * 0.159576912161;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 7] * blur) * 0.147308056121;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 8] * blur) * 0.115876621105;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[ 9] * blur) * 0.0776744219933;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[10] * blur) * 0.0443683338718;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[11] * blur) * 0.0215963866053;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[12] * blur) * 0.00895781211794;
	gl_FragColor += texture2D(u_texture, v_uv + v_uvBlur[13] * blur) * 0.0044299121055113265;
}

