package xt3d.events;

import xt3d.utils.XT;
import lime.ui.Window;
import xt3d.gl.view.MouseDelegate;

class MouseDispatcher implements MouseDelegate {

	// properties

	// members
	private var _handlers:Array<MouseHandler> = new Array<MouseHandler>();
	private var _handlersToAdd:Array<MouseHandler> = new Array<MouseHandler>();
	private var _handlersToRemove:Array<MouseHandler> = new Array<MouseHandler>();
	private var _locked:Bool;
	private var _gestureDispatcher:GestureDispatcher = null;

	public static function create(gestureDispatcher:GestureDispatcher):MouseDispatcher {
		var object = new MouseDispatcher();

		if (object != null && !(object.init(gestureDispatcher))) {
			object = null;
		}

		return object;
	}

	public function init(gestureDispatcher:GestureDispatcher):Bool {
		this._gestureDispatcher = gestureDispatcher;
		this._locked = false;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function addHandler(mouseHandler:MouseHandler):Void {
		if (this._locked) {
			this._handlersToAdd.push(mouseHandler);

		} else {
			if (this._handlers.indexOf(mouseHandler) < 0) {
				this._handlers.push(mouseHandler);
			}
		}
	}

	public function removeHandler(mouseHandler:MouseHandler):Void {
		if (this._locked) {
			this._handlersToRemove.push(mouseHandler);

		} else {
			var index = this._handlers.indexOf(mouseHandler);
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
	 * Called when a mouse down event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseDown(window:Window, x:Float, y:Float, button:Int):Void {
		// Delegate to gesture dispatcher first
		this._gestureDispatcher.onMouseDown(x, y, button);

		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onMouseDown(x, y, button);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}

	/**
	 * Called when a mouse move event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseMove (window:Window, x:Float, y:Float):Void {
		// Delegate to gesture dispatcher first
		this._gestureDispatcher.onMouseMove(x, y);

		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onMouseMove(x, y);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}

	/**
	 * Called when a mouse move relative event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The x movement of the mouse
	 * @param	y	The y movement of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseMoveRelative (window:Window, x:Float, y:Float):Void {
		// Delegate to gesture dispatcher first
		this._gestureDispatcher.onMouseMoveRelative(x, y);

		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onMouseMoveRelative(x, y);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}

	/**
	 * Called when a mouse up event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the button that was released
	 */
	public function onMouseUp (window:Window, x:Float, y:Float, button:Int):Void {
		// Delegate to gesture dispatcher first
		this._gestureDispatcher.onMouseUp(x, y, button);

		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onMouseUp(x, y, button);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}

	/**
	 * Called when a mouse wheel event is fired
	 * @param	window	The window dispatching the event
	 * @param	deltaX	The amount of horizontal scrolling (if applicable)
	 * @param	deltaY	The amount of vertical scrolling (if applicable)
	 */
	public function onMouseWheel (window:Window, deltaX:Float, deltaY:Float):Void {
		// Delegate to gesture dispatcher first
		this._gestureDispatcher.onMouseWheel(deltaX, deltaY);

		this._locked = true;
		var iterator = this._handlers.iterator();
		var isClaimed = false;

		// Iterate over handlers until one claims the mouse event
		while (iterator.hasNext() && !isClaimed) {
			var handler = iterator.next();
			isClaimed = handler.onMouseWheel(deltaX, deltaY);
		}
		this._locked = false;
		this.handleDeferredRequests();
	}

}
