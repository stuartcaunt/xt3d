package ;


import xt3d.gl.view.Xt3dLimeGLView;
import xt3d.utils.color.Color;
import xt3d.core.Director;
import xt3d.gl.view.Xt3dGLViewFactory;
import lime.app.Application;


class MainApplication extends Application {

	private var _director:Director;
	private var _glView:Xt3dLimeGLView;


	public function new () {
		super();

		ApplicationMain.config.windows[0].depthBuffer = true;

		var backgroundColor = Color.createWithComponents(0.2, 0.2, 0.2);

		// Create opengl view and as it as a child
		this._glView = Xt3dGLViewFactory.instance().createView();
		this.addModule(this._glView);

		// Initialise director - one per application delegate
		this._director = Director.create();
		this._director.glView = this._glView;
		this._director.backgroundColor = backgroundColor;

		this._director.onReady(function () {
			this.createViews();
		});

	}

	private function createViews():Void {

	}

}