package xt3d.events.gestures;

import xt3d.utils.XT;
import lime.system.System;
import lime.ui.Touch;
import lime.math.Vector2;


class SwipeEvent {

	public var location(get, null):Vector2;
	public var direction(get, null):Int;

	private var _location:Vector2;
	private var _direction:Int;

	public static function create(location:Vector2, swipeDirection:Int):SwipeEvent {
		var object = new SwipeEvent();

		if (object != null && !(object.init(location, swipeDirection))) {
			object = null;
		}

		return object;
	}

	public function init(location:Vector2, swipeDirection:Int):Bool {
		this._location = location;
		this._direction = swipeDirection;
		return true;
	}

	public function new() {
	}

	function get_location():Vector2 {
		return this._location;
	}

	function get_direction():Int {
		return this._direction;
	}

}


interface SwipeGestureDelegate {
	public function onSwipe(swipeEvent:SwipeEvent):Bool;
}


class SwipeGestureRecognizer extends GestureRecognizer {

	public static inline var DirectionLeft:Int = 1 << 0;
	public static inline var DirectionRight:Int = 1 << 1;
	public static inline var DirectionUp:Int = 1 << 2;
	public static inline var DirectionDown:Int = 1 << 3;

	public var maxDuration(get, set):Float;
	public var minDistance(get, set):Float;

	private var _maxDuration:Float = 300.0;
	private var _minDistance:Float = 60.0;

	private var _delegate:SwipeGestureDelegate;
	private var _isRecognizing:Bool;
	private var _initialPosition:Vector2 = new Vector2();
	private var _finalPosition:Vector2 = new Vector2();
	private var _startTime:Int;
	private var _endTime:Int;
	private var _swipeDirection:Int = 0;

	public static function create(delegate:SwipeGestureDelegate, swipeDirection:Int):SwipeGestureRecognizer {
		var object = new SwipeGestureRecognizer();

		if (object != null && !(object.initSwipe(delegate, swipeDirection))) {
			object = null;
		}

		return object;
	}

	public function initSwipe(delegate:SwipeGestureDelegate, swipeDirection:Int):Bool {
		var initOk;
		if ((initOk = super.init())) {
			this._delegate = delegate;
			this._isRecognizing = false;
			this._swipeDirection = swipeDirection;
		}
		return initOk;
	}

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */

	function get_maxDuration():Float {
		return this._maxDuration;
	}

	function set_maxDuration(value:Float) {
		return this._maxDuration = value;
	}

	function get_minDistance():Float {
		return this._minDistance;
	}

	function set_minDistance(value:Float) {
		return this._minDistance = value;
	}



	/* --------- Implementation --------- */

	override public function onGestureClaimed():Void {
		this.stopGestureRecognition();
	}

	override public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		if (button == 0) {
			return this.swipeStart(x, y);
		}
		return false;
	}

	override public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		if (button == 0) {
			return this.swipeEnd(x, y);
		}
		return false;
	}

	override public function onTouchStart (touch:Touch):Bool {
		return this.swipeStart(touch.x, touch.y);
	}

	override public function onTouchEnd (touch:Touch):Bool {
		return this.swipeEnd(touch.x, touch.y);
	}


	/* --------- Private methods --------- */

	private function swipeStart(x:Float, y:Float):Bool {
		// Avoid multi taps (two tap downs before a tap up)
		if (this._isRecognizing) {
			this.stopGestureRecognition();
			return false;
		}

		var time = System.getTimer();

		this._initialPosition.setTo(x, y);
		this._startTime = time;

		this._isRecognizing = true;

		return false;
	}

	private function swipeEnd(x:Float, y:Float):Bool {
		var cancelPropagation = false;
		if (this._isRecognizing) {

			//calculate duration
			var time = System.getTimer();
			this._endTime = time;
			var duration = (this._endTime - this._startTime); // duration of tap in milliseconds

			//calculate distance
			this._finalPosition.x = x;
			this._finalPosition.y = y;
			var distance = this.distanceBetweenPoints(this._finalPosition, this._initialPosition);

			// check swipe distance and duration match
			if (duration <= this._maxDuration && distance >= this._minDistance) {
				var direction = this.getSwipeDirection(this._initialPosition, this._finalPosition);
				if (direction != 0) {

					// Generate swipe event
					var swipeEvent = SwipeEvent.create(this._initialPosition.clone(), direction);
					cancelPropagation = this._delegate.onSwipe(swipeEvent);
				}
			}
			this.stopGestureRecognition();
		}

		return cancelPropagation;
	}

	private function stopGestureRecognition():Void {
		this._isRecognizing = false;
	}

	private function getSwipeDirection(p1:Vector2, p2:Vector2):Int {
		var right = (p2.x - p1.x) >= this._minDistance;
		var left = (p1.x - p2.x) >= this._minDistance;
		var down = (p2.y - p1.y) >= this._minDistance;
		var up = (p1.y - p2.y) >= this._minDistance;

		if (right && (this._swipeDirection & DirectionRight) != 0) {
			return DirectionRight;

		} else if (left && (this._swipeDirection & DirectionLeft) != 0) {
			return DirectionLeft;

		} else if (up && (this._swipeDirection & DirectionUp) != 0) {
			return DirectionUp;

		} else if (down && (this._swipeDirection & DirectionDown) != 0) {
			return DirectionDown;
		}

		return 0;
	}

}
