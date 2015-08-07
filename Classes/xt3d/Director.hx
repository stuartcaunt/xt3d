package xt3d;

import xt3d.gl.view.Xt3dGLViewEvent;
import xt3d.gl.view.Xt3dGLViewListener;
import xt3d.gl.view.Xt3dGLView;
import xt3d.gl.XTGL;
import xt3d.core.Configuration;
import openfl.Lib;
import xt3d.utils.XT;
import xt3d.core.Scheduler;
import xt3d.textures.TextureCache;
import xt3d.core.EventEmitter;
import xt3d.core.View;
import xt3d.core.Renderer;
import xt3d.utils.Color;

import openfl.geom.Rectangle;

class Director extends EventEmitter implements Xt3dGLViewListener {

	// properties
	public static var current(get, null):Director;
	public var renderer(get, null):Renderer;
	public var scheduler(get, null):Scheduler;
	public var configuration(get, null):Configuration;
	public var glView(get, set):Xt3dGLView;
	public var backgroundColor(get, set):Color;
	public var textureCache(get, null):TextureCache;
	public var paused(get, null):Bool;

	// members
	private static var _current:Director = null;
	private var _glView:Xt3dGLView;
	private var _backgroundColor:Color = new Color();
	private var _renderer:Renderer;
	private var _textureCache:TextureCache;
	private var _views:Array<View> = new Array<View>();
	private var _scheduler:Scheduler;
	private var _configuration:Configuration;

//	private var _lastUpdateTime:Int = 0;
	private var _deltaTime:Float = 0.0;
	private var _globalTime = 0.0;
	private var _paused:Bool = false;
	private var _nextDeltaTimeZero = true;

	// TODO handle animation interval programatically
	private var _animationInterval:Float = 1.0 / 60.0;
	private var _oldAnimationInterval:Float;

	private var _isReady:Bool = false;
	private var _onReadyListeners = new Array<Void->Void>();

	public static function create(options:Map<String, String> = null):Director {
		var object = new Director();

		if (object != null && !(object.init(options))) {
			object = null;
		}

		return object;
	}

	public function init(options:Map<String, String> = null):Bool {

		this._configuration = Configuration.create(options);

		// Make director current
		this.makeCurrent();

		// Create scheduler
		this._scheduler = Scheduler.create();

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

	public inline function get_configuration():Configuration {
		return this._configuration;
	}

	public inline function get_glView():Xt3dGLView {
		return this._glView;
	}

	public inline function set_glView(glView:Xt3dGLView) {
		this.setGLView(glView);
		return this._glView;
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


	/* --------- Xt3dViewListener Implementation --------- */

	public inline function onContextInitialised(view:Xt3dGLView):Void {
		// Remove any old renderers
		this._renderer = null;

		// Clear and remove old texture cache
		if (this._textureCache != null) {
			this._textureCache.removeAllTextures();
			this._textureCache = null;
		}

		// Create new renderer for opengl view
		this._renderer = Renderer.create(glView.gl);

		// Set viewport with full rectangle
		var displayRect = glView.displayRect;
		_renderer.setViewport(displayRect);

		// Iterate over all views
		for (view in _views) {
			// Update the display rect (does nothing if not changed)
			view.setDisplayRect(displayRect);
		}

			// Create new texture cache
		this._textureCache = TextureCache.create();

		this._isReady = true;
		this.notifyReadyListeners();
	}


	public inline function onUpdate(view:Xt3dGLView, dt:Float):Void {
		this.updateDeltaTime(dt);
	}

	public inline function onRender(view:Xt3dGLView):Void {
		this.renderLoop();
	}

	public inline function onEvent(view:Xt3dGLView, event:String):Void {
		if (event == Xt3dGLViewEvent.RESIZE) {
			// Set viewport with full rectangle
			var displayRect = this._glView.displayRect;
			_renderer.setViewport(displayRect);

			// Iterate over all views
			for (view in _views) {
				// Update the display rect (does nothing if not changed)
				view.setDisplayRect(displayRect);
			}
		}
	}

	/* --------- Implementation --------- */

	public inline function onReady(listener:Void->Void):Void {
		if (this._isReady) {
			listener();

		} else {
			this._onReadyListeners.push(listener);
		}
	}

	public function notifyReadyListeners():Void {
		for (listener in this._onReadyListeners) {
			listener();
		}

		// Remove all listeners
		this._onReadyListeners.splice(0, this._onReadyListeners.length);
	}

	public inline function makeCurrent():Void {
		_current = this;
	}

	public function setGLView(glView:Xt3dGLView):Void {
		if (this._glView != null) {
			this._glView.removeListener(this);
			this._glView = null;
		}

		this._glView = glView;
		this._isReady = false ;

		if (glView != null) {
			// Add listener to view
			glView.addListener(this);
		}
	}

	public inline function addView(view:View):Void {
		_views.push(view);

		// Update the display rect (does nothing if not changed)
		view.setDisplayRect(this._glView.displayRect);
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

	private function updateDeltaTime(dt:Float):Void {
		//XT.Log("fps = " + 1000.0 / dt);

		// Calculate dt
		this.calculateDeltaTime(dt);

		// If not paused then update animations
		if (!this._paused) {
			this._scheduler.update(this._deltaTime);
		}
	}

	private function renderLoop():Void {

		// Make current
		this.makeCurrent();

		// Render (always needed even if paused to perform screen refreshes

		// send pre-render event (custom updates before rendering)
		this.emit("pre_render");

		// Reset render target
		_renderer.setRenderTarget(null);

		// Clear context
		_renderer.clear(backgroundColor);

		// Iterate over all views
		for (view in _views) {
			// Render view
			view.render(_renderer);
		}

		// send pre-render event (custom updates before rendering)
		this.emit("post_render");

	}

	private function calculateDeltaTime(dt:Float = 0.0):Void {
		//var now = Lib.getTimer();

		if (this._nextDeltaTimeZero) {
			this._deltaTime = 0.0;
			this._nextDeltaTimeZero = false;

		} else {
			//this._deltaTime = 0.001 * (now - this._lastUpdateTime);
			this._deltaTime = dt;
			this._deltaTime = Math.max(0.0, this._deltaTime);
		}

		// Handle jumps
		if (this._deltaTime > 0.2) {
			this._deltaTime = this._animationInterval;
		}

		this._globalTime += this._deltaTime;

//		this._lastUpdateTime = now;
	}

	private function setAnimationInterval(animationInterval:Float):Void {
		this._animationInterval = animationInterval;

		// TODO handle animation interval
	}

}