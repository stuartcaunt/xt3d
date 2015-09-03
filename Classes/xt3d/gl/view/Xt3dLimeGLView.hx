package xt3d.gl.view;

import xt3d.utils.geometry.Size;
import lime.ui.Window;
import lime.graphics.Renderer;
import lime.app.Application;
import xt3d.utils.geometry.Size;
import lime.math.Rectangle;
import xt3d.utils.errors.XTException;
import xt3d.utils.XT;
import lime.graphics.GLRenderContext;
import xt3d.core.EventEmitter;
import lime.app.Module;
import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
import lime.ui.GamepadAxis;
import lime.ui.Gamepad;
import lime.graphics.RenderContext;
import lime.app.Module;

class Xt3dLimeGLView extends Module implements Xt3dGLView {

	// properties
	public var gl(get, null):GLRenderContext;
	public var size(get, null):Size<Int>;

	// members
	private var _gl:GLRenderContext = null;
	private var _listeners:Array<Xt3dGLViewListener> = new Array<Xt3dGLViewListener>();
	private var _width:Int = 0;
	private var _height:Int = 0;
	private var _renderCallback:RenderContext->Void;
	private var _windowResizeCallback:Window->Int->Int->Void;

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

	public function get_gl():GLRenderContext {
		return this._gl;
	}

	public function get_size():Size<Int> {
		return Size.createIntSize(this._width, this._height);
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

	private inline function onUpdate(dt:Float):Void {
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
		switch (context) {

			case OPENGL (gl):
				if (this._gl == null) {
					this._gl = gl;

				} else if (this._gl != gl) {
					// TODO Handle change of render context
					throw new XTException("RenderContextChanged", "The OpenGL render context changed which wasn't expected");
				}

			default:
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



	/**
	 * Called when a render event is fired
	 * @param	context	The current render context
	 */
	override inline public function render(renderer:Renderer):Void {
		this._renderCallback(renderer.context);
	}


	/**
	 * Called when an update event is fired
	 * @param	deltaTime	The amount of time in milliseconds that has elapsed since the last update
	 */
	override inline public function update (deltaTime:Int):Void {
		// Notify all listeners, convert to seconds
		this.onUpdate(0.001 * deltaTime);
	}

	/**
	 * Called when a window resize event is fired
	 * @param	width	The width of the window
	 * @param	height	The height of the window
	 */
	override inline public function onWindowResize(window:Window, width:Int, height:Int):Void {
		this._windowResizeCallback(window, width, height);
	}


}
