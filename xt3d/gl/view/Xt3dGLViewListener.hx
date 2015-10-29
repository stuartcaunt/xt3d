package xt3d.gl.view;

import lime.graphics.GLRenderContext;
interface Xt3dGLViewListener {

	function onContextInitialised(view:Xt3dGLView):Void;
	function onUpdate(view:Xt3dGLView, dt:Float):Void;
	function onRender(view:Xt3dGLView):Void;
	function onEvent(view:Xt3dGLView, event:String):Void;
}
