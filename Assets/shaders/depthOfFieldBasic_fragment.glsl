varying vec2 v_uv;

float range = 0.2; //focal range

void main() {

	float depth = vec4ToFloat(texture2D(u_depthTexture, v_uv));

	float blur = clamp((abs(depth - u_focalDepth) / range), 0.0, 1.0);

	vec4 focused = texture2D(u_texture, v_uv);
	vec4 blurred = texture2D(u_blurredTexture, v_uv);

	gl_FragColor.rgb = focused.rgb + blur * (blurred.rgb - focused.rgb);
	gl_FragColor.a = focused.a;

//	gl_FragColor = texture2D(u_blurredTexture, v_uv);
}

