// prefix vertex :

#if (defined (GOURAUD_LIGHTING) && defined (MAX_LIGHTS))

struct Light {
	vec4 position;
	vec4 ambientColor;
	vec4 diffuseColor;
	vec4 specularColor;
	vec3 attenuation;
	float spotCutoffAngle;
	vec3 spotDirection;
	float spotFalloffExponent;
};

#endif // GOURAUD_LIGHTING


attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec4 a_color;
attribute vec2 a_uv;

