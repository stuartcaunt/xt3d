varying vec4 v_color;
varying vec2 v_uv;

#ifdef GOURAUD_LIGHTING
varying vec4 v_specular;
#endif


void main() {

	vec4 color = v_color;
	vec4 specular = vec4(0.0);

#ifdef USE_TEXTURE
	color *= texture2D(u_texture, v_uv);
#endif /* USE_TEXTURE */

#ifdef PHONG_LIGHTING
	doPhongLighting(color, specular);
#endif /* PHONG_LIGHTING */

#ifdef GOURAUD_LIGHTING
	specular = v_specular;
#endif /* GOURAUD_LIGHTING */

#ifdef ALPHA_CULLING
	if (color.a <= u_alphaCullingValue) {
		discard;
	}
#endif /* ALPHA_CULLING */

	color = vec4(color.rgb + specular.rgb * specular.a, color.a);
	color = clamp(color, 0.0, 1.0);

	gl_FragColor = color;
	gl_FragColor.a *= u_opacity;
}


