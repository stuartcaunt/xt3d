package xt3d.core;

import xt3d.node.Camera;
import lime.math.Vector2;
import xt3d.textures.RenderTexture;
import xt3d.utils.geometry.Size;
import xt3d.events.GestureDispatcher;
import xt3d.events.MouseDispatcher;
import xt3d.events.TouchDispatcher;
import xt3d.utils.general.FPSCalculator;
import lime.app.Application;
import lime.math.Rectangle;
import xt3d.gl.view.Xt3dGLViewEvent;
import xt3d.gl.view.Xt3dGLViewListener;
import xt3d.gl.view.Xt3dGLView;
import xt3d.gl.XTGL;
import xt3d.core.Configuration;
import xt3d.utils.XT;
import xt3d.core.Scheduler;
import xt3d.textures.TextureCache;
import xt3d.view.View;
import xt3d.core.Renderer;
import xt3d.utils.color.Color;

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
	public var timeFactor(get, set):Float;
	public var touchDispatcher(get, null):TouchDispatcher;
	public var mouseDispatcher(get, null):MouseDispatcher;
	public var gestureDispatcher(get, null):GestureDispatcher;
	public var displaySize(get, null):Size<Int>;
	public var fpsEnabled(get, set):Bool;
	public var activeCamera(get, null):Camera;

	// members
	private static var _current:Director = null;
	private var _glView:Xt3dGLView;
	private var _backgroundColor:Color = new Color();
	private var _renderer:Renderer;
	private var _textureCache:TextureCache;
	private var _views:Array<View> = new Array<View>();
	private var _scheduler:Scheduler;
	private var _configuration:Configuration;

	private var _deltaTime:Float = 0.0;
	private var _timeFactor:Float = 1.0;
	private var _globalTime = 0.0;
	private var _paused:Bool = false;
	private var _nextDeltaTimeZero = true;

	private var _frameRate:Float = 60.0;
	private var _oldFrameRate:Float;
	private var _fpsCalculator:FPSCalculator;
	private var _fpsEnabled:Bool;

	private var _isReady:Bool = false;
	private var _onReadyListeners = new Array<Void->Void>();

	private var _touchDispatcher:TouchDispatcher = null;
	private var _mouseDispatcher:MouseDispatcher = null;
	private var _gestureDispatcher:GestureDispatcher = null;

	private var _activeCamera:Camera = null;

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

		// Create gesture dispatcher
		this._gestureDispatcher = GestureDispatcher.create(this);

		// Create touch dispatcher
		this._touchDispatcher = TouchDispatcher.create(this._gestureDispatcher);

		// Create mouse dispatcher
		this._mouseDispatcher = MouseDispatcher.create(this._gestureDispatcher);

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

	public inline function get_paused():Bool {
		return this._paused;
	}

	public inline function set_timeFactor(value:Float) {
		return this._timeFactor = value;
	}

	public inline function get_timeFactor():Float {
		return this._timeFactor;
	}

	public inline function get_touchDispatcher():TouchDispatcher {
		return this._touchDispatcher;
	}

	public inline function get_mouseDispatcher():MouseDispatcher {
		return this._mouseDispatcher;
	}

	public inline function get_gestureDispatcher():GestureDispatcher {
		return this._gestureDispatcher;
	}

	public inline function get_displaySize():Size<Int> {
		if (this._glView != null) {
			return this._glView.size;
		}
		return Size.createIntSize(0, 0);
	}

	public inline function set_fpsEnabled(value:Bool) {
		return this._fpsEnabled = value;
	}

	public inline function get_fpsEnabled():Bool {
		return this._fpsEnabled;
	}

	public inline function get_activeCamera():Camera {
		return this._activeCamera;
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
		this._renderer = Renderer.create(_glView.gl);

		// Iterate over all views
		for (view in _views) {
			// Update the display size in the views (does nothing if not changed)
			view.setDisplaySize(_glView.size);
		}

		// Create new texture cache
		this._textureCache = TextureCache.create();

		// Initialise frame rate
		this.setFrameRate(60.0);

		// Create fps calculator
		this._fpsCalculator = FPSCalculator.create();

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
			// Iterate over all views
			for (view in _views) {
				// Update the display size in the views (does nothing if not changed)
				view.setDisplaySize(_glView.size);
			}

			// send resize event
			this.emit("resize");
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

			glView.touchDelegate = this._touchDispatcher;
			glView.mouseDelegate = this._mouseDispatcher;
		}
	}

	public inline function addView(view:View):Void {
		_views.push(view);

		// Update the display rect (does nothing if not changed)
		view.setDisplaySize(_glView.size);

		// activate view
		view.onEnter();
	}

	public inline function addViewAbove(view:View, viewBelow:View = null):Void {
		if (viewBelow == null) {
			this.addView(view);

		} else {
			var index = this._views.indexOf(viewBelow);
			if (index >= 0) {
				// Insert above the given viewBelow
				_views.insert(index + 1, view);

				// Update the display rect (does nothing if not changed)
				view.setDisplaySize(_glView.size);

				// activate view
				view.onEnter();

			} else {
				XT.Warn("Could not find view to move during addViewAbove");
				this.addView(view);
			}
		}
	}

	public inline function addViewBelow(view:View, viewAbove:View = null):Void {
		var index = 0;
		if (viewAbove != null) {
			var index = this._views.indexOf(viewAbove);

			if (index < 0) {
				XT.Warn("Could not find view to move during addViewBelow");
				index = 0;
			}
		}
		// Insert below the given viewBelow (ie same index)
		_views.insert(index, view);

		// Update the display rect (does nothing if not changed)
		view.setDisplaySize(_glView.size);

		// activate view
		view.onEnter();
	}

	public inline function removeView(view:View):Void {
		var viewIndex = this._views.indexOf(view);
		if (viewIndex >= 0) {
			_views.splice(viewIndex, 1);

			// deactivate view
			view.onExit();
		}
	}

	public function getViewForGestureScreenPosition(x:Float, y:Float):View {
		// Reverse iterate over views (top first)
		var i = this._views.length;
		while (--i >= 0) {
			var view = this._views[i];
			if (view.containsScreenPosition(x, y) && view.gesturesEnabled) {
				return view;
			}
		}

		return null;
	}

	public inline function pause():Void {
		if (!this._paused) {
			this._paused = true;

			// Use slower animation interval to conserve energy on mobile devices
			this._oldFrameRate = this._frameRate;
			this.setFrameRate(4.0);
		}
	}

	public inline function resume():Void {
		if (this._paused) {
			this._paused = false;

			// Set the animation interval
			this.setFrameRate(this._oldFrameRate);
		}
	}

	private function updateDeltaTime(dt:Float):Void {
		//XT.Log("fps = " + 1000.0 / dt);

		if (this._isReady) {

			// Calculate dt
			this.calculateDeltaTime(dt);

			// If not paused then update animations
			if (!this._paused) {
				this._scheduler.update(this._timeFactor * this._deltaTime);
			}

			// Update fps calculator
			if (this._fpsEnabled) {
				this._fpsCalculator.update(dt);
			}
		}
	}

	private function renderLoop():Void {
		if (this._isReady) {
			// Make current
			this.makeCurrent();

			// send pre-render event (custom updates before rendering)
			this.emit("pre_render");

			// Perform render
			this.render(this._backgroundColor);

			// send pre-render event (custom updates before rendering)
			this.emit("post_render");
		}
	}

	public function render(backgroundColor:Color, renderTarget:RenderTexture = null, overrider:RendererOverrider = null) {

		// Reset render target
		_renderer.setRenderTarget(renderTarget);

		// Set the viewport
		var size = _glView.size;
		if (renderTarget != null) {
			size = renderTarget.contentSize;
		}
		var viewport:Rectangle = new Rectangle(0, 0, size.width, size.height);
		_renderer.setViewport(viewport);

		// Disable scissor test
		_renderer.disableScissor();

		// Clear context
		_renderer.clear(backgroundColor);

		// Iterate over all views
		for (view in _views) {
			this._activeCamera = view.camera;

			// Update view
			view.updateView(overrider);

			// Clear and render view
			view.clearAndRender(overrider);
		}


		// Display fps
		if (this._fpsEnabled) {
			// Set the fullscreen viewport
			_renderer.setViewport(viewport);

			// Disable scissor test
			_renderer.disableScissor();

			// render fps
			this._fpsCalculator.render();
		}
	}

	private function calculateDeltaTime(dt:Float = 0.0):Void {

		if (this._nextDeltaTimeZero) {
			this._deltaTime = 0.0;
			this._nextDeltaTimeZero = false;

		} else {
			this._deltaTime = dt;
			this._deltaTime = Math.max(0.0, this._deltaTime);
		}

		// Handle jumps
		if (this._deltaTime > 0.2) {
			this._deltaTime = 1.0 / this._frameRate;
		}

		this._globalTime += this._deltaTime;
	}

	private function setFrameRate(frameRate:Float):Void {
		this._frameRate = frameRate;

		// Set the framerate
		Application.current.frameRate = this._frameRate;
	}

}