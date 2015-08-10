package xt3d.gl.view;

import xt3d.utils.Size;
import lime.math.Rectangle;
import lime.graphics.GLRenderContext;
interface Xt3dGLView {

	var gl(get, null):GLRenderContext;
	var displayRect(get, null):Rectangle;
	var size(get, set):Size<Int>;

	function addListener(listener:Xt3dGLViewListener):Void;
	function removeListener(listener:Xt3dGLViewListener):Void;

	function get_gl():GLRenderContext;
	function get_displayRect():Rectangle;
	function set_size(size:Size<Int>):Size<Int>;
	function get_size():Size<Int>;


}
