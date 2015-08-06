package xt3d.gl.view;

import lime.math.Rectangle;
import lime.graphics.GLRenderContext;
interface Xt3dGLView {

	var gl(get, null):GLRenderContext;
	var width(get, null):Int;
	var height(get, null):Int;
	var displayRect(get, null):Rectangle;

	function addListener(listener:Xt3dGLViewListener):Void;
	function removeListener(listener:Xt3dGLViewListener):Void;

	function get_gl():GLRenderContext;
	function get_width():Int;
	function get_height():Int;
	function get_displayRect():Rectangle;
}
