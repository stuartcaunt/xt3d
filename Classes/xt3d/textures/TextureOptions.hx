package xt3d.textures;

import xt3d.gl.KFGL;
class TextureOptions {

	// properties
	public var forcePOT(get, set):Bool;
	public var generateMipMaps(get, set):Bool;
	public var minFilter(get, set):Int;
	public var magFilter(get, set):Int;
	public var wrapS(get, set):Int;
	public var wrapT(get, set):Int;
	public var pixelFormat(get, set):Int;

	// members
	private var _forcePOT:Bool = true;
	private var _generateMipMaps:Bool = true;
	private var _minFilter:Int = KFGL.GL_LINEAR;
	private var _magFilter:Int = KFGL.GL_LINEAR;
	private var _wrapS:Int = KFGL.GL_REPEAT;
	private var _wrapT:Int = KFGL.GL_REPEAT;

	private var _pixelFormat:Int = KFGL.Texture2DPixelFormat_RGBA8888;

	public function new() {

	}


/* ----------- Properties ----------- */


	public inline function get_forcePOT():Bool {
		return this._forcePOT;
	}

	public inline function set_forcePOT(value:Bool) {
		return this._forcePOT = value;
	}

	public inline function get_generateMipMaps():Bool {
		return this._generateMipMaps;
	}

	public inline function set_generateMipMaps(value:Bool) {
		return this._generateMipMaps = value;
	}

	public inline function get_minFilter():Int {
		return this._minFilter;
	}

	public inline function set_minFilter(value:Int) {
		return this._minFilter = value;
	}

	public inline function get_magFilter():Int {
		return this._magFilter;
	}

	public inline function set_magFilter(value:Int) {
		return this._magFilter = value;
	}

	public inline function get_wrapS():Int {
		return this._wrapS;
	}

	public inline function set_wrapS(value:Int) {
		return this._wrapS = value;
	}

	public inline function get_wrapT():Int {
		return this._wrapT;
	}

	public inline function set_wrapT(value:Int) {
		return this._wrapT = value;
	}

	public inline function get_pixelFormat():Int {
		return this._pixelFormat;
	}

	public inline function set_pixelFormat(value:Int) {
		return this._pixelFormat = value;
	}


/* --------- Implementation --------- */

}
