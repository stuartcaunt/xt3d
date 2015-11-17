package xt3d.gl.view;

#if xt3dopenfl
import xt3d.gl.view.Xt3dOpenFLGLView;
import openfl.display.Sprite;
#else
import xt3d.gl.view.Xt3dLimeGLView;
import lime.app.Application;
#end

class Xt3dGLViewFactory {

	private static var _instance:Xt3dGLViewFactory = null;

	private function new() {
	}

	public static function instance():Xt3dGLViewFactory {
		if (_instance == null) {
			_instance = new Xt3dGLViewFactory();
		}

		return _instance;
	}

#if xt3dopenfl
	public function createView():Xt3dOpenFLGLView {
		return Xt3dOpenFLGLView.create();
	}

	public function buildView(parent:Sprite):Xt3dGLView {
		var glView = this.createView();

		parent.addChild(glView);

		return glView;
	}

	#else
	public function createView():Xt3dLimeGLView {
		return Xt3dLimeGLView.create();
	}

	public function buildView(parent:Application):Xt3dGLView {
		var glView = this.createView();

		parent.addModule(glView);

		return glView;
	}
#end


}
