package xt3d.view;

import xt3d.utils.XT;
import lime.math.Rectangle;
import xt3d.core.Director;
import xt3d.core.EventEmitter;
import xt3d.core.RendererOverrider;
import xt3d.math.Vector4;
import xt3d.utils.errors.XTException;
import xt3d.node.Node3D;
import xt3d.node.Camera;
import xt3d.utils.color.Color;
import xt3d.textures.RenderTexture;
import xt3d.utils.geometry.Size;
import xt3d.node.Scene;

class View extends EventEmitter {

	// properties
	public var viewport(get, null):Rectangle;
	public var viewportInPixels(get, null):Rectangle;
	public var displaySize(get, set):Size<Int>; // In points
	public var horizontalConstraint(get, set):HorizontalConstraint;
	public var verticalConstraint(get, set):VerticalConstraint;
	public var backgroundColor(get, set):Color;
	public var scene(get, set):Scene;
	public var camera(get, set):Camera;

	// members
	private var _viewport:Rectangle;
	private var _viewportInPixels:Rectangle;
	private var _displaySize:Size<Int>; // In points
	private var _horizontalConstraint:HorizontalConstraint = HorizontalConstraint.create();
	private var _verticalConstraint:VerticalConstraint = VerticalConstraint.create();
	private var _scissorEnabled:Bool = false;


	private var _backgroundColor:Color = null;
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

	public static function createBasic3D():View {
		var object = new View();

		if (object != null && !(object.initBasic3D())) {
			object = null;
		}

		return object;
	}

	public function initView():Bool {
		// Get current director display size
		this.setDisplaySize(Director.current.displaySize);

		return true;
	}

	public function initBasic3D():Bool {
		// Get current director display size
		this.setDisplaySize(Director.current.displaySize);

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


	public inline function get_viewport():Rectangle {
		return this._viewport;
	}

	public inline function get_viewportInPixels():Rectangle {
		return this._viewportInPixels;
	}

	function get_displaySize():Size<Int> {
		return this._displaySize;
	}

	function set_displaySize(value:Size<Int>) {
		this.setDisplaySize(value);
		return this._displaySize;
	}

	function get_horizontalConstraint():HorizontalConstraint {
		return this._horizontalConstraint;
	}

	function set_horizontalConstraint(value:HorizontalConstraint) {
		this.setHorizontalConstraint(value);
		return this._horizontalConstraint;
	}

	function get_verticalConstraint():VerticalConstraint {
		return this._verticalConstraint;
	}

	function set_verticalConstraint(value:VerticalConstraint) {
		this.setVerticalConstraint(value);
		return this._verticalConstraint;
	}

	public inline function get_backgroundColor():Color {
		if (this._backgroundColor == null) {
			this._backgroundColor = Director.current.backgroundColor;
		}

		return this._backgroundColor;
	}

	public inline function set_backgroundColor(value:Color) {
		return this._backgroundColor = value;
	}

	public inline function get_scene():Scene {
		return this._scene;
	}

	public inline function set_scene(value:Scene) {
		this.setScene(value);
		return this._scene;
	}

	public inline function get_camera():Camera {
		return this._camera;
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
		renderer.setViewport(this._viewport);

		// Set scissor
		if (this._scissorEnabled) {
			renderer.enableScissor(this._viewport);
		} else {
			renderer.disableScissor();
		}

		// Clear view
		renderer.clear(_backgroundColor);

		// Render scene with camera
		renderer.render(this._scene, this._camera, rendererOverrider);
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

		// Set scissor
		if (this._scissorEnabled) {
			renderer.enableScissor(viewport);
		} else {
			renderer.disableScissor();
		}

		// Clear and initialise render to texture
		if (clear) {
			var color = (clearColor == null) ? _backgroundColor : clearColor;
			renderer.clear(color, renderTexture.clearFlags);
		}

		// Render scene with camera
		renderer.render(this._scene, this._camera, rendererOverrider);
	}

	public function setDisplaySize(displaySize:Size<Int>):Void {
		if (this._displaySize == null || !displaySize.equals(this._displaySize)) {
			this._displaySize = displaySize;

			this.updateViewport();
		}
	}

	public function setDisplaySizeInPixels(displaySizeInPixels:Size<Int>):Void {
		// Convert from pixels to points
		var displaySize = Size.createIntSize(Std.int(displaySizeInPixels.width / this._contentScaleFactor),
			Std.int(displaySizeInPixels.height / this._contentScaleFactor));

		this.setDisplaySize(displaySize);
	}

	public function updateViewport():Void {

		// Calculate viewport from constraints applied to display size
		this._viewport = new Rectangle(
			this._horizontalConstraint.getLeftInPoints(displaySize.width, this._contentScaleFactor),
			this._verticalConstraint.getTopInPoints(displaySize.height, this._contentScaleFactor),
			this._horizontalConstraint.getWidthInPoints(displaySize.width, this._contentScaleFactor),
			this._verticalConstraint.getHeightInPoints(displaySize.height, this._contentScaleFactor));

		this._viewportInPixels = new Rectangle(viewport.x * this._contentScaleFactor, viewport.y * this._contentScaleFactor, viewport.width * this._contentScaleFactor, viewport.height * this._contentScaleFactor);

		// See if we need scissor test
		this._scissorEnabled = (
			this._viewport.x != 0 ||
			this._viewport.width != displaySize.width ||
			this._viewport.y != 0 ||
			this._viewport.height != displaySize.height);

		// Emit event
		this.emit("viewport_changed");
	}

	public function setHorizontalConstraint(horizontalConstraint:HorizontalConstraint):Void {
		this._horizontalConstraint = horizontalConstraint;
		this.updateViewport();
	}

	public function setVerticalConstraint(verticalConstraint:VerticalConstraint):Void {
		this._verticalConstraint = verticalConstraint;
		this.updateViewport();
	}

	public override function update(dt:Float):Void {
		// Method to be overridden to get automatic updates every frame if scheduleUpdate has been called
	}

}