#ifdef FACE_PICKING
varying vec2 v_faceId;
#endif

void main(void) {

	// Set position (use bones if necessary)
	vec4 position = a_position;

#ifdef FACE_PICKING
	v_faceId = a_faceId;
#endif

	gl_Position = u_modelViewProjectionMatrix * position;
}
