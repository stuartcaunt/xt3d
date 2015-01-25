package kfsgl;

import kfsgl.view.KFView;
import kfsgl.renderer.KFRenderer;
import kfsgl.utils.KF;
import kfsgl.utils.KFColor;

import openfl.display.OpenGLView;
import flash.geom.Rectangle;

class KFDirector {

	public var openglView(get_openglView, set_openglView):OpenGLView;
	public var backgroundColor(get_backgroundColor, set_backgroundColor):KFColor;


	private var _openglView:OpenGLView;
	private var _backgroundColor:KFColor = new KFColor(0.2, 0.2, 0.2);
	private var _renderer:KFRenderer;
	private var _views:Array<KFView> = new Array<KFView>();

	public function new() {
		_renderer = new KFRenderer();
		_renderer.init();
	}
	
	public function get_openglView():OpenGLView {
		return _openglView;
	}

	public function set_openglView(openglView) {
		_openglView = openglView;

		_openglView.render = renderLoop;

		return _openglView;
	}

	public function get_backgroundColor():KFColor {
		return _backgroundColor;
	}

	public function set_backgroundColor(backgroundColor) {
		_backgroundColor = backgroundColor;
		return _backgroundColor;
	}

	public function addView(view:KFView):Void {
		_views.push(view);
	}


	private function renderLoop(displayRect:Rectangle):Void {

		//KF.Log("render");

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