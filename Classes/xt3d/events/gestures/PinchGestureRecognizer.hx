package xt3d.events.gestures;


import lime.ui.Touch;
import lime.math.Vector2;
class PinchEvent {

	// properties

	// members
	private var _position1:Vector2;
	private var _position2:Vector2;
	private var _distance:Float;
	private var _initialDistance:Float;


	public static function create():PinchEvent {
		var object = new PinchEvent();

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

}


interface PinchGestureDelegate {
	public function onPinch():Bool;
}


class PinchGestureRecognizer extends GestureRecognizer {

	// properties

	// members
	var _delegate:PinchGestureDelegate;

	private var _touch1:Touch;
	private var _touch2:Touch;

	private var _position1:Vector2 = new Vector2();
	private var _position2:Vector2 = new Vector2();


	public static function create(delegate:PinchGestureDelegate):PinchGestureRecognizer {
		var object = new PinchGestureRecognizer();

		if (object != null && !(object.initPinch(delegate))) {
			object = null;
		}

		return object;
	}

	public function initPinch(delegate:PinchGestureDelegate):Bool {
		this._delegate = delegate;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		if (button == 1) {
			return this.pinchStart(x, y);
		}
		return false;
	}

	override public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		if (button == 1) {
			return this.pinchEnd(x, y);
		}
		return false;
	}

	override public function onMouseMove (x:Float, y:Float):Bool {
		return this.pinchMove(x, y);
	}

	override public function onTouchStart (touch:Touch):Bool {
		return this.pinchStart(touch.x, touch.y);
	}

	override public function onTouchEnd (touch:Touch):Bool {
		return this.pinchEnd(touch.x, touch.y);
	}

	override public function onTouchMove (touch:Touch):Bool {
		return this.pinchMove(touch.dx, touch.dy);
	}

	/* --------- Private methods --------- */

	private function pinchStart(x:Float, y:Float):Bool {
		// Avoid multiple touches - pan is single touch only
		if (this._isRecognizing) {
			this._isRecognizing = false;
			return false;
		}

		this._isRecognizing = true;

		return false;
	}

	private function panMove(x:Float, y:Float):Bool {
	}

	private function panEnd(x:Float, y:Float):Bool {
		this._isRecognizing = false;

		return false;
	}

}
