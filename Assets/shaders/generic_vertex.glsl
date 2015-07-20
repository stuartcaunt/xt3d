
varying vec4 v_color;

#ifdef USE_TEXTURE
varying vec2 v_uv;
#endif /* USE_TEXTURE */

#if (defined (GOURAUD_LIGHTING) && defined (MAX_LIGHTS))

varying vec3 v_specular;

vec3 ecPosition3;
vec3 normal;
vec3 eye;


void gouraudLight(const in Light light,
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

vec4 doGouraudLighting(const in vec4 vertexPosition,
						const in vec3 vertexNormal) {


	vec3 amb = vec3(0.0);
	vec3 diff = vec3(0.0);
	vec3 spec = vec3(0.0);

	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
	float alpha = 1.0;

	if (u_lightingEnabled) {

#ifdef USE_MATERIAL_COLOR
		float shininess = u_material.shininess;
#else
		float shininess = u_defaultShininess;
#endif

		ecPosition3 = vec3(u_modelViewMatrix * vertexPosition);

		eye = -normalize(ecPosition3);

		normal = u_normalMatrix * vertexNormal;
		normal = normalize(normal);

		for (int i = 0; i < MAX_LIGHTS; i++) {
			if (u_lights[i].enabled) {
				gouraudLight(u_lights[i], amb, diff, spec, shininess);
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


#ifdef USE_MATERIAL_COLOR
	ambient *= u_material.ambientColor;
	diffuse *= u_material.diffuseColor.rgb;
	specular *= u_material.specularColor;
	alpha *= u_material.diffuseColor.a;
#endif /* USE_MATERIAL_COLOR */

	// Set specular for fragement shader
	v_specular = specular;

	// Create combined color
	vec4 color = vec4(ambient + diffuse, alpha);
	color = clamp(color, 0.0, 1.0);

	return color;
}

#endif // GOURAUD_LIGHTING


#if (defined (PHONG_LIGHTING) && defined (MAX_LIGHTS))

varying vec3 v_ecPosition3;
varying vec3 v_normal;
varying vec3 v_eye;

void doPhongLightingPrepare(const in vec4 vertexPosition,
						const in vec3 vertexNormal) {

	v_ecPosition3 = vec3(u_modelViewMatrix * vertexPosition);
	v_eye = -normalize(v_ecPosition3);
	v_normal = normalize(u_normalMatrix * vertexNormal);
}

#endif // PHONG_LIGHTING


void main(void) {

	// Set position (use bones if necessary)
	vec4 position = a_position;

#ifdef USE_TEXTURE
	// Set uv
	v_uv = a_uv * u_uvScaleOffset.xy + u_uvScaleOffset.zw;
#endif /* USE_TEXTURE */

	// Initialise color from uniform color
	vec4 color = u_color;

#ifdef GOURAUD_LIGHTING
	// Do gouraud vertex lighting
	color *= doGouraudLighting(position, a_normal);
#endif /* GOURAUD_LIGHTING */

#ifdef USE_VERTEX_COLOR
	// Apply vertex color
	color *= a_color;
#endif /* USE_VERTEX_COLOR */

	// Set varying color for fragment shader
	v_color = color;

#ifdef PHONG_LIGHTING
	doPhongLightingPrepare(position, a_normal);
#endif

//	vec4 mvPosition = u_modelViewMatrix * a_position;
//	gl_Position = u_projectionMatrix * mvPosition;

	gl_Position = u_modelViewProjectionMatrix * a_position;
//	gl_Position.xy += a_userData;
}
