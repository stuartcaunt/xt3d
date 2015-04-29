package kfsgl.textures;

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
	public var generateMipMaps(get, set):Bool;
	public var minFilter(get, set):Int;
	public var magFilter(get, set):Int;
	public var wrapS(get, set):Int;
	public var wrapT(get, set):Int;

	// members
	private var _contentSize:Size<Int>;
	private var _pixelsWidth:Int;
	private var _pixelsHeight:Int;

	private var _generateMipMaps:Bool;
	private var _minFilter:Int;
	private var _magFilter:Int;
	private var _wrapS:Int;
	private var _wrapT:Int;

	private var _texture:GLTexture = null;

	/** helper object */
	private static var _sOrigin:Point = new Point();

	public static function createFromAssetImage(imagePath:String, textureOptions:TextureOptions = null):Texture2D {
		var object = new Texture2D();

		if (object != null && !(object.initFromAssetImage(imagePath, textureOptions))) {
			object = null;
		}

		return object;
	}

	public function initFromAssetImage(imagePath:String, textureOptions:TextureOptions = null):Bool {
		if (textureOptions == null) {
			textureOptions = new TextureOptions();
		}

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
			}
		}

		// Create GL Texture
		this._texture = GL.createTexture();
		if (this._texture == null) {
			KF.Error("Cannot create a new GLTexture");
			return false;
		}

		GL.bindTexture(GL.TEXTURE_2D, this._texture);

		this.uploadImageData(bitmapData, this._pixelsWidth, this._pixelsHeight);



		// Set texture options
		this.setTextureOptions(textureOptions);

		GL.bindTexture(GL.TEXTURE_2D, null);

		return true;
	}


	public function new() {
		super();

	}


	/* ----------- Properties ----------- */

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

	public function dispose():Void {
		if (this._texture != null) {
			GL.deleteTexture(this._texture);
			this._texture = null;
		}
	}

	private function uploadImageData(bitmapData:BitmapData, textureWidth:Int, textureHeight:Int):Void {

#if js
		var byteArray = ByteArray.__ofBuffer (@:privateAccess (bitmapData.__image).data.buffer);
		var source = new UInt8Array(byteArray.length);
		byteArray.position = 0;

		var i:Int = 0;
		while (byteArray.position < byteArray.length) {

			source[i] = byteArray.readUnsignedByte ();
			i++;
		}
#else
		var byteArray = @:privateAccess (bitmapData.__image).data.buffer;
		var source = new UInt8Array(byteArray);
#end

		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, textureWidth, textureHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, source);
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
