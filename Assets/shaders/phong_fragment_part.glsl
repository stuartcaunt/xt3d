
#if (defined (PHONG_LIGHTING) && defined (MAX_LIGHTS))

varying vec3 v_ecPosition3;
varying vec3 v_normal;
varying vec3 v_eye;

void phongLight(const in Light light,
				inout vec3 ambient,
				inout vec3 diffuse,
				inout vec3 specular,
				const in float shininess) {

	float nDotVP;
	float eDotRV;
	float pf;
	float d;
	vec3 VP;
	vec3 reflectVector;
	float attenuation;

	// Check if light source is directional
	if (light.position.w != 0.0) {
		// Vector between light position and vertex
		VP = vec3(light.position.xyz - v_ecPosition3);

		// Distance between the two
		d = length(VP);

		// Normalise
		VP = normalize(VP);

		// Calculate attenuation
		vec3 attDist = vec3(1.0, d, d * d);
		attenuation = 1.0 / dot(light.attenuation, attDist);

		// Calculate spot lighting effects
		if (light.spotCutoffAngle > 0.0) {
			float spotFactor = dot(-VP, light.spotDirection);
			float spotCutoff = cos(radians(light.spotCutoffAngle));
			if (spotFactor >= spotCutoff) {
				spotFactor = (1.0 - (1.0 - spotFactor) * 1.0/(1.0 - spotCutoff));
				spotFactor = pow(spotFactor, light.spotFalloffExponent);

			} else {
				spotFactor = 0.0;
			}
			attenuation *= spotFactor;
		}
	} else {
		attenuation = 1.0;
		VP = light.position.xyz;
	}


	// Check if light source is directional
	if (light.position.w != 0.0) {
		// Calculate spot lighting effects
		if (light.spotCutoffAngle > 0.0) {
			float spotFactor = dot(-VP, light.spotDirection);
			float spotCutoff = cos(radians(light.spotCutoffAngle));
			if (spotFactor >= spotCutoff) {
				spotFactor = (1.0 - (1.0 - spotFactor) * 1.0/(1.0 - spotCutoff));
				spotFactor = pow(spotFactor, light.spotFalloffExponent);

			} else {
				spotFactor = 0.0;
			}
			attenuation *= spotFactor;
		}
	}

	// angle between normal and light-vertex vector
	nDotVP = max(0.0, dot(VP, v_normal));

 	ambient += light.ambientColor * attenuation;
	if (nDotVP > 0.0) {
		diffuse += light.diffuseColor * (nDotVP * attenuation);

		// reflected vector
		reflectVector = normalize(reflect(-VP, v_normal));

		// angle between eye and reflected vector
		eDotRV = max(0.0, dot(v_eye, reflectVector));
		eDotRV = pow(eDotRV, 16.0);

		pf = pow(eDotRV, shininess);
		specular += light.specularColor * (pf * attenuation);
	}
}

void doPhongLighting(inout vec4 color, inout vec3 specular) {

	vec3 ambient;
	vec3 diffuse;
	float alpha = 1.0;

	vec3 amb = vec3(0.0);
	vec3 diff = vec3(0.0);
	vec3 spec = vec3(0.0);

#ifdef USE_MATERIAL_COLOR
	float shininess = u_material.shininess;
#else
	float shininess = u_defaultShininess;
#endif

	if (u_lightingEnabled) {

		for (int i = 0; i < MAX_LIGHTS; i++) {
			if (u_lights[i].enabled) {
				phongLight(u_lights[i], amb, diff, spec, shininess);
			}
		}

		ambient = u_sceneAmbientColor + amb,
		diffuse = diff;

	} else {
		ambient = amb;
		diffuse = vec3(1.0);
	}

#ifdef USE_MATERIAL_COLOR
	ambient *= u_material.ambientColor;
	diffuse *= u_material.diffuseColor.rgb;
	specular *= u_material.specularColor;
	alpha *= u_material.diffuseColor.a;
#endif /* USE_MATERIAL_COLOR */

	color *= vec4(ambient + diffuse, alpha);
	specular += spec;
}

#endif // PHONG_LIGHTING

