package tartiflop;

import flash.geom.Rectangle;

import tartiflop.KFRenderer;

class KFView  {

	// Viewport descriptor : {top right bottom left}
	// can give percentages of full frame or pixel offsets
	// Negative values are considered to be from opposite side
	// eg {2px -202px -102px 2px} creates a rectangle of ((2, 2), (200, 100))

	public var displayRect(default, set):Rectangle;
	public var viewport(default, default):Rectangle;
	public var backgroundColor(default, default):KFColor = new KFColor();

	public function new() {

	}

	public function render(renderer:KFRenderer):Void {
		renderer.clear(viewport, backgroundColor);
	}


	function set_displayRect(rect:Rectangle) {
		if (this.displayRect == null || !rect.equals(this.displayRect)) {	
			// Update viewport - do calculation if needed.
			// Just copy for now
			this.viewport = rect;
			this.displayRect = rect;
		}

		return rect;
	}
}