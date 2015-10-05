package xt3d.events.gestures;

import lime.system.System;
import xt3d.utils.XT;
import lime.ui.Touch;
import lime.math.Vector2;

enum TapType {
	TapTypeDown;
	TapTypeUp;
}

class TapEvent {

	public var location(get, null):Vector2;
	public var tapType(get, null):TapType;

	private var _location:Vector2;
	private var _tapType:TapType;

	public static function create(location:Vector2, tapType:TapType):TapEvent {
		var object = new TapEvent();

		if (object != null && !(object.init(location, tapType))) {
			object = null;
		}

		return object;
	}

	public function init(location:Vector2, tapType:TapType):Bool {
		this._location = location;
		this._tapType = tapType;
		return true;
	}

	public function new() {
	}

	function get_location():Vector2 {
		return this._location;
	}

	function get_tapType():TapType {
		return this._tapType;
	}

}


interface TapGestureDelegate {
	public function onTap(tapEvent:TapEvent):Bool;
}


class TapGestureRecognizer extends GestureRecognizer {

	public var maxDurationBetweenTaps(get, set):Float;
	public var maxDistanceBetweenTaps(get, set):Float;
	public var maxDuration(get, set):Float;
	public var maxDistance(get, set):Float;

	private var _maxDuration:Float = 1500.0;
	private var _maxDistance:Float = 20.0;
	private var _maxDurationBetweenTaps:Float = 220.0;
	private var _maxDistanceBetweenTaps:Float = 20.0;

	private var _delegate:TapGestureDelegate;
	private var _numberOfTapsRequired:Int;
	private var _taps:Int;
	private var _isRecognizing:Bool;
	private var _initialPosition:Vector2 = new Vector2();
	private var _finalPosition:Vector2 = new Vector2();
	private var _startTime:Int;
	private var _endTime:Int;

	public static function create(delegate:TapGestureDelegate, numberOfTapsRequired:Int = 1):TapGestureRecognizer {
		var object = new TapGestureRecognizer();

		if (object != null && !(object.initTap(delegate, numberOfTapsRequired))) {
			object = null;
		}

		return object;
	}

	public function initTap(delegate:TapGestureDelegate, numberOfTapsRequired:Int = 1):Bool {
		this._delegate = delegate;
		this._numberOfTapsRequired = numberOfTapsRequired;

		this._taps = 0;
		this._isRecognizing = false;

		return true;
	}

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */

	function get_maxDurationBetweenTaps():Float {
		return this._maxDurationBetweenTaps;
	}

	function set_maxDurationBetweenTaps(value:Float) {
		return this._maxDurationBetweenTaps = value;
	}

	function get_maxDistanceBetweenTaps():Float {
		return this._maxDistanceBetweenTaps;
	}

	function set_maxDistanceBetweenTaps(value:Float) {
		return this._maxDistanceBetweenTaps = value;
	}

	function get_maxDuration():Float {
		return this._maxDuration;
	}

	function set_maxDuration(value:Float) {
		return this._maxDuration = value;
	}

	function get_maxDistance():Float {
		return this._maxDistance;
	}

	function set_maxDistance(value:Float) {
		return this._maxDistance = value;
	}



	/* --------- Implementation --------- */

	override public function onGestureClaimed():Void {
		this.stopGestureRecognition();
	}

	override public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		if (button == 0) {
			return this.tapDown(x, y);
		}
		return false;
	}

	override public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		if (button == 0) {
			return this.tapUp(x, y);
		}
		return false;
	}

	override public function onTouchStart (touch:Touch):Bool {
		return this.tapDown(touch.x, touch.y);
	}

	override public function onTouchEnd (touch:Touch):Bool {
		return this.tapUp(touch.x, touch.y);
	}

	/* --------- Private methods --------- */

	private function tapDown(x:Float, y:Float):Bool {
		// Avoid multi taps (two tap downs before a tap up)
		if (this._isRecognizing && this._taps == 0) {
			this.stopGestureRecognition();
			return false;
		}

		var time = System.getTimer();

		// If first tap then store the intial position and time
		if (this._taps == 0) {
			this._initialPosition.setTo(x, y);
			this._startTime = time;
		}

		// Generate TapDown event
		var tapDown = TapEvent.create(new Vector2(x, y), TapType.TapTypeDown);
		var cancelPropagation = this._delegate.onTap(tapDown);
		var duration = (time - this._startTime); // duration of tap in milliseconds

		if (this._taps > 0 && this._taps < this._numberOfTapsRequired) {
			var distance = this.distanceBetweenPoints(this._finalPosition, this._initialPosition); //distance between taps
			if (duration > this._maxDurationBetweenTaps || distance > this._maxDistanceBetweenTaps) {
				this.stopGestureRecognition();

				this._initialPosition.setTo(x, y);
				this._startTime = time;
			}
		}

		this._isRecognizing = true;
		return cancelPropagation;
	}

	private function tapUp(x:Float, y:Float):Bool {
		var cancelPropagation = false;
		if (this._isRecognizing) {

			//calculate duration
			var time = System.getTimer();
			this._endTime = time;
			var duration = (this._endTime - this._startTime); // duration of tap in milliseconds

			//calculate distance
			this._finalPosition.x = x;
			this._finalPosition.y = y;
			var distance = this.distanceBetweenPoints(this._finalPosition, this._initialPosition); //distance between taps

			//tap was successful
			if (duration <= this._maxDuration && distance <= this._maxDistance) {

				this._taps++;
				if (this._taps == this._numberOfTapsRequired) {

					// Generate tap up
					var tapUp = TapEvent.create(this._initialPosition.clone(), TapType.TapTypeUp);
					cancelPropagation = this._delegate.onTap(tapUp);

					this.stopGestureRecognition();
				}
			} else {
				this.stopGestureRecognition();
			}
		}

		return cancelPropagation;
	}

	private function stopGestureRecognition():Void {
		this._taps = 0;
		this._isRecognizing = false;
	}

}
