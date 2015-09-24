package xt3d.events;

import xt3d.utils.XT;
import lime.ui.Window;
import xt3d.gl.view.MouseDelegate;

class MouseDispatcher implements MouseDelegate {

	// properties

	// members

	public static function create():MouseDispatcher {
		var object = new MouseDispatcher();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	/**
	 * Called when a mouse down event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseDown (window:Window, x:Float, y:Float, button:Int):Void {
		//XT.Log("Mouse down at " + x + ", " + y);
	}

	/**
	 * Called when a mouse move event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseMove (window:Window, x:Float, y:Float):Void {
		//XT.Log("Mouse move to " + x + ", " + y);
	}

	/**
	 * Called when a mouse move relative event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The x movement of the mouse
	 * @param	y	The y movement of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseMoveRelative (window:Window, x:Float, y:Float):Void {
		//XT.Log("Mouse move by " + x + ", " + y);
	}

	/**
	 * Called when a mouse up event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the button that was released
	 */
	public function onMouseUp (window:Window, x:Float, y:Float, button:Int):Void {
		//XT.Log("Mouse up at " + x + ", " + y);
	}

	/**
	 * Called when a mouse wheel event is fired
	 * @param	window	The window dispatching the event
	 * @param	deltaX	The amount of horizontal scrolling (if applicable)
	 * @param	deltaY	The amount of vertical scrolling (if applicable)
	 */
	public function onMouseWheel (window:Window, deltaX:Float, deltaY:Float):Void {
		//XT.Log("Mouse wheel by " + deltaX + ", " + deltaY);
	}

}
