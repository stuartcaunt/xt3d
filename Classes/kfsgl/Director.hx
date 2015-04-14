package kfsgl;

import kfsgl.events.EventEmitter;
import kfsgl.renderer.shaders.UniformLib;
import kfsgl.view.View;
import kfsgl.renderer.Renderer;
import kfsgl.utils.Color;

import openfl.display.OpenGLView;
import flash.geom.Rectangle;

class Director extends EventEmitter {

	// properties
	public var openglView(get_openglView, set_openglView):OpenGLView;
	public var backgroundColor(get_backgroundColor, set_backgroundColor):Color;


	// members
	private var _openglView:OpenGLView;
	private var _backgroundColor:Color = new Color(0.2, 0.2, 0.2);
	private var _renderer:Renderer;
	private var _views:Array<View> = new Array<View>();

	private var _globalTime = 0.0;

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */

	public inline function get_openglView():OpenGLView {
		return _openglView;
	}

	public inline function set_openglView(openglView) {
		_openglView = openglView;

		// Create new renderer for opengl view
		_renderer = Renderer.create();

		_openglView.render = renderLoop;

		return _openglView;
	}

	public inline function get_backgroundColor():Color {
		return _backgroundColor;
	}

	public inline function set_backgroundColor(backgroundColor) {
		_backgroundColor = backgroundColor;
		return _backgroundColor;
	}

	/* --------- Implementation --------- */


	public function addView(view:View):Void {
		_views.push(view);
	}

	private function renderLoop(displayRect:Rectangle):Void {

		//KF.Log("render");

		// Calculate time step
		var dt = 1.0 / 60.0;
		_globalTime += dt;
		UniformLib.instance().uniform("time").value = _globalTime;

//		// TODO : remove this, just used to help debugging in chrome
//		if (_globalTime < 2.0) {
//			return;
//		}

		// send pre-render event (custom updates before rendering)
		this.emit("pre_render");

		// Clear context wil full rectangle
		_renderer.clear(displayRect, backgroundColor);

		// Iterate over all views
		for (view in _views) {
			// Update the display rect (does nothing if not changed)
			view.setDisplayRect(displayRect);

			// Render view
			view.render(_renderer);
		}

		// send pre-render event (custom updates before rendering)
		this.emit("post_render");

	}

}