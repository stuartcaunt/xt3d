package xt3d.gl.view;

import lime.ui.Touch;

interface TouchDelegate {
	/**
	 * Called when a touch end event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchEnd (touch:Touch):Void;


	/**
	 * Called when a touch move event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchMove (touch:Touch):Void;


	/**
	 * Called when a touch start event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchStart (touch:Touch):Void;
}
