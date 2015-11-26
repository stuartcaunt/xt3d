package xt3d.events.gestures;

import xt3d.utils.XT;
import lime.system.System;
import lime.ui.Touch;
import lime.math.Vector2;


class LongPressEvent {

	public var location(get, null):Vector2;

	private var _location:Vector2;

	public static function create(location:Vector2):LongPressEvent {
		var object = new LongPressEvent();

		if (object != null && !(object.init(location))) {
			object = null;
		}

		return object;
	}

	public function init(location:Vector2):Bool {
		this._location = location;
		return true;
	}

	public function new() {
	}

	function get_location():Vector2 {
		return this._location;
	}
}


interface LongPressGestureDelegate {
	public function onLongPress(swipeEvent:LongPressEvent):Bool;
}

class LongPressGestureRecognizer extends GestureRecognizer {

	public var minDuration(get, set):Float;
	public var maxDistance(get, set):Float;

	private var _minDuration:Float = 0.5;
	private var _maxDistance:Float = 0.0;

	private var _delegate:LongPressGestureDelegate;
	private var _isRecognizing:Bool;
	private var _initialPosition:Vector2 = new Vector2();
	private var _currentPosition:Vector2 = new Vector2();

	public static function create(delegate:LongPressGestureDelegate):LongPressGestureRecognizer {
		var object = new LongPressGestureRecognizer();

		if (object != null && !(object.initLongPress(delegate))) {
			object = null;
		}

		return object;
	}

	public function initLongPress(delegate:LongPressGestureDelegate):Bool {
		var initOk;
		if ((initOk = super.init())) {
			this._delegate = delegate;
			this._isRecognizing = false;
		}
		return initOk;
	}

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */

	function get_minDuration():Float {
		return this._minDuration;
	}

	function set_minDuration(value:Float) {
		return this._minDuration = value;
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
			return this.pressStart(x, y);
		}
		return false;
	}

	override public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		if (button == 0) {
			return this.pressEnd(x, y);
		}
		return false;
	}

	override public function onMouseMove (x:Float, y:Float):Bool {
		return this.pressMove(x, y);
	}

	override public function onTouchStart (touch:Touch):Bool {
		return this.pressStart(touch.x, touch.y);
	}

	override public function onTouchEnd (touch:Touch):Bool {
		return this.pressEnd(touch.x, touch.y);
	}

	override public function onTouchMove (touch:Touch):Bool {
		return this.pressMove(touch.x, touch.y);
	}


	/* --------- Private methods --------- */

	private function pressStart(x:Float, y:Float):Bool {
		// Avoid multi taps (two tap downs before a tap up)
		if (this._isRecognizing) {
			this.stopGestureRecognition();
			return false;
		}

		this.schedule(this.timerDidEnd, 0.0, this._minDuration, 0, false);

		this._initialPosition.setTo(x, y);
		this._isRecognizing = true;

		return false;
	}

	private function pressMove(x:Float, y:Float):Bool {
		this._currentPosition.setTo(x, y);
		return false;
	}

	private function pressEnd(x:Float, y:Float):Bool {
		this.stopGestureRecognition();
		return false;
	}

	private function stopGestureRecognition():Void {
		this._isRecognizing = false;
		this.unschedule(this.timerDidEnd);
	}

	private function timerDidEnd(dt:Float):Void {
		var distance = this.distanceBetweenPoints(this._currentPosition, this._initialPosition);

		var cancelPropagation:Bool = false;
		// check distance moved
		if (distance <= this._maxDistance) {

			// Generate event
			var longPressEvent = LongPressEvent.create(this._initialPosition.clone());
			cancelPropagation = this._delegate.onLongPress(longPressEvent);
			// How to use cancelPropagation?
		}

		this.stopGestureRecognition();
	}

}
