package xt3d.events;

import xt3d.utils.XT;
import lime.ui.Touch;
import xt3d.gl.view.TouchDelegate;

class TouchDispatcher implements TouchDelegate {

	// properties

	// members
	private var _handlers:Array<TouchHandler> = new Array<TouchHandler>();
	private var _handlersToAdd:Array<TouchHandler> = new Array<TouchHandler>();
	private var _handlersToRemove:Array<TouchHandler> = new Array<TouchHandler>();
	private var _locked:Bool;

	public static function create():TouchDispatcher {
		var object = new TouchDispatcher();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		this._locked = false;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function addHandler(touchHandler:TouchHandler):Void {
		if (this._locked) {
			this._handlersToAdd.push(touchHandler);

		} else {
			if (this._handlers.indexOf(touchHandler) < 0) {
				this._handlers.push(touchHandler);
			}
		}
	}

	public function removeHandler(touchHandler:TouchHandler):Void {
		if (this._locked) {
			this._handlersToRemove.push(touchHandler);

		} else {
			var index = this._handlers.indexOf(touchHandler);
			if (index >= 0) {
				this._handlers.splice(index, 1);
			}
		}
	}

	private function handleDeferredRequests():Void {
		for (handlerToAdd in this._handlersToAdd) {
			this.addHandler(handlerToAdd);
		}
		this._handlersToAdd.splice(0, this._handlersToAdd.length);

		for (handlerToRemove in this._handlersToRemove) {
			this.removeHandler(handlerToRemove);
		}
		this._handlersToRemove.splice(0, this._handlersToRemove.length);
	}

	/**
	 * Called when a touch start event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchStart (touch:Touch):Void {
		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onTouchStart(touch);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}

	/**
	 * Called when a touch end event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchEnd (touch:Touch):Void {
		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onTouchEnd(touch);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}


	/**
	 * Called when a touch move event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchMove (touch:Touch):Void {
		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onTouchMove(touch);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}

}
