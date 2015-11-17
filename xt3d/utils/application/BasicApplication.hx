package xt3d.utils.application;

import xt3d.utils.color.Color;
import xt3d.gl.view.Xt3dGLViewFactory;
import xt3d.core.Director;
import lime.app.Application;

class BasicApplication extends Application {

	// properties
	public var director(get, null):Director;

	// members
	private var _director:Director;

	public function new () {
		super();

		// Enable depth buffer in the Application
		ApplicationMain.config.windows[0].depthBuffer = true;

		// Create opengl view and as it as a child
		var glView = Xt3dGLViewFactory.instance().buildView(this);

		// Create a director and set the gl view it is to render on
		this._director = Director.create();
		this._director.glView = glView;

		// When the director is ready create the View
		this._director.onReady(function () {
			this.onApplicationReady();
		});

	}

	/* ----------- Properties ----------- */

	function get_director():Director {
		return this._director;
	}

	/* --------- Implementation --------- */


	private function onApplicationReady():Void {
		// Override me
	}

}
