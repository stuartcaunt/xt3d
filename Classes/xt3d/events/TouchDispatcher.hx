package xt3d.events;

import xt3d.utils.XT;
import lime.ui.Touch;
import xt3d.gl.view.TouchDelegate;

class TouchDispatcher implements TouchDelegate {

	// properties

	// members

	public static function create():TouchDispatcher {
		var object = new TouchDispatcher();

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
	 * Called when a touch end event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchEnd (touch:Touch):Void {
		//XT.Log("Touch end at " + touch.x + ", " + touch.y);
	}


	/**
	 * Called when a touch move event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchMove (touch:Touch):Void {
		//XT.Log("Touch move by " + touch.dx + ", " + touch.dy);
	}


	/**
	 * Called when a touch start event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchStart (touch:Touch):Void {
		//XT.Log("Touch start at " + touch.x + ", " + touch.y);
	}

}
