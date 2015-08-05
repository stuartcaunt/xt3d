package xt3d.gl.view;

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

	public function createView(width:Int = 1024, height:Int = 768):Xt3dView {

	}


}
