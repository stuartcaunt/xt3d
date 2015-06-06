package kfsgl;

import openfl.Lib;
import kfsgl.utils.KF;
import kfsgl.core.Scheduler;
import kfsgl.textures.TextureCache;
import kfsgl.core.EventEmitter;
import kfsgl.core.View;
import kfsgl.core.Renderer;
import kfsgl.utils.Color;

import openfl.display.OpenGLView;
import openfl.geom.Rectangle;

class Director extends EventEmitter {

	// properties
	public static var current(get, null):Director;
	public var renderer(get, null):Renderer;
	public var scheduler(get, null):Scheduler;
	public var openGLView(get_openGLView, set_openGLView):OpenGLView;
	public var backgroundColor(get_backgroundColor, set_backgroundColor):Color;
	public var textureCache(get, null):TextureCache;
	public var paused(get, null):Bool;

	// members
	private static var _current:Director = null;
	private var _openGLView:OpenGLView;
	private var _backgroundColor:Color = new Color();
	private var _renderer:Renderer;
	private var _textureCache:TextureCache;
	private var _views:Array<View> = new Array<View>();
	private var _scheduler:Scheduler;

	private var _lastUpdateTime:Int = 0;
	private var _deltaTime:Float = 0.0;
	private var _globalTime = 0.0;
	private var _paused:Bool = false;
	private var _nextDeltaTimeZero = true;

	// TODO handle animation interval programatically
	private var _animationInterval:Float = 1.0 / 60.0;
	private var _oldAnimationInterval:Float;

	public static function create(openGLView:OpenGLView):Director {
		var object = new Director();

		if (object != null && !(object.init(openGLView))) {
			object = null;
		}

		return object;
	}

	public function init(openGLView:OpenGLView):Bool {

		// Make director current
		this.makeCurrent();

		// Create scheduler
		this._scheduler = Scheduler.create();

		// Set openglview
		this.setOpenglView(openGLView);

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

	public inline function get_scheduler():Scheduler {
		return this._scheduler;
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

	public function get_paused():Bool {
		return this._paused;
	}


	/* --------- Implementation --------- */

	public inline function makeCurrent():Void {
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
		this._textureCache = TextureCache.create();

		_openGLView.render = renderLoop;
	}

	public inline function addView(view:View):Void {
		_views.push(view);
	}

	public inline function pause():Void {
		if (!this._paused) {
			this._paused = true;

			// Use slower animation interval to conserve energy on mobile devices
			this._oldAnimationInterval = this._animationInterval;
			this.setAnimationInterval(1.0 / 4.0);
		}
	}

	public inline function resume():Void {
		if (this._paused) {
			this._paused = false;

			// Set the animation interval
			this.setAnimationInterval(this._oldAnimationInterval);
		}
	}

	private function renderLoop(displayRect:Rectangle):Void {

		// Make current
		this.makeCurrent();

		// Calculate dt
		this.calculateDeltaTime();

		// If not paused then update animations
		if (!this._paused) {
			this._scheduler.update(this._deltaTime);
		}

		// Render (always needed even if paused to perform screen refreshes

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

	private function calculateDeltaTime():Void {
		var now = Lib.getTimer();

		if (this._nextDeltaTimeZero) {
			this._deltaTime = 0.0;
			this._nextDeltaTimeZero = false;

		} else {
			this._deltaTime = 0.001 * (now - this._lastUpdateTime);
			this._deltaTime = Math.max(0.0, this._deltaTime);
		}

		// Handle jumps
		if (this._deltaTime > 0.2) {
			this._deltaTime = this._animationInterval;
		}

		this._globalTime += this._deltaTime;

		this._lastUpdateTime = now;
	}

	private function setAnimationInterval(animationInterval:Float):Void {
		this._animationInterval = animationInterval;

		// TODO handle animation interval
	}

}