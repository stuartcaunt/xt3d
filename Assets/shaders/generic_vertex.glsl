
#if (defined (GOURAUD_LIGHTING) && defined (MAX_LIGHTS))

varying vec3 v_specular;

vec3 ecPosition3;
vec3 normal;
vec3 eye;


void pointLight(const in Light light,
				inout vec3 ambient,
				inout vec3 diffuse,
				inout vec3 specular,
				const in float shininess) {

	float nDotVP;
	float eDotRV;
	float pf;
	float attenuation;
	float d;
	vec3 VP;
	vec3 reflectVector;

	// Check if light source is directional
	if (light.position.w != 0.0) {
		// Vector between light position and vertex
		VP = vec3(light.position.xyz - ecPosition3);

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

	// angle between normal and light-vertex vector
	nDotVP = max(0.0, dot(VP, normal));

 	ambient += light.ambientColor * attenuation;
	if (nDotVP > 0.0) {
		diffuse += light.diffuseColor * (nDotVP * attenuation);

		// reflected vector
		reflectVector = normalize(reflect(-VP, normal));

		// angle between eye and reflected vector
		eDotRV = max(0.0, dot(eye, reflectVector));
		eDotRV = pow(eDotRV, 16.0);

		pf = pow(eDotRV, shininess);
		specular += light.specularColor * (pf * attenuation);
	}
}

void doGouraudLighting(const in vec4 vertexPosition,
						const in vec3 vertexNormal,
						out vec3 ambient,
						out vec3 diffuse,
						out vec3 specular,
						const in float shininess) {
	vec3 amb = vec3(0.0);
	vec3 diff = vec3(0.0);
	vec3 spec = vec3(0.0);

	if (u_lightingEnabled) {

		ecPosition3 = vec3(u_modelViewMatrix * vertexPosition);

		eye = -normalize(ecPosition3);

		normal = u_normalMatrix * vertexNormal;
		normal = normalize(normal);

		for (int i = 0; i < MAX_LIGHTS; i++) {
			if (u_lights[i].enabled) {
				pointLight(u_lights[i], amb, diff, spec, shininess);
			}
		}

		ambient = u_sceneAmbientColor + amb,
		diffuse = diff;
		specular = spec;

	} else {
		ambient = amb;
		diffuse = vec3(1.0);
		specular = spec;
	}
}

#endif // GOURAUD_LIGHTING

#ifdef USE_TEXTURE
varying vec2 v_uv;
#endif /* USE_TEXTURE */


varying vec4 v_color;

void main(void) {

	vec4 position = a_position;

#ifdef GOURAUD_LIGHTING
	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
#ifdef USE_MATERIAL_COLOR
	float shininess = u_material.shininess;
#else
	float shininess = u_defaultShininess;
#endif

	doGouraudLighting(position, a_normal, ambient, diffuse, specular, shininess);

#ifdef USE_MATERIAL_COLOR
	v_color.rgb = ambient * u_material.ambient + diffuse * u_material.diffuse;
	v_color.a = u_material.diffuse.a;
	v_specular = specular * u_material.specular;

#elseif USE_VERTEX_COLOR
	v_color.rgb = (ambient + diffuse) * a_color.rgb * u_color.rgb;
	v_color.a = a_color.a * u_color.a;
	v_specular = specular;

#else
	v_color.rgb = (ambient + diffuse) * u_color.rgb;
	v_color.a = u_color.a;
	v_specular = specular;

#endif /* USE_MATERIAL_COLOR */

	v_color = clamp(v_color, 0.0, 1.0);

#else /* GOURAUD_LIGHTING */

#ifdef USE_VERTEX_COLOR
	v_color = a_color * u_color;
#else
	v_color = u_color;
#endif /* USE_VERTEX_COLOR */

#endif /* GOURAUD_LIGHTING */


#ifdef USE_TEXTURE
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;
#endif /* USE_TEXTURE */

//	vec4 mvPosition = u_modelViewMatrix * a_position;
//	gl_Position = u_projectionMatrix * mvPosition;

	gl_Position = u_modelViewProjectionMatrix * a_position;
//	gl_Position.xy += a_userData;
}
