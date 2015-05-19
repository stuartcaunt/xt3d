package kfsgl.utils;

class Size<T> {

	// properties
	public var width(get, set):T;
	public var height(get, set):T;

	// members
	private var _width:T;
	private var _height:T;

	public static function createIntSize(width:Int, height:Int):Size<Int> {
		var object = new Size<Int>();

		if (object != null && !(object.init(width, height))) {
			object = null;
		}

		return object;
	}

	public function init(width:T, height:T):Bool {
		this._width = width;
		this._height = height;

		return true;
	}


	public function new() {

	}



	/* ----------- Properties ----------- */

	public inline function get_width():T {
		return this._width;
	}

	public inline function set_width(value:T) {
		return this._width = value;
	}

	public inline function get_height():T {
		return this._height;
	}

	public inline function set_height(value:T) {
		return this._height = value;
	}



	/* --------- Implementation --------- */

}
