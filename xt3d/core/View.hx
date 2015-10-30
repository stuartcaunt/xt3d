package xt3d.core;

import xt3d.utils.XT;
import lime.math.Rectangle;
import lime.graphics.opengl.GL;
import lime.math.Vector4;
import xt3d.utils.errors.XTException;
import xt3d.node.Node3D;
import xt3d.node.Camera;
import xt3d.utils.color.Color;
import xt3d.textures.RenderTexture;
import xt3d.utils.geometry.Size;
import xt3d.node.Scene;

class View extends EventEmitter {

	// Viewport descriptor : {top right bottom left}
	// can give percentages of full frame or pixel offsets
	// Negative values are considered to be from opposite side
	// eg {2px -202px -102px 2px} creates a rectangle of ((2, 2), (200, 100))

	// properties
	public var displayRect(get, set):Rectangle;
	public var viewport(get, set):Rectangle;
	public var viewportInPixels(get, set):Rectangle;
	public var backgroundColor(get, set):Color;
	public var scene(get, set):Scene;
	public var camera(get, set):Camera;

	// members
	public var _displayRect:Rectangle;
	public var _viewport:Rectangle;
	public var _viewportInPixels:Rectangle;
	public var _backgroundColor:Color = new Color();
	private var _scene:Scene;
	private var _camera:Camera;

	private var _contentScaleFactor = 1.0;

	private var _running:Bool = false;

	public static function create():View {
		var object = new View();

		if (object != null && !(object.initView())) {
			object = null;
		}

		return object;
	}

	public static function createWithSize(size:Size<Int>):View {
		var object = new View();

		if (object != null && !(object.initWithSize(size))) {
			object = null;
		}

		return object;
	}

	public static function createBasic3D(size:Size<Int> = null):View {
		var object = new View();

		if (object != null && !(object.initBasic3D(size))) {
			object = null;
		}

		return object;
	}

	public function initView():Bool {
		// Set default viewport
		setViewport(new Rectangle(0, 0, 500, 600));

		return true;
	}

	public function initWithSize(size:Size<Int>):Bool {
		// Set default viewport
		setViewport(new Rectangle(0, 0, size.width, size.height));

		return true;
	}

	public function initBasic3D(size:Size<Int> = null):Bool {
		if (size == null) {
			size = Size.createIntSize(500, 600);
		}

		// Set default viewport
		setViewport(new Rectangle(0, 0, size.width, size.height));

		// Create scene
		this._scene = Scene.create();

		// Create camera (by default already with perspective projection)
		this._camera = Camera.create(this);

		// Add camera to scene
		this._scene.addChild(this._camera);

		return true;
	}

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */


	public inline function get_displayRect():Rectangle {
		return _displayRect;
	}

	public inline function set_displayRect(value:Rectangle) {
		this.setDisplayRect(value);
		return this._displayRect;
	}

	public inline function get_viewport():Rectangle {
		return _viewport;
	}

	public inline function set_viewport(value:Rectangle) {
		this.setViewport(value);
		return this._viewport;
	}

	public inline function get_viewportInPixels():Rectangle {
		return _viewportInPixels;
	}

	public inline function set_viewportInPixels(value:Rectangle) {
		this.setViewportInPixels(value);
		return this._viewportInPixels;
	}

	public inline function get_backgroundColor():Color {
		return _backgroundColor;
	}

	public inline function set_backgroundColor(value:Color) {
		return this._backgroundColor = value;
	}

	public inline function get_scene():Scene {
		return _scene;
	}

	public inline function set_scene(value:Scene) {
		this.setScene(value);
		return this._scene;
	}

	public inline function get_camera():Camera {
		return _camera;
	}

	public inline function set_camera(value:Camera) {
		return this._camera = value;
	}


	/* --------- Implementation --------- */

	public function setScene(scene:Scene):Void {
		if (this._camera != null && this._camera.parent == this._scene) {
			this._scene.removeChild(this._camera);

			this._scene = scene;
		}

	}

	override public function scheduleUpdate(ignored:Bool = false):Void {
		super.scheduleUpdate(!this._running);
	}

	public function onEnter():Void {
		if (this._scene != null) {
			this._scene.onEnter();
		}

		// Resume scheduled callback if set
		this.resumeScheduler();

		this._running = true;
	}

	public function onExit():Void {
		this._running = false;

		if (this._scene != null) {
			this._scene.onExit();
		}

		// Pause any scheduled callback
		this.pauseScheduler();
	}


	public function render(rendererOverrider:RendererOverrider = null):Void {
		var renderer = Director.current.renderer;

		// Set viewport with full rectangle
		renderer.setViewport(viewport);

		// Clear view
		renderer.clear(backgroundColor);

		// Render scene with camera
		renderer.render(this.scene, this.camera, rendererOverrider);
	}

	public function renderNodeToTexture(node:Node3D, renderTexture:RenderTexture, clear:Bool = true, clearColor:Color = null, rendererOverrider:RendererOverrider = null):Void {
		if (this.scene == null) {
			throw new XTException("CannotRenderWithNullScene", "Cannot render to texture with a null Scene for the View");

		}

		// Take temporary ownership of the node
		this.scene.borrowChild(node);

		// Make of copy of original position
		var originalPosition = node.position;

		// Set node matrix to identity matrix
		node.position = new Vector4();

		// Render node and children to texture
		this.renderToTexture(renderTexture, clear, clearColor, rendererOverrider);

		// Replace node in original heirarchy
		this.scene.returnBorrowedChild(node);

		// Put back origin matrix
		node.position = originalPosition;
	}

	public function renderToTexture(renderTexture:RenderTexture, clear:Bool = true, clearColor:Color = null, rendererOverrider:RendererOverrider = null):Void {

		var renderer = Director.current.renderer;

		// Bind to render texture frame buffer
		renderer.setRenderTarget(renderTexture);

		// Set viewport for render texture
		renderer.setViewport(viewport);

		// Clear and initialise render to texture
		if (clear) {
			var color = (clearColor == null) ? this._backgroundColor : clearColor;
			renderer.clear(color, renderTexture.clearFlags);
		}

		// Render scene with camera
		renderer.render(this.scene, this.camera, rendererOverrider);
	}



	public inline function setDisplayRect(displayRect:Rectangle) {
		this.setViewport(displayRect);
	}

	public function setViewport(viewport:Rectangle) {
		//XT.Log("Setting viewport to " + viewport.width + " x " + viewport.height);
		if (this._viewport == null || !viewport.equals(this._viewport)) {
			// Update displayrect - do calculation if needed.
			// Just copy for now
			this._viewport = viewport;
			this._displayRect = viewport;

			this._viewportInPixels = new Rectangle(viewport.x * this._contentScaleFactor, viewport.y * this._contentScaleFactor, viewport.width * this._contentScaleFactor, viewport.height * this._contentScaleFactor);

			// Emit event
			this.emit("viewport_changed");
		}
	}

	public function setViewportInPixels(viewportInPixels:Rectangle) {
		if (this._viewportInPixels == null || !viewportInPixels.equals(this._viewportInPixels)) {
			// Update displayrect - do calculation if needed.
			// Just copy for now
			this._viewportInPixels = viewportInPixels;

			var viewport = new Rectangle(
				viewport.x / this._contentScaleFactor,
				viewport.y / this._contentScaleFactor,
				viewport.width / this._contentScaleFactor,
				viewport.height / this._contentScaleFactor);

			this._viewport = viewport;
			this._displayRect = viewport;

			// Emit event
			this.emit("viewport_changed");
		}
	}


	public override function update(dt:Float):Void {
		// Method to be overridden to get automatic updates every frame if scheduleUpdate has been called
	}

}