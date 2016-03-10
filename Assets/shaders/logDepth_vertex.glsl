
void main() {
	gl_Position = u_modelViewProjectionMatrix * a_position;

	// Convert into a logarithmic depth with 0 at near plane, 1 at far plane
	// http://outerra.blogspot.fr/2012/11/maximizing-depth-buffer-range-and.html
	//gl_Position.z = 2.0 * log(gl_Position.w / u_near) / log(u_far / u_near) - 1.0;
	gl_Position.z = u_nearFarFactor * log(gl_Position.w / u_near) - 1.0;
    gl_Position.z *= gl_Position.w;
}
