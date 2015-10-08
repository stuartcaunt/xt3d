package xt3d.events.gestures;


import xt3d.utils.XT;
import lime.ui.Touch;
import lime.math.Vector2;
class PinchEvent {

	// properties
	public var deltaDistance(get, null):Float;
	public var totalDistance(get, null):Float;

	// members
	private var _deltaDistance:Float;
	private var _totalDistance:Float;

	public static function create(deltaDistance:Float, totalDistance:Float):PinchEvent {
		var object = new PinchEvent();

		if (object != null && !(object.init(deltaDistance, totalDistance))) {
			object = null;
		}

		return object;
	}

	public function init(deltaDistance:Float, totalDistance:Float):Bool {
		this._deltaDistance = deltaDistance;
		this._totalDistance = totalDistance;
		return true;
	}


	public function new() {
	}

	/* ----------- Properties ----------- */


	function get_deltaDistance():Float {
		return this._deltaDistance;
	}

	function get_totalDistance():Float {
		return this._totalDistance;
	}

	/* --------- Implementation --------- */

}


interface PinchGestureDelegate {
	public function onPinch(pinchEvent:PinchEvent):Bool;
}


class PinchGestureRecognizer extends GestureRecognizer {

	// properties
	public var pinchThreshold(get, set):Float;

	// members
	private var _pinchThreshold:Float = 2.0;

	var _delegate:PinchGestureDelegate;

	private var _touches:Array<Touch> = new Array<Touch>();
	private var _initialTouchDistance:Float;
	private var _lastTouchDistance:Float;

	private var _initialMouseLocationY:Float;
	private var _mouseLocationY:Float;

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
		super();
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
		if (button == 2) {
			// Avoid multiple touches - pan is single touch only
			if (this._isRecognizing) {
				return false;
			}

			this._initialMouseLocationY = y;
			this._mouseLocationY = y;

			this._isRecognizing = true;
		}
		return false;
	}

	override public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		if (button == 2) {
			this._isRecognizing = false;
		}
		return false;
	}

	override public function onMouseMove (x:Float, y:Float):Bool {
		if (!this._isRecognizing) {
			return false;
		}

		var mouseDeltaY = y - this._mouseLocationY;
		var mouseTotalDeltaY = y - this._initialMouseLocationY;

		// Check for threshold
		if (Math.abs(mouseDeltaY) < this._pinchThreshold) {
			return false;
		}

		this._mouseLocationY = y;

		return this.pinchMove(-mouseDeltaY, -mouseTotalDeltaY);
	}

	override public function onMouseWheel (deltaX:Float, deltaY:Float):Bool {
		if (this._isRecognizing) {
			return false;
		}

		return this.pinchMove(-deltaY * 2, -deltaY * 2);

		return false;
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
			this._initialTouchDistance = this._lastTouchDistance;

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
			return false;
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

		var dx = Math.abs(touch1.x - touch2.x);
		var dy = Math.abs(touch1.y - touch2.y);

		var distance = Math.sqrt(dx * dx + dy* dy);


		var deltaDistance = distance - this._lastTouchDistance;
		var totalDistance = distance - this._initialTouchDistance;
		this._lastTouchDistance = distance;

		return this.pinchMove(deltaDistance, totalDistance);
	}

	/* --------- Private methods --------- */


	private function pinchMove(deltaDistance:Float, totalDistance:Float):Bool {
		var pinchEvent = PinchEvent.create(deltaDistance, totalDistance);
		var cancelPropagation = this._delegate.onPinch(pinchEvent);

		return cancelPropagation;
	}


}
