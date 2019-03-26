package xt3d.gl.view;

import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import xt3d.utils.geometry.Size;
import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.app.Application;
import xt3d.utils.geometry.Size;
import lime.math.Rectangle;
import xt3d.utils.errors.XTException;
import xt3d.utils.XT;
import lime.graphics.WebGLRenderContext;
import xt3d.core.EventEmitter;
import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
import lime.ui.GamepadAxis;
import lime.ui.Gamepad;

class Xt3dLimeGLView extends Application implements Xt3dGLView {

	// properties
	public var gl(get, null):WebGLRenderContext;
	public var size(get, null):Size<Int>;
	public var touchDelegate(get, set):TouchDelegate;
	public var mouseDelegate(get, set):MouseDelegate;

	// members
	private var _gl:WebGLRenderContext = null;
	private var _listeners:Array<Xt3dGLViewListener> = new Array<Xt3dGLViewListener>();
	private var _width:Int = 0;
	private var _height:Int = 0;
	private var _renderCallback:RenderContext->Void;
	private var _windowResizeCallback:Window->Int->Int->Void;

	private var _touchDelegate:TouchDelegate;
	private var _mouseDelegate:MouseDelegate;

	public static function create():Xt3dLimeGLView {
		var object = new Xt3dLimeGLView();

		if (object != null && !(object.initView())) {
			object = null;
		}

		return object;
	}

	public function initView():Bool {
		// Set first render callback to be an initialisation call
		this._renderCallback = this.onApplicationReady;
		this._windowResizeCallback = function (window:Window, width:Int, height:Int) {
			// Dummy function
		};

		return true;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* ----------- Xt3dGLView Properties ----------- */

	inline public function get_gl():WebGLRenderContext {
		return this._gl;
	}

	inline public function get_size():Size<Int> {
		return Size.createIntSize(this._width, this._height);
	}

	inline public function get_touchDelegate():TouchDelegate {
		return this._touchDelegate;
	}

	inline public function set_touchDelegate(value:TouchDelegate) {
		return this._touchDelegate = value;
	}

	inline public function get_mouseDelegate():MouseDelegate {
		return this._mouseDelegate;
	}

	inline public function set_mouseDelegate(value:MouseDelegate) {
		return this._mouseDelegate = value;
	}


	/* --------- Implementation --------- */

	private inline function onInit():Void {
		// Initialise width and height
		this._width = Application.current.window.width;
		this._height = Application.current.window.height;

		for (listener in this._listeners) {
			listener.onContextInitialised(this);
		}
	}

	private inline function onUpdateEvent(dt:Float):Void {
		for (listener in this._listeners) {
			listener.onUpdate(this, dt);
		}
	}

	private inline function onRender():Void {
		for (listener in this._listeners) {
			listener.onRender(this);
		}
	}

	private inline function onEvent(event:String):Void {
		for (listener in this._listeners) {
			listener.onEvent(this, event);
		}
	}

	private inline function setRenderContext(context:RenderContext):Void {
        if (context.webgl != null) {
            if (this._gl == null) {
                this._gl = context.webgl;

            } else if (this._gl != context.webgl) {
                // TODO Handle change of render context
                throw new XTException("RenderContextChanged", "The OpenGL render context changed which wasn't expected");
            }
        } else {
            throw new XTException("RenderContextChanged", "Unknown RenderContext type");
        }
	}

	private inline function onApplicationReady(context:RenderContext):Void {
		this.setRenderContext(context);

		// If we have a context then initialise all listeners
		if (this._gl != null) {
			this.onInit();

		} else {
			throw new XTException("InvalidGraphicsContext", "xTalk3d cannot run without OpenGL");
		}

		// Perform a first render
		this.performRender(context);

		// Set real callbacks
		this._renderCallback = this.performRender;
		this._windowResizeCallback = this.handleWindowResize;
	}

	private inline function performRender(context:RenderContext):Void {
		// Verify render context hasn't changed
		this.setRenderContext(context);

		// Notify all listeners
		this.onRender();
	}

	private inline function handleWindowResize(window:Window, width:Int, height:Int):Void {
		this._width = width;
		this._height = height;

		this.onEvent(Xt3dGLViewEvent.RESIZE);
	}

	public function addWindow (window:Window):Void {
//		window.onActivate.add (onWindowActivate.bind (window));
//		window.onClose.add (__onWindowClose.bind (window), false, -10000);
//		window.onCreate.add (onWindowCreate.bind (window));
//		window.onDeactivate.add (onWindowDeactivate.bind (window));
//		window.onDropFile.add (onWindowDropFile.bind (window));
//		window.onEnter.add (onWindowEnter.bind (window));
//		window.onExpose.add (onWindowExpose.bind (window));
//		window.onFocusIn.add (onWindowFocusIn.bind (window));
//		window.onFocusOut.add (onWindowFocusOut.bind (window));
//		window.onFullscreen.add (onWindowFullscreen.bind (window));
//		window.onKeyDown.add (onKeyDown.bind (window));
//		window.onKeyUp.add (onKeyUp.bind (window));
//		window.onLeave.add (onWindowLeave.bind (window));
//		window.onMinimize.add (onWindowMinimize.bind (window));
//		window.onMouseDown.add (onMouseDown.bind (window));
//		window.onMouseMove.add (onMouseMove.bind (window));
//		window.onMouseMoveRelative.add (onMouseMoveRelative.bind (window));
//		window.onMouseUp.add (onMouseUp.bind (window));
//		window.onMouseWheel.add (onMouseWheel.bind (window));
//		window.onMove.add (onWindowMove.bind (window));
//		window.onResize.add (onWindowResize.bind (window));
//		window.onRestore.add (onWindowRestore.bind (window));
//		window.onTextEdit.add (onTextEdit.bind (window));
//		window.onTextInput.add (onTextInput.bind (window));

		__windows.push (window);
	}

	/* --------- Xt3dGLView Implementation --------- */

	public function addListener(listener:Xt3dGLViewListener):Void {
		if (this._listeners.indexOf(listener) == -1) {
			this._listeners.push(listener);

			// If already initialised then notify listener
			if (this._gl != null) {
				listener.onContextInitialised(this);
			}
		}
	}

	public function removeListener(listener:Xt3dGLViewListener):Void {
		var index = this._listeners.indexOf(listener);
		if (index != -1) {
			this._listeners.slice(index, 1);
		}
	}


	/* --------- Application Implementation --------- */



	/**
	 * Called when a render event is fired
	 * @param	context	The current render context
	 */
	override inline public function render(renderContext:RenderContext):Void {
		this._renderCallback(renderContext);
	}


	/**
	 * Called when an update event is fired
	 * @param	deltaTime	The amount of time in milliseconds that has elapsed since the last update
	 */
	override inline public function update (deltaTime:Int):Void {
		// Notify all listeners, convert to seconds
		this.onUpdateEvent(0.001 * deltaTime);
	}

	/**
	 * Called when a window resize event is fired
	 * @param	width	The width of the window
	 * @param	height	The height of the window
	 */
	override inline public function onWindowResize(width:Int, height:Int):Void {
		this._windowResizeCallback(this.window, width, height);
	}

	/**
	 * Called when a mouse down event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	override public function onMouseDown (x:Float, y:Float, button:Int):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseDown(this.window, x, y, button);
		}
	}


	/**
	 * Called when a mouse move event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	override public function onMouseMove (x:Float, y:Float):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseMove(this.window, x, y);
		}
	}


	/**
	 * Called when a mouse up event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the button that was released
	 */
	override public function onMouseUp (x:Float, y:Float, button:Int):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseUp(this.window, x, y, button);
		}
	}


	/**
	 * Called when a mouse wheel event is fired
	 * @param	window	The window dispatching the event
	 * @param	deltaX	The amount of horizontal scrolling (if applicable)
	 * @param	deltaY	The amount of vertical scrolling (if applicable)
	 */
	override public function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseWheel(this.window, deltaX, deltaY);
		}
	}

	/**
	 * Called when a touch end event is fired
	 * @param	touch	The current touch object
	 */
	override public function onTouchEnd (touch:Touch):Void {
		if (this._touchDelegate != null) {
			this._touchDelegate.onTouchEnd(touch);
		}
	}


	/**
	 * Called when a touch move event is fired
	 * @param	touch	The current touch object
	 */
	override public function onTouchMove (touch:Touch):Void {
		if (this._touchDelegate != null) {
			this._touchDelegate.onTouchMove(touch);
		}
	}


	/**
	 * Called when a touch start event is fired
	 * @param	touch	The current touch object
	 */
	override public function onTouchStart (touch:Touch):Void {
		if (this._touchDelegate != null) {
			this._touchDelegate.onTouchStart(touch);
		}
	}

}
