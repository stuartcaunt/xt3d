package tartiflop;

import tartiflop.KF;
import tartiflop.KFView;
import tartiflop.KFRenderer;
import tartiflop.KFColor;

import openfl.display.OpenGLView;
import flash.geom.Rectangle;

class KFDirector {

	public var openglView(default, set):OpenGLView;
	public var backgroundColor(default, default):KFColor = new KFColor(0.2, 0.2, 0.2);

	private var _renderer:KFRenderer;
	private var _views:Array<KFView> = new Array<KFView>();

	public function new() {
		_renderer = new KFRenderer();
	}
	

	function set_openglView(openglView) {
		this.openglView = openglView;

		this.openglView.render = renderLoop;

		return this.openglView;
	}

	public function addView(view:KFView):Void {
		_views.push(view);
	}


	private function renderLoop(displayRect:Rectangle):Void {

		KF.Log("render");

		// Clear context wil full rectangle 
		_renderer.clear(displayRect, backgroundColor);

		// Iterate over all views
		for (view in _views) {
			// Update the display rect (does nothing if not changed)
			view.displayRect = displayRect;

			// Render view
			view.render(_renderer);
		}

	}

}