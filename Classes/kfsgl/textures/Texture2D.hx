package kfsgl.textures;

import kfsgl.gl.GLTextureManager;
import kfsgl.gl.KFGL;
import flash.utils.ByteArray;
import openfl.utils.UInt8Array;
import kfsgl.utils.KF;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.display.BitmapData;
import openfl.geom.Point;
import kfsgl.utils.Size;
import openfl.Assets;
import kfsgl.utils.CountedObject;

class Texture2D extends CountedObject {

	// properties
	public var name(get, null):String;
	public var isDirty(get, set):Bool;
	public var glTexture(get, set):GLTexture;
	public var generateMipMaps(get, set):Bool;
	public var minFilter(get, set):Int;
	public var magFilter(get, set):Int;
	public var wrapS(get, set):Int;
	public var wrapT(get, set):Int;

	public var bitmapData(get, null):BitmapData;
	public var pixelsWidth(get, null):Int;
	public var pixelsHeight(get, null):Int;

	public var uvScaleOffset(get, null):Array<Float>;

	// members
	private var _name:String;
	private var _contentSize:Size<Int>;
	private var _pixelsWidth:Int;
	private var _pixelsHeight:Int;
	private var _uvScaleX:Float = 1.0;
	private var _uvScaleY:Float = 1.0;
	private var _uvOffsetX:Float = 0.0;
	private var _uvOffsetY:Float = 0.0;

	private var _generateMipMaps:Bool;
	private var _minFilter:Int;
	private var _magFilter:Int;
	private var _wrapS:Int;
	private var _wrapT:Int;

	private var _glTexture:GLTexture = null;
	private var _bitmapData:BitmapData = null;
	private var _isDirty:Bool = false;

	/** helper object */
	private static var _sOrigin:Point = new Point();

	public static function createFromAssetImage(imagePath:String, textureOptions:TextureOptions = null, textureManager:GLTextureManager = null):Texture2D {
		var object = new Texture2D();

		if (object != null && !(object.initFromAssetImage(imagePath, textureOptions, textureManager))) {
			object = null;
		}

		return object;
	}

	public function initFromAssetImage(imagePath:String, textureOptions:TextureOptions = null, textureManager:GLTextureManager = null):Bool {
		this._name = imagePath;

		if (textureOptions == null) {
			textureOptions = new TextureOptions();
		}

		// Set texture options
		this.setTextureOptions(textureOptions);

		// Get bitmap data from asset
		var bitmapData = Assets.getBitmapData(imagePath);
		if (bitmapData == null) {
			KF.Error("Cannot get bitmap data from \"" + imagePath + "\"");
			return false;
		}

		var size = new Size<Int>();
		this._contentSize = Size.createIntSize(bitmapData.width, bitmapData.height);

		// Create power-of-two bitmap data
		if (textureOptions.forcePOT) {
			this._pixelsWidth = this.getNextPOT(this._contentSize.width);
			this._pixelsHeight = this.getNextPOT(this._contentSize.height);
			if (this._pixelsWidth != bitmapData.width || this._pixelsHeight != bitmapData.height) {
				var potBitmapData = new BitmapData(this._pixelsWidth, this._pixelsHeight, true, 0);
				potBitmapData.copyPixels(bitmapData, bitmapData.rect, _sOrigin);
				bitmapData = potBitmapData;

				this._uvScaleX = this._contentSize.width / this._pixelsWidth;
				this._uvScaleY = this._contentSize.height / this._pixelsHeight;
			}
		}

		this._bitmapData = bitmapData;
		this._isDirty = true;

		// Upload texture immediately if we have a texture manager
		if (textureManager != null) {
			textureManager.uploadTexture(this);
		}

		return true;
	}


	public function new() {
		super();

	}


	/* ----------- Properties ----------- */

	public function get_name():String {
		return this._name;
	}

	public function get_isDirty():Bool {
		return this._isDirty;
	}

	public function set_isDirty(value:Bool):Bool {
		return this._isDirty = value;
	}

	public function get_glTexture():GLTexture {
		return this._glTexture;
	}

	public function set_glTexture(value:GLTexture) {
		return this._glTexture = value;
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

	public function get_bitmapData():BitmapData {
		return this._bitmapData;
	}

	public function get_pixelsWidth():Int {
		return this._pixelsWidth;
	}

	public function get_pixelsHeight():Int {
		return this._pixelsHeight;
	}


	public function get_uvScaleOffset():Array<Float> {
		return [this._uvScaleX, this._uvScaleY, this._uvOffsetX, this._uvOffsetY];
	}


	/* --------- Implementation --------- */

	public function dispose(textureManager:GLTextureManager):Void {
		textureManager.deleteTexture(this);
		this._glTexture = null;
	}

	private function setTextureOptions(options:TextureOptions):Void {
		this._generateMipMaps = options.generateMipMaps;
		this._minFilter = options.minFilter;
		this._magFilter = options.magFilter;
		this._wrapS = options.wrapS;
		this._wrapT = options.wrapT;
	}

	private function getNextPOT(value:Int):Int {
		var pot:Int = 1;
		while (pot < value) {
			pot = pot << 1;
		}
		return pot;
	}
}
