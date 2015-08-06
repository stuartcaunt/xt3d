package xt3d.gl.view;

#if lime
import xt3d.gl.view.LimeGLView;
#else
import xt3d.gl.view.OpenFlGLView;
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

#if lime
	public function createView(width:Int = 1024, height:Int = 768):LimeGLView {
		return LimeGLView.create(width, height);
	}
#else
	public function createView(width:Int = 1024, height:Int = 768):OpenFlGLView {
		return OpenFlGLView.create(width, height);
	}
#end


}
