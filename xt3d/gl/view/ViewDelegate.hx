package xt3d.gl.view;

import lime.graphics.RenderContext;
import lime.ui.Window;
interface ViewDelegate {

	/**
	 * Called when a render event is fired
	 * @param	context	The current render context
	 */
	inline public function render(renderContext:RenderContext):Void;

	/**
	 * Called when an update event is fired
	 * @param	deltaTime	The amount of time in milliseconds that has elapsed since the last update
	 */
	inline public function update (deltaTime:Int):Void;

	/**
	 * Called when a window resize event is fired
	 * @param	width	The width of the window
	 * @param	height	The height of the window
	 */
	inline public function onWindowResize(window:Window, width:Int, height:Int):Void;

}
