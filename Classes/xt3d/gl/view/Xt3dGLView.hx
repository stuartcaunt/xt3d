package xt3d.gl.view;

import xt3d.utils.geometry.Size;
import lime.math.Rectangle;
import lime.graphics.GLRenderContext;
interface Xt3dGLView {

	var gl(get, null):GLRenderContext;
	var size(get, null):Size<Int>;

	function addListener(listener:Xt3dGLViewListener):Void;
	function removeListener(listener:Xt3dGLViewListener):Void;

	function get_gl():GLRenderContext;
	function get_size():Size<Int>;


}
