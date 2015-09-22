package ;


import xt3d.utils.color.Color;
import xt3d.core.Director;
import xt3d.gl.view.Xt3dGLViewFactory;

#if xt3dopenfl
import openfl.display.Sprite;
import xt3d.gl.view.Xt3dOpenFLGLView;
#else
import lime.app.Application;
import xt3d.gl.view.Xt3dLimeGLView;
#end


#if xt3dopenfl
class MainApplication extends Sprite {
#else
class MainApplication extends Application {
#end

	private var _director:Director;

#if xt3dopenfl
	private var _glView:Xt3dOpenFLGLView;
#else
	private var _glView:Xt3dLimeGLView;
#end

	public function new () {
		super();

#if xt3dopenfl
#else
		ApplicationMain.config.windows[0].depthBuffer = true;
#end
		var backgroundColor = Color.createWithComponents(0.2, 0.2, 0.2);

		// Create opengl view and as it as a child
		this._glView = Xt3dGLViewFactory.instance().createView();
#if xt3dopenfl
		this.addChild(this._glView);
#else
		this.addModule(this._glView);
#end

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