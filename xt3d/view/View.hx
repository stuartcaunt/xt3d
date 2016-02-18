package xt3d.view;

import lime.graphics.opengl.GL;
import lime.math.Vector2;
import lime.math.Matrix3;
import xt3d.utils.Types;
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
	@:isVar public var isOpaque(get, set):Bool;
	public var scene(get, set):Scene;
	public var camera(get, set):Camera;
	public var orientation(get, set):XTOrientation;
	public var viewTransform(get, set):Matrix3;

	// members
	private var _viewport:Rectangle;
	private var _viewportInPixels:Rectangle;
	private var _displaySize:Size<Int>; // In points
	private var _horizontalConstraint:HorizontalConstraint = HorizontalConstraint.create();
	private var _verticalConstraint:VerticalConstraint = VerticalConstraint.create();
	private var _scissorEnabled:Bool = false;
	private var _orientation:XTOrientation = XTOrientation.Orientation0;
	private var _viewTransform:Matrix3 = new Matrix3();

	private var _backgroundColor:Color = Director.current.backgroundColor;
	private var _isOpaque:Bool = false;

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
		return this._backgroundColor;
	}

	public inline function set_backgroundColor(value:Color) {
		return this._backgroundColor = value;
	}

	function get_isOpaque():Bool {
		return this._isOpaque;
	}

	function set_isOpaque(value:Bool) {
		return this._isOpaque = value;
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

	function get_orientation():XTOrientation {
		return this._orientation;
	}

	function set_orientation(value:XTOrientation) {
		this.setOrientation(value);
		return this._orientation;
	}

	function get_viewTransform():Matrix3 {
		return this._viewTransform;
	}

	function set_viewTransform(value:Matrix3) {
		return this._viewTransform = value;
	}


	/* --------- Implementation --------- */

	public function setScene(scene:Scene):Void {
		this._scene = scene;
	}

	public function setOrientation(orientation:XTOrientation):Void {
		if (orientation != this._orientation) {
			this._orientation = orientation;

			// Update view transform
			this.calculateViewTransform();

			// Emit event
			this.emit("orientation_changed");
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
		if (this._isOpaque) {
			renderer.clear(this._backgroundColor, GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

		} else {
			renderer.clear(null, GL.DEPTH_BUFFER_BIT);
		}

		// Prepare for render
		this._preRenderPhase(rendererOverrider);

		// Render scene with camera
		// TODO : Change this for a callback: standard callback is as follows, custom one allows for
		// TODO : additional effects such as shadow depth calculation, post processing.
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

		// Prepare for render
		this._preRenderPhase(rendererOverrider);

		// Render scene with camera
		renderer.render(this._scene, this._camera, rendererOverrider);
	}

	private function _preRenderPhase(rendererOverrider:RendererOverrider):Void {
		// Update world matrices of scene graph
		this._scene.updateWorldMatrix();

		// Make sure camera matrix is updated even if it has not been added to the scene
		if (this._camera.parent == null) {
			this._camera.updateWorldMatrix();
		}

		// Update objects - anything that needs to be done before rendering
		this._scene.prepareObjectsForRender(this._scene, rendererOverrider);

		// Emit event
		this.emit("pre_render");
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

		// Update view transform
		this.calculateViewTransform();

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

	public function containsScreenPosition(x:Float, y:Float):Bool {
		// Invert y
		return this._viewport.contains(x, y);
	}

	public function isNodeInView(node):Bool {
		if (this._scene != null) {
			return this._scene.containsChild(node);
		}

		return false;
	}

	private function calculateViewTransform():Void {
		if (this._orientation == XTOrientation.Orientation0) {
			var ox = -this._viewport.x;
			var oy = -this._viewport.y;
			this._viewTransform.setTo(1.0, 0.0, 0.0, 1.0, ox, oy);

		} else if (this._orientation == XTOrientation.Orientation90Clockwise) {
			var ox = this._viewport.height + this._viewport.y;
			var oy = -this._viewport.x;
			this._viewTransform.setTo(0.0, 1.0, -1.0, 0.0, ox, oy);

		} else if (this._orientation == XTOrientation.Orientation90CounterClockwise) {
			var ox = -this._viewport.y;
			var oy = this._viewport.x + this._viewport.width;
			this._viewTransform.setTo(0.0, -1.0, 1.0, 0.0, ox, oy);

		} else if (this._orientation == XTOrientation.Orientation180) {
			var ox = this._viewport.x + this._viewport.width;
			var oy = this._viewport.y + this._viewport.height;

			this._viewTransform.setTo(-1.0, 0.0, 0.0, -1.0, ox, oy);
		}

	}

	public override function update(dt:Float):Void {
		// Method to be overridden to get automatic updates every frame if scheduleUpdate has been called
	}

}