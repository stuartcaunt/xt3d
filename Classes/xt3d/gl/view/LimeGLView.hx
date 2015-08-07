package xt3d.gl.view;

import lime.app.Application;
import xt3d.utils.Size;
import lime.math.Rectangle;
import xt3d.utils.errors.KFException;
import xt3d.utils.XT;
import openfl._internal.renderer.opengl.GLRenderer;
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

class LimeGLView extends Module implements Xt3dGLView {

	// properties
	public var gl(get, null):GLRenderContext;
	public var width(get, null):Int;
	public var height(get, null):Int;
	public var displayRect(get, null):Rectangle;
	public var size(get, set):Size<Int>;

	// members
	private var _gl:GLRenderContext = null;
	private var _listeners:Array<Xt3dGLViewListener> = new Array<Xt3dGLViewListener>();
	private var _width:Int;
	private var _height:Int;

	public static function create(width:Int = 1024, height:Int = 768):LimeGLView {
		var object = new LimeGLView();

		if (object != null && !(object.initView(width, height))) {
			object = null;
		}

		return object;
	}

	public function initView(width:Int = 1024, height:Int = 768):Bool {
		this._width = width;
		this._height = height;

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

	public function get_width():Int {
		XT.Log("GET WIDTH REALLY");
		return this._width;
	}

	public function get_height():Int {
		return this._height;
	}

	public function get_displayRect():Rectangle {
		return new Rectangle(0, 0, this._width, this._height);
	}

	function set_size(size:Size<Int>) {
		this.onWindowResize(size.width, size.height);
		return size;
	}

	function get_size():Size<Int> {
		return Size.createIntSize(this._width, this._height);
	}


	/* --------- Implementation --------- */

	private function onInit():Void {
		// Initialise width and height
		this._width = Application.current.window.width;
		this._height = Application.current.window.height;

		for (listener in this._listeners) {
			listener.onContextInitialised(this);
		}
	}

	private function onUpdate(dt:Float):Void {
		for (listener in this._listeners) {
			listener.onUpdate(this, dt);
		}
	}

	private function onRender():Void {
		for (listener in this._listeners) {
			listener.onRender(this);
		}
	}

	private function onEvent(event:String):Void {
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
					throw new KFException("RenderContextChanged", "The OpenGL render context changed which wasn't expected");
				}

			default:
		}
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
	 * The init() method is called once before the first render()
	 * call. This can be used to do initial set-up for the current
	 * render context
	 * @param	context The current render context
	 */
	override public function init(context:RenderContext):Void {
		this.setRenderContext(context);

		// If we have a context then initialise all listeners
		if (this._gl != null) {
			this.onInit();

		} else {
			throw new KFException("InvalidGraphicsContext", "xTalk3d cannot run without OpenGL");
		}


	}


	/**
	 * Called when a render event is fired
	 * @param	context	The current render context
	 */
	override public function render(context:RenderContext):Void {
		// Verify render context hasn't changed
		this.setRenderContext(context);

		// Notify all listeners
		this.onRender();
	}


	/**
	 * Called when an update event is fired
	 * @param	deltaTime	The amount of time in milliseconds that has elapsed since the last update
	 */
	override public function update (deltaTime:Int):Void {
		// Notify all listeners
		this.onUpdate(deltaTime);
	}

	/**
	 * Called when a window resize event is fired
	 * @param	width	The width of the window
	 * @param	height	The height of the window
	 */
	override public function onWindowResize(width:Int, height:Int):Void {
		this._width = width;
		this._height = height;

		this.onEvent(Xt3dGLViewEvent.RESIZE);
	}


}
