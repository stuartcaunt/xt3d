package kfsgl.view;

import kfsgl.camera.KFCamera;
import kfsgl.node.KFScene;
import flash.geom.Rectangle;

import kfsgl.renderer.KFRenderer;
import kfsgl.utils.KFColor;

class KFView  {

	// Viewport descriptor : {top right bottom left}
	// can give percentages of full frame or pixel offsets
	// Negative values are considered to be from opposite side
	// eg {2px -202px -102px 2px} creates a rectangle of ((2, 2), (200, 100))

	public var displayRect(default, null):Rectangle;
	public var viewport(default, null):Rectangle;
	public var backgroundColor(default, default):KFColor = new KFColor();

	public var scene(default, default):KFScene;
	public var camera(default, default):KFCamera;

	public function new() {

	}

	public function render(renderer:KFRenderer):Void {
		// Clear view
		renderer.clear(viewport, backgroundColor);

		// Render scene with camera
		renderer.renderScene(this.scene, this.camera);
	}


	public function setDisplayRect(displayRect:Rectangle) {
		if (this.displayRect == null || !displayRect.equals(this.displayRect)) {
			// Update viewport - do calculation if needed.
			// Just copy for now
			this.viewport = displayRect;
			this.displayRect = displayRect;
		}

		return this.displayRect;
	}
}