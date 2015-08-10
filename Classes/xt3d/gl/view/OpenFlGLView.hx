package xt3d.gl.view;

import openfl.display.OpenGLView;
import xt3d.utils.XT;
import lime.math.Rectangle;
import xt3d.utils.Size;
import openfl.errors.Error;
import openfl.Lib;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl._internal.renderer.AbstractRenderer;
import openfl._internal.renderer.AbstractRenderer;
import lime.graphics.RenderContext;
import xt3d.utils.errors.KFException;
import lime.graphics.GLRenderContext;
import openfl.events.Event;
import openfl.display.Sprite;

class OpenFlGLView extends OpenGLView implements Xt3dGLView {

	// properties
	public var gl(get, null):GLRenderContext;
	public var displayRect(get, null):Rectangle;
	public var size(get, set):Size<Int>;

	// members
	private var _gl:GLRenderContext = null;
	private var _listeners:Array<Xt3dGLViewListener> = new Array<Xt3dGLViewListener>();
	private var _width:Int;
	private var _height:Int;
	private var _lastUpdateTime:Int = 0;

	public static function create(width:Int = 1024, height:Int = 768):OpenFlGLView {
		var object = new OpenFlGLView();

		if (object != null && !(object.initView(width, height))) {
			object = null;
		}

		return object;
	}

	public function initView(width:Int = 1024, height:Int = 768):Bool {
		this._width = width;
		this._height = height;


		// Set first render callback to be an initialisation call
		super.render = this.onApplicationReady;

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

	public function get_displayRect():Rectangle {
		return new Rectangle(0, 0, this._width, this._height);
	}

	public function set_size(size:Size<Int>):Size<Int> {
		this.onWindowResize(size.width, size.height);
		return size;
	}

	public function get_size():Size<Int> {
		return Size.createIntSize(this._width, this._height);
	}


	/* --------- Implementation --------- */


	private inline function onInit():Void {
		// Initialise width and height
		this._width = stage.stageWidth;
		this._height = stage.stageHeight;

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


	private inline function onApplicationReady(rect:Rectangle):Void {
		// Get render context
		var renderer:AbstractRenderer = @:privateAccess (stage.__renderer);
		try {
			var glRenderer = cast(renderer, GLRenderer);

			this._gl = glRenderer.gl;

			// If we have a context then initialise all listeners
			this.onInit();

		} catch (exception:Error) {
			throw new KFException("InvalidGraphicsContext", "xTalk3d cannot run without OpenGL");

		}

		// Perform a first render
		this.performRender(rect);

		// Set real render callback
		super.render = this.performRender;
	}

	private inline function performRender(rect:Rectangle):Void {
		this.onWindowResize(Std.int(rect.width), Std.int(rect.height));

		var now = Lib.getTimer();
		var deltaTimeMs = 0.001 * (now - this._lastUpdateTime);
		this._lastUpdateTime = now;

		// Notify all listeners of update
		this.onUpdate(deltaTimeMs);

		// Notify all listeners
		this.onRender();
	}

	inline public function onWindowResize(width:Int, height:Int):Void {
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

}
