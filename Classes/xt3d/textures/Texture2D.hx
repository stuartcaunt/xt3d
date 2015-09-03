package xt3d.textures;

import xt3d.utils.image.ImageHelper;
import lime.math.Vector2;
import lime.graphics.Image;
import xt3d.utils.XTObject;
import xt3d.utils.color.Color;
import xt3d.utils.image.ImageLoader;
import xt3d.gl.GLTextureManager;
import xt3d.gl.XTGL;
import lime.utils.ByteArray;
import lime.utils.UInt8Array;
import xt3d.utils.XT;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import xt3d.utils.geometry.Size;
import xt3d.core.Director;
import lime.Assets;

	class Texture2D extends XTObject {

	// properties
	public var name(get, null):String;
	public var isDirty(get, set):Bool;
	public var glTexture(get, set):GLTexture;
	public var generateMipMaps(get, set):Bool;
	public var minFilter(get, set):Int;
	public var magFilter(get, set):Int;
	public var wrapS(get, set):Int;
	public var wrapT(get, set):Int;
	public var pixelFormat(get, set):Int;

	public var image(get, null):Image;
	public var contentSize(get, null):Size<Int>;
	public var pixelsWidth(get, null):Int;
	public var pixelsHeight(get, null):Int;

	public var uvScaleOffset(get, null):Array<Float>;

	// members
	private static var ID_COUNTER = 0;
	private var _id:Int = ID_COUNTER++;
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
	private var _pixelFormat:Int;
	private var _forcePOT:Bool;

	private var _glTexture:GLTexture = null;
	private var _image:Image = null;
	private var _isReady:Bool = false;
	private var _isDirty:Bool = true;

	/** helper object */
	private static var _sOrigin:Vector2 = new Vector2();

	public static function createEmpty(width:Int, height:Int, textureOptions:TextureOptions = null):Texture2D {
		var object = new Texture2D();

		if (object != null && !(object.initEmpty(width, height, textureOptions))) {
			object = null;
		}

		return object;
	}

	public static function createFromImageAsset(imagePath:String, textureOptions:TextureOptions = null):Texture2D {
		var object = new Texture2D();

		if (object != null && !(object.initFromImageAsset(imagePath, textureOptions))) {
			object = null;
		}

		return object;
	}

#if js
	public static function createFromImageUrl(imageUrl:String, textureOptions:TextureOptions = null):Texture2D {
		var object = new Texture2D();

		if (object != null && !(object.initFromImageUrl(imageUrl, textureOptions))) {
			object = null;
		}

		return object;
	}
#end

	public static function createFromImageAssetAsync(imagePath:String, textureOptions:TextureOptions = null, callback:Texture2D -> Void = null):Texture2D {
		var object = new Texture2D();

		if (object != null && !(object.initFromImageAssetAsync(imagePath, textureOptions, callback))) {
			object = null;
		}

		return object;
	}

	public static function createFromColor(color:Color, textureOptions:TextureOptions = null):Texture2D {
		var object = new Texture2D();

		if (object != null && !(object.initFromColor(color, textureOptions))) {
			object = null;
		}

		return object;
	}

	public function initEmpty(width:Int, height:Int, textureOptions:TextureOptions = null):Bool {
		this._name = "empty-texture-" + this._id;

		// Set texture options
		this.setTextureOptions(textureOptions);

		var size = new Size<Int>();
		this._contentSize = Size.createIntSize(width, height);

		// Create power-of-two image data
		if (this._forcePOT) {
			this._pixelsWidth = this.getNextPOT(this._contentSize.width);
			this._pixelsHeight = this.getNextPOT(this._contentSize.height);
			this._uvScaleX = this._contentSize.width / this._pixelsWidth;
			this._uvScaleY = this._contentSize.height / this._pixelsHeight;
		}

		// Create texture immediately
		this.uploadTexture();

		this._isReady = true;

		return true;
	}



	public function initFromImageAsset(imagePath:String, textureOptions:TextureOptions = null):Bool {
		this._name = imagePath;

		// Set texture options
		this.setTextureOptions(textureOptions);

		// Get image from asset
		var image:Image = Assets.getImage(imagePath);
		if (image == null) {
			XT.Error("Image at \"" + imagePath + "\" does not exist");
			return false;
		}

		// Handle the image data
		this.handleImageData(image);

		// Create texture immediately
		this.uploadTexture();

		this._isReady = true;

		return true;
	}


#if js
	public function initFromImageUrl(imageUrl:String, textureOptions:TextureOptions = null):Bool {
		this._name = imageUrl;

		// Set texture options
		this.setTextureOptions(textureOptions);

		var imageLoader = ImageLoader.create(imageUrl,
			function (image:Image) {
				// Handle the image data
				this.handleImageData(image);

				this._isReady = true;
			},
			function (error) {
				XT.Error("Texture2D failed to create texture: " + error);
			});


		return true;
	}
#end

	public function initFromImageAssetAsync(imagePath:String, textureOptions:TextureOptions = null, callback:Texture2D -> Void = null):Bool {
		this._name = imagePath;

		// Set texture options
		this.setTextureOptions(textureOptions);

		// Get image from asset in async
		Assets.loadImage(imagePath, function (image:Image) {
			if (image == null) {
				XT.Error("Cannot get image from \"" + imagePath + "\"");

			} else {
				// Handle the image data
				this.handleImageData(image);

				this._isReady = true;

				// user callback
				if (callback != null) {
					callback(this);
				}
			}

		});

		return true;
	}


	public function initFromColor(color:Color, textureOptions:TextureOptions = null):Bool {
		this._name = color.toString();

		// Set texture options
		this.setTextureOptions(textureOptions);

		// Get image data from asset
		var image = ImageHelper.imageFromColor(2, 2, color);
		if (image == null) {
			XT.Error("Cannot create image from color \"" + color.toString + "\"");
			return false;
		}

		// Handle the image data
		this.handleImageData(image);

		// Create texture immediately
		this.uploadTexture();

		this._isReady = true;

		return true;
	}

	public function new() {
		super();

	}


	/* ----------- Properties ----------- */

	public inline function get_name():String {
		return this._name;
	}

	public inline function get_isDirty():Bool {
		return this._isDirty;
	}

	public inline function set_isDirty(value:Bool):Bool {
		return this._isDirty = value;
	}

	public inline function get_glTexture():GLTexture {
		return this._glTexture;
	}

	public inline function set_glTexture(value:GLTexture) {
		return this._glTexture = value;
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

	public inline function get_image():Image {
		return this._image;
	}

	public inline function get_contentSize():Size<Int> {
		return this._contentSize;
	}

	public inline function get_pixelsWidth():Int {
		return this._pixelsWidth;
	}

	public inline function get_pixelsHeight():Int {
		return this._pixelsHeight;
	}


	public inline function get_uvScaleOffset():Array<Float> {
		return [this._uvScaleX, this._uvScaleY, this._uvOffsetX, this._uvOffsetY];
	}


	/* --------- Implementation --------- */

	public function dispose():Void {
		var renderer = Director.current.renderer;
		renderer.textureManager.deleteTexture(this);
		this._glTexture = null;
	}

	private function uploadTexture():Void {
		var renderer = Director.current.renderer;
		renderer.textureManager.uploadTexture(this);
	}

	private function setTextureOptions(textureOptions:TextureOptions):Void {
		if (textureOptions == null) {
			textureOptions = new TextureOptions();
		}

		this._generateMipMaps = textureOptions.generateMipMaps;
		this._minFilter = textureOptions.minFilter;
		this._magFilter = textureOptions.magFilter;
		this._wrapS = textureOptions.wrapS;
		this._wrapT = textureOptions.wrapT;
		this._pixelFormat = textureOptions.pixelFormat;
		this._forcePOT = textureOptions.forcePOT;
	}

	private function handleImageData(image:Image):Void {

		// Get content size of original image (before resizing to PoT)
		var size = new Size<Int>();
		this._contentSize = Size.createIntSize(image.width, image.height);

		// Create power-of-two image
		if (this._forcePOT && !image.powerOfTwo) {
			var potImage = image.clone();
			potImage.powerOfTwo = true;

			image = potImage;
		}

		// Get real pixel width and uv scaling after any modification to the image
		this._pixelsWidth = image.buffer.width;
		this._pixelsHeight = image.buffer.height;
		this._uvScaleX = this._contentSize.width / this._pixelsWidth;
		this._uvScaleY = this._contentSize.height / this._pixelsHeight;

		this._image = image;
		this._isDirty = true;
	}

	private function getNextPOT(value:Int):Int {
		var pot:Int = 1;
		while (pot < value) {
			pot = pot << 1;
		}
		return pot;
	}
}
