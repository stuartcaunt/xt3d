#ifdef FACE_PICKING
varying vec2 v_faceId;
#endif

void main() {

	vec4 color;
#ifdef FACE_PICKING
	color.zw = v_faceId;
#else
	color.zw = vec2(0.0);
#endif
	color.xy = u_objectId;

	gl_FragColor = color;
}


