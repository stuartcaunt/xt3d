package xt3d.events.gestures;


import lime.ui.Touch;
import lime.math.Vector2;
class PinchEvent {

	// properties

	// members
	private var _position1:Vector2;
	private var _position2:Vector2;
	private var _deltaDistance:Float;
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
	public var pinchThreshold(get, set):Float;

	// members
	private var _pinchThreshold:Float = 2.0;

	var _delegate:PinchGestureDelegate;

	private var _touches:Array<Touch> = new Array<Touch>();
	private var _lastTouchDistance:Float;

	private var _initialMousePosition:Vector2 = new Vector2();
	private var _mouseLocation:Vector2 = new Vector2();

	private var _isRecognizing:Bool = false;




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

	function get_pinchThreshold():Float {
		return this._pinchThreshold;
	}

	function set_pinchThreshold(value:Float) {
		return this._pinchThreshold = value;
	}



/* --------- Implementation --------- */

	override public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		if (button == 1) {
			// Avoid multiple touches - pan is single touch only
			if (this._isRecognizing) {
				return false;
			}

			this._initialMousePosition.setTo(x, y);
			this._mouseLocation.setTo(x, y);

			this._isRecognizing = true;
		}
		return false;
	}

	override public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		if (button == 1) {
			this._isRecognizing = false;
		}
		return false;
	}

	override public function onMouseMove (x:Float, y:Float):Bool {
		if (!this._isRecognizing) {
			return false;
		}

		// Check for threshold
		if (Math.abs(x - this._mouseLocation.x) < this._pinchThreshold || Math.abs(y - this._mouseLocation.y) < this._pinchThreshold) {
			return false;
		}

		this._mouseLocation.setTo(x, y);

		return this.pinchMove(this._initialMousePosition, this._mouseLocation);
	}

	override public function onTouchStart (touch:Touch):Bool {
		if (this._isRecognizing) {
			return false;
		}

		this._touches.push(touch);

		//start recognizing after that 2 fingers are touching
		if (this._touches.length == 2) {
			var touch1 = this._touches[0];
			var touch2 = this._touches[1];

			var dx = Math.abs(touch1.x - touch2.x);
			var dy = Math.abs(touch1.y - touch2.y);

			this._lastTouchDistance = Math.sqrt(dx * dx + dy* dy);

			this._isRecognizing = true;
		}

		return false;
	}

	override public function onTouchEnd (touch:Touch):Bool {
		this._isRecognizing = false;
		var touchIndex = this._touches.indexOf(touch);
		if (touchIndex >= 0) {
			this._touches.splice(touchIndex, 1);
		}
		return false;
	}

	override public function onTouchMove (touch:Touch):Bool {
		if (!this._isRecognizing) {
			return;
		}

		var touch1 = this._touches[0];
		var touch2 = this._touches[1];

		// Check moved enough
		if ((Math.abs(touch1.dx) < this._pinchThreshold && Math.abs(touch1.dy) < this._pinchThreshold) ||
			(Math.abs(touch2.dx) < this._pinchThreshold && Math.abs(touch2.dy) < this._pinchThreshold)) {
			return false;
		}

		// Check moving in oposite directions
		if ((touch1.dx < 0.0 && touch2.dx < 0.0) || (touch1.dx > 0.0 && touch2.dx > 0.0) ||
			(touch1.dy < 0.0 && touch2.dy < 0.0) || (touch1.dy > 0.0 && touch2.dx > 0.0)) {
			return false;
		}


		this._touchPosition1.setTo(touch1.x, touch1.y);
		this._touchPosition2.setTo(touch2.x, touch2.y);

		var dx = Math.abs(touch1.x - touch2.x);
		var dy = Math.abs(touch1.y - touch2.y);

		var distance = Math.sqrt(dx * dx + dy* dy);

		CCPinch * pinch = CCPinch::create();

//decide type of pinch
		if (lastDistance<=distance) {
		pinch->type = kPinchGestureRecognizerTypeOpen;
		}
		else {
		pinch->type = kPinchGestureRecognizerTypeClose;
		}

		gestureRecognized(pinch);
	}

	/* --------- Private methods --------- */


	private function pinchMove(position1:Vector2, position2, Vector2):Bool {

	}


}
