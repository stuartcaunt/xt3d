package xt3d.gl.view;

import lime.app.Module;
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

class Xt3dLimeGLView extends Module implements Xt3dGLView {

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


	/* --------- Module Implementation --------- */

	private override function __registerLimeModule(application:Application):Void
	{
		application.onCreateWindow.add(onCreateWindow);
		application.onUpdate.add(update);
		Touch.onStart.add(onTouchStart);
		Touch.onMove.add(onTouchMove);
		Touch.onEnd.add(onTouchEnd);

        if (application.window != null) {
            this.onCreateWindow(application.window);
        }
	}

	private override function __unregisterLimeModule(application:Application):Void
	{
		application.onCreateWindow.remove(onCreateWindow);
		application.onUpdate.remove(update);
		Touch.onStart.remove(onTouchStart);
		Touch.onMove.remove(onTouchMove);
		Touch.onEnd.remove(onTouchEnd);
	}


	/* --------- Application events --------- */

	private function onCreateWindow(window:Window):Void
	{
		window.onRender.add (render);
		window.onMouseDown.add (onMouseDown);
		window.onMouseMove.add (onMouseMove);
		window.onMouseUp.add (onMouseUp);
		window.onMouseWheel.add (onMouseWheel);
		window.onResize.add (onWindowResize);
	}

	/**
	 * Called when a render event is fired
	 * @param	context	The current render context
	 */
    inline public function render(renderContext:RenderContext):Void {
		this._renderCallback(renderContext);
	}


	/**
	 * Called when an update event is fired
	 * @param	deltaTime	The amount of time in milliseconds that has elapsed since the last update
	 */
    inline public function update (deltaTime:Int):Void {
		// Notify all listeners, convert to seconds
		this.onUpdateEvent(0.001 * deltaTime);
	}

	/**
	 * Called when a window resize event is fired
	 * @param	width	The width of the window
	 * @param	height	The height of the window
	 */
    inline public function onWindowResize(width:Int, height:Int):Void {
		this._windowResizeCallback(Application.current.window, width, height);
	}

	/**
	 * Called when a mouse down event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseDown (x:Float, y:Float, button:Int):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseDown(Application.current.window, x, y, button);
		}
	}


	/**
	 * Called when a mouse move event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the mouse button that was pressed
	 */
	public function onMouseMove (x:Float, y:Float):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseMove(Application.current.window, x, y);
		}
	}


	/**
	 * Called when a mouse up event is fired
	 * @param	window	The window dispatching the event
	 * @param	x	The current x coordinate of the mouse
	 * @param	y	The current y coordinate of the mouse
	 * @param	button	The ID of the button that was released
	 */
	public function onMouseUp (x:Float, y:Float, button:Int):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseUp(Application.current.window, x, y, button);
		}
	}


	/**
	 * Called when a mouse wheel event is fired
	 * @param	window	The window dispatching the event
	 * @param	deltaX	The amount of horizontal scrolling (if applicable)
	 * @param	deltaY	The amount of vertical scrolling (if applicable)
	 */
	public function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (this._mouseDelegate != null) {
			this._mouseDelegate.onMouseWheel(Application.current.window, deltaX, deltaY);
		}
	}

	/**
	 * Called when a touch end event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchEnd (touch:Touch):Void {
		if (this._touchDelegate != null) {
			this._touchDelegate.onTouchEnd(touch);
		}
	}


	/**
	 * Called when a touch move event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchMove (touch:Touch):Void {
		if (this._touchDelegate != null) {
			this._touchDelegate.onTouchMove(touch);
		}
	}


	/**
	 * Called when a touch start event is fired
	 * @param	touch	The current touch object
	 */
	public function onTouchStart (touch:Touch):Void {
		if (this._touchDelegate != null) {
			this._touchDelegate.onTouchStart(touch);
		}
	}

}
