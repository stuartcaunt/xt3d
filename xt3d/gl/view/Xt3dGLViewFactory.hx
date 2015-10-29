package xt3d.gl.view;

#if xt3dopenfl
import xt3d.gl.view.Xt3dOpenFLGLView;
#else
import xt3d.gl.view.Xt3dLimeGLView;
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
#else
	public function createView():Xt3dLimeGLView {
		return Xt3dLimeGLView.create();
	}
#end


}
