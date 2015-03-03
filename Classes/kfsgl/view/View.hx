package kfsgl.view;

import kfsgl.camera.Camera;
import kfsgl.node.Scene;
import flash.geom.Rectangle;

import kfsgl.renderer.Renderer;
import kfsgl.utils.Color;

class View  {

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


	public function new() {

	}

	/* ----------- Properties ----------- */


	public function get_displayRect():Rectangle {
		return _displayRect;
	}

	public function set_displayRect(value:Rectangle) {
		this.setDisplayRect(value);
		return this._displayRect;
	}

	public function get_viewport():Rectangle {
		return _viewport;
	}

	public function set_viewport(value:Rectangle) {
		this.setViewport(value);
		return this._viewport;
	}

	public function get_viewportInPixels():Rectangle {
		return _viewportInPixels;
	}

	public function set_viewportInPixels(value:Rectangle) {
		this.setViewportInPixels(value);
		return this._viewportInPixels;
	}

	public function get_backgroundColor():Color {
		return _backgroundColor;
	}

	public function set_backgroundColor(value:Color) {
		this._backgroundColor = value;
		return this._backgroundColor;
	}

	public function get_scene():Scene {
		return _scene;
	}

	public function set_scene(value:Scene) {
		this._scene = value;
		return this._scene;
	}

	public function get_camera():Camera {
		return _camera;
	}

	public function set_camera(value:Camera) {
		this._camera = value;
		return this._camera;
	}


	/* --------- Implementation --------- */

	public function render(renderer:Renderer):Void {
		// Clear view
		renderer.clear(viewport, backgroundColor);

		// Render scene with camera
		renderer.renderScene(this.scene, this.camera);
	}


	public function setDisplayRect(displayRect:Rectangle) {
		this.setViewport(displayRect);
	}

	public function setViewport(viewport:Rectangle) {
		if (this._viewport == null || !viewport.equals(this._viewport)) {
			// Update displayrect - do calculation if needed.
			// Just copy for now
			this._viewport = viewport;
			this._displayRect = viewport;

			this.viewportInPixels = new Rectangle(viewport.x * this._contentScaleFactor, viewport.y * this._contentScaleFactor, viewport.width * this._contentScaleFactor, viewport.height * this._contentScaleFactor);
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
		}
	}
}