package xt3d.gl.view;

#if xt3dopenfl
import xt3d.gl.view.OpenFlGLView;
#elseif xt3dlime
import xt3d.gl.view.LimeGLView;
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
	public function createView(width:Int = 1024, height:Int = 768):OpenFlGLView {
		return OpenFlGLView.create(width, height);
	}
#elseif xt3dlime
	public function createView(width:Int = 1024, height:Int = 768):LimeGLView {
		return LimeGLView.create(width, height);
	}
#end


}
