package xt3d.events.gestures;

import lime.ui.Touch;
class GestureRecognizer {

	// properties

	// members

	public function init():Bool {
		return true;
	}


	public function new() {
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function update(dt:Float):Void {
	}

	public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		return false;
	}

	public function onMouseMove (x:Float, y:Float):Bool {
		return false;
	}

	public function onMouseMoveRelative (x:Float, y:Float):Bool {
		return false;
	}

	public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		return false;
	}

	public function onMouseWheel (deltaX:Float, deltaY:Float):Bool {
		return false;
	}

	public function onTouchStart (touch:Touch):Bool {
		return false;
	}

	public function onTouchEnd (touch:Touch):Bool {
		return false;
	}

	public function onTouchMove (touch:Touch):Bool {
		return false;
	}

}
