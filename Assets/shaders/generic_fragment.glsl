varying vec4 v_color;
varying vec2 v_uv;

#ifdef GOURAUD_LIGHTING
varying vec3 v_specular;
#endif
void main() {

	vec4 color = v_color;

#ifdef USE_TEXTURE
	color *= texture2D(u_texture, v_uv);
#endif

#ifdef GOURAUD_LIGHTING
	color = vec4(color.rgb + v_specular, color.a);
#endif

	gl_FragColor = color;
	gl_FragColor.a *= u_opacity;
}


