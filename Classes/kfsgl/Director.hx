package kfsgl;

import kfsgl.textures.TextureCache;
import kfsgl.core.EventEmitter;
import kfsgl.gl.shaders.UniformLib;
import kfsgl.core.View;
import kfsgl.core.Renderer;
import kfsgl.utils.Color;

import openfl.display.OpenGLView;
import openfl.geom.Rectangle;

class Director extends EventEmitter {

	// properties
	public static var current(get, null):Director;
	public var renderer(get, null):Renderer;
	public var openGLView(get_openGLView, set_openGLView):OpenGLView;
	public var backgroundColor(get_backgroundColor, set_backgroundColor):Color;
	public var textureCache(get, null):TextureCache;

	// members
	private static var _current:Director = null;
	private var _openGLView:OpenGLView;
	private var _backgroundColor:Color = new Color();
	private var _renderer:Renderer;
	private var _textureCache:TextureCache;
	private var _views:Array<View> = new Array<View>();

	private var _globalTime = 0.0;

	public static function create(openGLView:OpenGLView):Director {
		var object = new Director();

		if (object != null && !(object.init(openGLView))) {
			object = null;
		}

		return object;
	}

	public function init(openGLView:OpenGLView):Bool {
		this.setOpenglView(openGLView);

		this.makeCurrent();

		return true;
	}

	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public inline function get_textureCache():TextureCache {
		return this._textureCache;
	}

	public static inline function get_current():Director {
		return _current;
	}

	public inline function get_renderer():Renderer {
		return this._renderer;
	}

	public inline function get_openGLView():OpenGLView {
		return this._openGLView;
	}

	public inline function set_openGLView(openGLView) {
		this.setOpenglView(openGLView);
		return this._openGLView;
	}

	public inline function get_backgroundColor():Color {
		return this._backgroundColor;
	}

	public inline function set_backgroundColor(backgroundColor) {
		return this._backgroundColor = backgroundColor;
	}

	/* --------- Implementation --------- */

	public function makeCurrent():Void {
		_current = this;
	}

	public function setOpenglView(openGLView:OpenGLView):Void {
		this._openGLView = openGLView;

		// Create new renderer for opengl view
		this._renderer = Renderer.create();

		// Create new texture cache
		if (this._textureCache != null) {
			this._textureCache.removeAllTextures();
		}
		this._textureCache = TextureCache.create(this._renderer.textureManager);

		_openGLView.render = renderLoop;
	}

	public inline function addView(view:View):Void {
		_views.push(view);
	}

	private function renderLoop(displayRect:Rectangle):Void {

		//KF.Log("render");

		// TODO Calculate time step
		var dt = 1.0 / 60.0;
		_globalTime += dt;
		UniformLib.instance().uniform("time").value = _globalTime;

		// send pre-render event (custom updates before rendering)
		this.emit("pre_render");

		// Reset render target
		_renderer.setRenderTarget(null);

		// Set viewport with full rectangle
		_renderer.setViewport(displayRect);

		// Clear context
		_renderer.clear(backgroundColor);

		// Iterate over all views
		for (view in _views) {
			// Update the display rect (does nothing if not changed)
			view.setDisplayRect(displayRect);

			// Render view
			view.render(_renderer);
		}

		// send pre-render event (custom updates before rendering)
		this.emit("post_render");

	}

}