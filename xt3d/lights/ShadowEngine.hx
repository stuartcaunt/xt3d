package xt3d.lights;

import xt3d.view.View;

class ShadowEngine {

	// properties

	// members

	public static function create():ShadowEngine {
		var object = new ShadowEngine();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function dispose():Void {
		// Override me
	}

	public function updateShadows(view:View, light:Light):Void {
		// Override me
	}

}
