package xt3d.material;

import xt3d.utils.color.Color;
import xt3d.core.Director;
import xt3d.utils.geometry.Size;
import xt3d.textures.TextureOptions;
import xt3d.textures.Texture2D;

class Dot3BumpMaterialExtension {

	// properties
	public var texture(get, set):Texture2D;
	public var uvScaleOffset(get, null):Array<Float>;

	// members
	private var _texture:Texture2D = null;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();


	public static function createWithTexture(texture:Texture2D):Dot3BumpMaterialExtension {
		var object = new Dot3BumpMaterialExtension();

		if (object != null && !(object.initWithTexture(texture))) {
			object = null;
		}

		return object;
	}

	public static function createWithImageAsset(imagePath:String, textureOptions:TextureOptions = null):Dot3BumpMaterialExtension {
		var object = new Dot3BumpMaterialExtension();

		if (object != null && !(object.initWithImageAsset(imagePath, textureOptions))) {
			object = null;
		}

		return object;
	}

#if js
	public static function createWithImageUrl(imageUrl:String, textureOptions:TextureOptions = null, userCallback:Dot3BumpMaterialExtension -> Void = null):Dot3BumpMaterialExtension {
		var object = new Dot3BumpMaterialExtension();

		if (object != null && !(object.initWithImageUrl(imageUrl, textureOptions, userCallback))) {
			object = null;
		}

		return object;
	}
#end

	public static function createWithImageAssetAsync(imagePath:String, textureOptions:TextureOptions = null, userCallback:Dot3BumpMaterialExtension -> Void = null):Dot3BumpMaterialExtension {
		var object = new Dot3BumpMaterialExtension();

		if (object != null && !(object.initWithImageAssetAsync(imagePath, textureOptions, userCallback))) {
			object = null;
		}

		return object;
	}


	public function initWithTexture(texture:Texture2D):Bool {
		this.setTexture(texture);

		return true;
	}

	public function initWithImageAsset(imagePath:String, textureOptions:TextureOptions = null):Bool {
		var texture:Texture2D = Director.current.textureCache.addTextureFromImageAsset(imagePath, textureOptions);
		this.setTexture(texture);

		return true;
	}


#if js
	public function initWithImageUrl(imageUrl:String, textureOptions:TextureOptions = null, userCallback:Dot3BumpMaterialExtension -> Void = null):Bool {
		var texture:Texture2D = Director.current.textureCache.addTextureFromImageUrl(imageUrl, textureOptions, function (texture:Texture2D) {
			this.setTexture(texture);

			// Call user callback
			if (userCallback != null) {
				userCallback(this);
			}
		});

		return true;
	}
#end

	public function initWithImageAssetAsync(imagePath:String, textureOptions:TextureOptions = null, userCallback:Dot3BumpMaterialExtension -> Void = null):Bool {
		var texture:Texture2D = Director.current.textureCache.addTextureFromImageAssetAsync(imagePath, textureOptions, function (texture:Texture2D) {
			this.setTexture(texture);

			// Call user callback
			if (userCallback != null) {
				userCallback(this);
			}
		});

		return true;
	}

	public function new() {
	}


	/* ----------- Properties ----------- */

	public inline function get_texture():Texture2D {
		return this._texture;
	}

	public inline function set_texture(value:Texture2D) {
		this.setTexture(value);
		return this._texture;
	}

	public inline function get_uvScaleOffset():Array<Float> {
		return this._uvScaleOffset;
	}


	/* --------- Implementation --------- */


	public function setTexture(value:Texture2D):Void {
		if (this._texture != null) {
			this._texture.release();
			this._texture = null;
		}

		if (value != null) {
			this._texture = value;
			this._texture.retain();

			var textureUvScaleOffset = this._texture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);
		}
	}

	public function setUvScaleOffset(uvScaleX:Float, uvScaleY:Float, uvOffsetX:Float, uvOffsetY:Float):Void {
		this._uvScaleOffset[0] = uvScaleX;
		this._uvScaleOffset[1] = uvScaleY;
		this._uvScaleOffset[2] = uvOffsetX;
		this._uvScaleOffset[3] = uvOffsetY;
	}

}
