package kfsgl.textures;

import kfsgl.gl.KFGL;
class TextureOptions {

	// properties
	public var forcePOT(get, set):Bool;
	public var generateMipMaps(get, set):Bool;
	public var minFilter(get, set):Int;
	public var magFilter(get, set):Int;
	public var wrapS(get, set):Int;
	public var wrapT(get, set):Int;

	// members
	private var _forcePOT:Bool = true;
	private var _generateMipMaps:Bool = true;
	private var _minFilter:Int = KFGL.GL_NEAREST;
	private var _magFilter:Int = KFGL.GL_NEAREST;
	private var _wrapS:Int = KFGL.GL_REPEAT;
	private var _wrapT:Int = KFGL.GL_REPEAT;

	public function new() {

	}


/* ----------- Properties ----------- */


	public function get_forcePOT():Bool {
		return this._forcePOT;
	}

	public function set_forcePOT(value:Bool) {
		return this._forcePOT = value;
	}

	public function get_generateMipMaps():Bool {
		return this._generateMipMaps;
	}

	public function set_generateMipMaps(value:Bool) {
		return this._generateMipMaps = value;
	}

	public function get_minFilter():Int {
		return this._minFilter;
	}

	public function set_minFilter(value:Int) {
		return this._minFilter = value;
	}

	public function get_magFilter():Int {
		return this._magFilter;
	}

	public function set_magFilter(value:Int) {
		return this._magFilter = value;
	}

	public function get_wrapS():Int {
		return this._wrapS;
	}

	public function set_wrapS(value:Int) {
		return this._wrapS = value;
	}

	public function get_wrapT():Int {
		return this._wrapT;
	}

	public function set_wrapT(value:Int) {
		return this._wrapT = value;
	}




	/* --------- Implementation --------- */

}
