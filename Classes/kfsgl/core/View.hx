package kfsgl.core;

import openfl.geom.Vector3D;
import openfl.geom.Vector3D;
import kfsgl.utils.errors.KFException;
import kfsgl.node.Node3D;
import kfsgl.node.Node3D;
import kfsgl.utils.Color;
import kfsgl.textures.RenderTexture;
import kfsgl.utils.Size;
import kfsgl.node.Scene;
import openfl.geom.Rectangle;
import kfsgl.utils.Color;

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

	public static function create():View {
		var object = new View();

		if (object != null && !(object.init())) {
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

	public function init():Bool {
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
		this.scene = Scene.create();

		// Create camera (by default already with perspective projection)
		this.camera = Camera.create(this);

		// Add camera to scene
		this.scene.addChild(this.camera);

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
		return this._scene = value;
	}

	public inline function get_camera():Camera {
		return _camera;
	}

	public inline function set_camera(value:Camera) {
		return this._camera = value;
	}


	/* --------- Implementation --------- */

	public function render(renderer:Renderer = null):Void {
		if (renderer == null) {
			renderer = Director.current.renderer;
		}

		// Clear view
		renderer.clear(viewport, backgroundColor);

		// Render scene with camera
		renderer.render(this.scene, this.camera);
	}

	public function renderNodeToTexture(node:Node3D, renderTexture:RenderTexture, clearColor:Color = null, renderer:Renderer = null):Void {
		if (this.scene == null) {
			throw new KFException("CannotRenderWithNullScene", "Cannot render to texture with a null Scene for the View");

		}

		// Take temporary ownership of the node
		this.scene.borrowChild(node);

		// Make of copy of original position
		var originalPosition = node.position;

		// Set node matrix to identity matrix
		node.position = new Vector3D();

		// Render node and children to texture
		this.renderToTexture(renderTexture, 0, renderer);

		// Replace node in original heirarchy
		this.scene.returnBorrowedChild(node);

		// Put back origin matrix
		node.position = originalPosition;
	}

	public function renderToTexture(renderTexture:RenderTexture, clearFlags:Int = 0, renderer:Renderer = null):Void {

		if (renderer == null) {
			renderer = Director.current.renderer;
		}

		// Bind to render texture frame buffer
		renderTexture.begin();

		// Clear and initialise render to texture
		//if (clearFlags == 0) {
			renderer.clear(viewport, backgroundColor);
		//}

		// Render scene with camera
		renderer.render(this.scene, this.camera);

		// Terminate rendering to texture
		renderTexture.end();
	}



	public inline function setDisplayRect(displayRect:Rectangle) {
		this.setViewport(displayRect);
	}

	public function setViewport(viewport:Rectangle) {
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
}