package xt3d.lights;

import xt3d.view.View;

class ShadowEngine {

	// properties
	public var debug(get, set):Bool;

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

	public inline function set_debug(value:Bool):Bool {
		return this.setDebug(value);
	}

	public inline function get_debug():Bool {
		return this.getDebug();
	}
	/* --------- Implementation --------- */

	public function getDebug():Bool {
		// Override me
		return null;
	}

	public function setDebug(value:Bool):Bool {
		// Override me
		return null;
	}

	public function dispose():Void {
		// Override me
	}

	public function updateShadows(view:View, light:Light):Void {
		// Override me
	}

}
