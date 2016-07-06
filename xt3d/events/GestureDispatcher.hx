package xt3d.events;

import lime.math.Vector2;
import lime.math.Matrix3;
import xt3d.view.View;
import xt3d.core.Director;
import xt3d.utils.XT;
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
	private var _director:Director;
	private var _activeView:View;
	private var _vector:Vector2 = new Vector2();

	public static function create(director:Director):GestureDispatcher {
		var object = new GestureDispatcher();

		if (object != null && !(object.init(director))) {
			object = null;
		}

		return object;
	}

	public function init(director:Director):Bool {
		this._director = director;
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


	private function handleEvent(eventHandler:GestureRecognizer->Bool):Bool {
		this._locked = true;
		var iterator = this._gestureRecognizers.iterator();
		var claimingRecognizer:GestureRecognizer = null;
		var isClaimed = false;

		// Iterate over gesture recognizers until one claims the event
		while (iterator.hasNext() && !isClaimed) {
			var gestureRecognizer = iterator.next();

			if (this._activeView.isNodeInView(gestureRecognizer)) {
				isClaimed = eventHandler(gestureRecognizer);
				if (isClaimed) {
					claimingRecognizer = gestureRecognizer;
				}
			}
		}

		// If claimed then cancel all recognizers
		if (isClaimed) {
			for (gestureRecognizer in this._gestureRecognizers) {
				if (gestureRecognizer != claimingRecognizer) {
					gestureRecognizer.onGestureClaimed();
				}
			}
		}

		this._locked = false;

		return isClaimed;
	}

	public function onMouseDown (x:Float, y:Float, button:Int):Bool {
		this._vector.setTo(x, y);
		// Set the active view on a mouse down
		this._activeView = this.getViewForScreenPosition(x, y);

		if (this._activeView == null) {
			return false;
		}

		// Transform screen position to view
		var transformedPosition = this.transformScreenPositionToViewPosition(x, y);

		var isClaimed = this.handleEvent(function (gestureRecognizer:GestureRecognizer):Bool {
			return gestureRecognizer.onMouseDown(transformedPosition.x, transformedPosition.y, button);
		});

		return isClaimed;
	}

	public function onMouseMove (x:Float, y:Float):Bool {
		// Set the active view on a mouse move only if it is null
		if (this._activeView == null) {
			this._activeView = this.getViewForScreenPosition(x, y);
		}

		if (this._activeView == null) {
			return false;
		}

		// Transform screen position to view
		var transformedPosition = this.transformScreenPositionToViewPosition(x, y);

		var isClaimed = this.handleEvent(function (gestureRecognizer:GestureRecognizer):Bool {
			return gestureRecognizer.onMouseMove(transformedPosition.x, transformedPosition.y);
		});

		return isClaimed;
	}

	public function onMouseUp (x:Float, y:Float, button:Int):Bool {

		if (this._activeView == null) {
			return false;
		}

		// Transform screen position to view
		var transformedPosition = this.transformScreenPositionToViewPosition(x, y);

		var isClaimed = this.handleEvent(function (gestureRecognizer:GestureRecognizer):Bool {
			return gestureRecognizer.onMouseUp(transformedPosition.x, transformedPosition.y, button);
		});

		// Set the active view on mouse up after calculating view position with previous active view
		this._activeView = null; //this._director.getViewContainingScreenPosition(this._vector);

		return isClaimed;
	}

	public function onMouseWheel (deltaX:Float, deltaY:Float):Bool {

		if (this._activeView == null) {
			return false;
		}

		// Transform screen position to view and make relative
		var transformedPosition = this.transformDeltaScreenPositionToDeltaViewPosition(deltaX, deltaY);

		var isClaimed = this.handleEvent(function (gestureRecognizer:GestureRecognizer):Bool {
			return gestureRecognizer.onMouseWheel(transformedPosition.x, transformedPosition.y);
		});

		return isClaimed;
	}

	public function onTouchStart (touch:Touch):Bool {
		// Set the active view on a mouse down
		this._activeView = this.getViewForScreenPosition(touch.x, touch.y);

		if (this._activeView == null) {
			return false;
		}

		// Convert touch to view
		var touchInView = this.getTouchInView(touch);

		var isClaimed = this.handleEvent(function (gestureRecognizer:GestureRecognizer):Bool {
			return gestureRecognizer.onTouchStart(touchInView);
		});

		return isClaimed;
	}

	public function onTouchEnd (touch:Touch):Bool {

		if (this._activeView == null) {
			return false;
		}

		// Convert touch to view
		var touchInView = this.getTouchInView(touch);

		var isClaimed = this.handleEvent(function (gestureRecognizer:GestureRecognizer):Bool {
			return gestureRecognizer.onTouchEnd(touchInView);
		});

		// Set the active view on touch up after calculating the touchInView with previous active view
		this._activeView = null; //this._director.getViewContainingScreenPosition(this._vector);

		return isClaimed;
	}

	public function onTouchMove (touch:Touch):Bool {
		// Set the active view on a mouse move only if it is null
		if (this._activeView == null) {
			this._activeView = this.getViewForScreenPosition(touch.x, touch.y);
		}

		if (this._activeView == null) {
			return false;
		}

		// Convert touch to view
		var touchInView = this.getTouchInView(touch);

		var isClaimed = this.handleEvent(function (gestureRecognizer:GestureRecognizer):Bool {
			return gestureRecognizer.onTouchMove(touchInView);
		});

		return isClaimed;
	}

	private function getViewForScreenPosition(x:Float, y:Float):View {
		return this._director.getViewForGestureScreenPosition(x, this._director.displaySize.height - y);
	}

	private function getTouchInView(touch:Touch):Touch {
		var p = this.transformScreenPositionToViewPosition(touch.x, touch.y);
		this._vector.setTo(touch.dx, -touch.dy);
		var dp = this._activeView.viewTransform.deltaTransformVector2(this._vector);

		var touchInView = new Touch(p.x, p.y, touch.id, dp.x, dp.y, touch.pressure, touch.device);

		return touchInView;
	}

	private function transformScreenPositionToViewPosition(x:Float, y:Float):Vector2 {
		var height = this._director.displaySize.height;
		this._vector.setTo(x, height - y);
		var viewTransform = this._activeView.viewTransform;
		var transformed = viewTransform.transformVector2(this._vector);

		return transformed;
	}

	private function transformDeltaScreenPositionToDeltaViewPosition(dx:Float, dy:Float):Vector2 {
		this._vector.setTo(dx, -dy);
		var viewTransform = this._activeView.viewTransform;
		var transformed = viewTransform.deltaTransformVector2(this._vector);

		return transformed;
	}

}
