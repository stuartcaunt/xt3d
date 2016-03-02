package xt3d.material;

class DepthMaterial extends Material {

	public static function create():DepthMaterial {
		var object = new DepthMaterial();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var isOk;
		if ((isOk = super.initMaterial("depth"))) {
		}

		return isOk;
	}

}
