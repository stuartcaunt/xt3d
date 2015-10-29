package xt3d.events.gestures;

import lime.ui.Touch;
import lime.math.Vector2;

class PanEvent {

	// properties
	public var location(get, null):Vector2;
	public var delta(get, null):Vector2;
	public var globalDelta(get, null):Vector2;

	// members
	private var _location:Vector2;
	private var _delta:Vector2;
	private var _globalDelta:Vector2;


	public static function create(location:Vector2, delta:Vector2, globalDelta:Vector2):PanEvent {
		var object = new PanEvent();

		if (object != null && !(object.init(location, delta, globalDelta))) {
			object = null;
		}

		return object;
	}

	public function init(location:Vector2, delta:Vector2, globalDelta:Vector2):Bool {
		this._location = location;
		this._delta = delta;
		this._globalDelta = globalDelta;
		return true;
	}


	public function new() {
	}

	/* ----------- Properties ----------- */

	function get_location():Vector2 {
		return this._location;
	}

	function get_delta():Vector2 {
		return this._delta;
	}

	function get_globalDelta():Vector2 {
		return this._globalDelta;
	}

	/* --------- Implementation --------- */

}


interface PanGestureDelegate {
	public function onPan(panEvent:PanEvent):Bool;
}

class PanGestureRecognizer extends GestureRecognizer {

	// properties

	// members
	private var _delegate:PanGestureDelegate;
	private var _initialPosition:Vector2 = new Vector2();
	private var _location:Vector2 = new Vector2();
	private var _delta:Vector2 = new Vector2();
	private var _globalDelta:Vector2 = new Vector2();
	private var _isRecognizing:Bool;

	public static function create(delegate:PanGestureDelegate):PanGestureRecognizer {
		var object = new PanGestureRecognizer();

		if (object != null && !(object.initPan(delegate))) {
			object = null;
		}

		return object;
	}

	public function initPan(delegate:PanGestureDelegate):Bool {
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

	/* --------- Implementation --------- */

	override public function onGestureClaimed():Void {
		this._isRecognizing = false;
	}

	override public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		if (button == 0) {
			return this.panStart(x, y);
		}
		return false;
	}

	override public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		if (button == 0) {
			return this.panEnd(x, y);
		}
		return false;
	}

	override public function onMouseMove (x:Float, y:Float):Bool {
		return this.panMove(x, y);
	}

	override public function onTouchStart (touch:Touch):Bool {
		return this.panStart(touch.x, touch.y);
	}

	override public function onTouchEnd (touch:Touch):Bool {
		return this.panEnd(touch.x, touch.y);
	}

	override public function onTouchMove (touch:Touch):Bool {
		return this.panMove(touch.dx, touch.dy);
	}

	/* --------- Private methods --------- */

	private function panStart(x:Float, y:Float):Bool {
		// Avoid multiple touches - pan is single touch only
		if (this._isRecognizing) {
			this._isRecognizing = false;
			return false;
		}

		this._isRecognizing = true;

		this._initialPosition.setTo(x, y);
		this._location.setTo(x, y);

		return false;
	}

	private function panMove(x:Float, y:Float):Bool {
		var cancelPropagation = false;
		if (this._isRecognizing) {
			this._delta.setTo(x - this._location.x, y - this._location.y);
			this._globalDelta.setTo(x - this._initialPosition.x, y - this._initialPosition.y);
			this._location.setTo(x, y);

			var panEvent = PanEvent.create(this._location, this._delta, this._globalDelta);
			cancelPropagation = this._delegate.onPan(panEvent);

		}
		return cancelPropagation;
	}

	private function panEnd(x:Float, y:Float):Bool {
		this._isRecognizing = false;

		return false;
	}

}
