package xt3d.events;

import xt3d.utils.XTObject;
import xt3d.events.gestures.GestureRecognizer;
import lime.ui.Touch;

class GestureDispatcher implements MouseHandler implements TouchHandler {

	// properties

	// members
	private var _gestureRecognizers:Array<GestureRecognizer>;
	private var _recognizersToAdd:Array<GestureRecognizer> = new Array<GestureRecognizer>();
	private var _recognizersToRemove:Array<GestureRecognizer> = new Array<GestureRecognizer>();
	private var _locked:Bool;

	public static function create():GestureDispatcher {
		var object = new GestureDispatcher();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		this._locked = false;
		this._gestureRecognizers = new Array<GestureRecognizer>();

		return true;
	}


	public function new() {
	}

	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


	public function addGestureRecognizer(gestureRecognizer:GestureRecognizer):Void {
		if (this._locked) {
			this._recognizersToAdd.push(gestureRecognizer);

		} else {
			if (this._gestureRecognizers.indexOf(gestureRecognizer) < 0) {
				this._gestureRecognizers.push(gestureRecognizer);
			}
		}
	}

	public function removeGestureRecognizer(gestureRecognizer:GestureRecognizer):Void {
		if (this._locked) {
			this._recognizersToRemove.push(gestureRecognizer);

		} else {
			var index = this._gestureRecognizers.indexOf(gestureRecognizer);
			if (index >= 0) {
				this._gestureRecognizers.splice(index, 1);
			}
		}
	}

	private function handleDeferredRequests():Void {
		for (recognizerToAdd in this._recognizersToAdd) {
			this.addGestureRecognizer(recognizerToAdd);
		}
		this._recognizersToAdd.splice(0, this._recognizersToAdd.length);

		for (recognizerToRemove in this._recognizersToRemove) {
			this.removeGestureRecognizer(recognizerToRemove);
		}
		this._recognizersToRemove.splice(0, this._recognizersToRemove.length);
	}


	public function update(dt:Float):Void {
		this._locked = true;
		// Send update to all recognizers
		for (recognizer in this._gestureRecognizers) {
			recognizer.update(dt);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}


	public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onMouseDown(x, y, button);
		}
		this._locked = false;

		return isClaimed;
	}

	public function onMouseMove (x:Float, y:Float):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onMouseMove(x, y);
		}
		this._locked = false;

		return isClaimed;
	}

	public function onMouseMoveRelative (x:Float, y:Float):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onMouseMoveRelative(x, y);
		}
		this._locked = false;

		return isClaimed;
	}

	public function onMouseUp (x:Float, y:Float, button:Int):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onMouseUp(x, y, button);
		}
		this._locked = false;

		return isClaimed;
	}

	public function onMouseWheel (deltaX:Float, deltaY:Float):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onMouseWheel(deltaX, deltaY);
		}
		this._locked = false;

		return isClaimed;
	}

	public function onTouchStart (touch:Touch):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onTouchStart(touch);
		}
		this._locked = false;

		return isClaimed;
	}

	public function onTouchEnd (touch:Touch):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onTouchEnd(touch);
		}
		this._locked = false;

		return isClaimed;
	}

	public function onTouchMove (touch:Touch):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();
			isClaimed = gestureRecognizer.onTouchMove(touch);
		}
		this._locked = false;

		return isClaimed;
	}

}
