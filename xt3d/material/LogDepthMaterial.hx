package xt3d.material;

class LogDepthMaterial extends Material {

	public static function create():LogDepthMaterial {
		var object = new LogDepthMaterial();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var isOk;
		if ((isOk = super.initMaterial("logDepth"))) {
		}

		return isOk;
	}

}
