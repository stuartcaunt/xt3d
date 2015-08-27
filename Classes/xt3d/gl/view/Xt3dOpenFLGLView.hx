package xt3d.gl.view;

import openfl.display.OpenGLView;
import xt3d.utils.XT;
import lime.math.Rectangle;
import xt3d.utils.Size;
import openfl.errors.Error;
import openfl.Lib;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl._internal.renderer.AbstractRenderer;
import xt3d.utils.errors.XTException;
import lime.graphics.GLRenderContext;
import openfl.events.Event;
import openfl.display.Sprite;

class Xt3dOpenFLGLView extends OpenGLView implements Xt3dGLView {

	// properties
	public var gl(get, null):GLRenderContext;
	public var size(get, null):Size<Int>;

	// members
	private var _gl:GLRenderContext = null;
	private var _listeners:Array<Xt3dGLViewListener> = new Array<Xt3dGLViewListener>();
	private var _width:Int = 0;
	private var _height:Int = 0;
	private var _lastUpdateTime:Int = 0;

	public static function create():Xt3dOpenFLGLView {
		var object = new Xt3dOpenFLGLView();

		if (object != null && !(object.initView())) {
			object = null;
		}

		return object;
	}

	public function initView():Bool {

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
			throw new XTException("InvalidGraphicsContext", "xTalk3d cannot run without OpenGL");

		}

		// Perform a first render
		this.performRender(rect);

		// Set real render callback
		super.render = this.performRender;
	}

	private inline function performRender(rect:Rectangle):Void {
		if (rect.width != this._width || rect.height != this._height) {
			this.onWindowResize(Std.int(rect.width), Std.int(rect.height));
		}

		// Calculate time
		var now = Lib.getTimer();
		if (this._lastUpdateTime == 0) {
			this._lastUpdateTime = now;
		}
		var deltaTimeMs = (now - this._lastUpdateTime);
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
