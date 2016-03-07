package xt3d.material;

import xt3d.utils.color.Color;
import xt3d.core.Director;
import xt3d.utils.geometry.Size;
import xt3d.textures.TextureOptions;
import xt3d.textures.Texture2D;

class TextureMaterial extends BaseTypedMaterial {

	// properties
	public var texture(get, set):Texture2D;
	public var uvScaleX(get, set):Float;
	public var uvScaleY(get, set):Float;
	public var uvOffsetX(get, set):Float;
	public var uvOffsetY(get, set):Float;
	public var uvScaleOffset(get, null):Array<Float>;
	public var contentSize(get, null):Size<Int>;

	// members
	private var _texture:Texture2D = null;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();


	public static function createWithTexture(texture:Texture2D, materialOptions:MaterialOptions = null):TextureMaterial {
		var object = new TextureMaterial();

		if (object != null && !(object.initWithTexture(texture, materialOptions))) {
			object = null;
		}

		return object;
	}

	public static function createWithImageAsset(imagePath:String, textureOptions:TextureOptions = null, materialOptions:MaterialOptions = null):TextureMaterial {
		var object = new TextureMaterial();

		if (object != null && !(object.initWithImageAsset(imagePath, textureOptions, materialOptions))) {
			object = null;
		}

		return object;
	}

#if js
	public static function createWithImageUrl(imageUrl:String, textureOptions:TextureOptions = null, userCallback:TextureMaterial -> Void = null, materialOptions:MaterialOptions = null):TextureMaterial {
		var object = new TextureMaterial();

		if (object != null && !(object.initWithImageUrl(imageUrl, textureOptions, userCallback, materialOptions))) {
			object = null;
		}

		return object;
	}
#end

	public static function createWithImageAssetAsync(imagePath:String, textureOptions:TextureOptions = null, userCallback:TextureMaterial -> Void = null, materialOptions:MaterialOptions = null):TextureMaterial {
		var object = new TextureMaterial();

		if (object != null && !(object.initWithImageAssetAsync(imagePath, textureOptions, userCallback, materialOptions))) {
			object = null;
		}

		return object;
	}

	public static function createWithColor(color:Color, textureOptions:TextureOptions = null, materialOptions:MaterialOptions = null):TextureMaterial {
		var object = new TextureMaterial();

		if (object != null && !(object.initWithColor(color, textureOptions, materialOptions))) {
			object = null;
		}

		return object;
	}



	public function initWithTexture(texture:Texture2D, materialOptions:MaterialOptions = null):Bool {
		var isOk;
		if ((isOk = super.initBaseTypedMaterial(materialOptions))) {
			this.setTexture(texture);
		}

		return isOk;
	}

	public function initWithImageAsset(imagePath:String, textureOptions:TextureOptions = null, materialOptions:MaterialOptions = null):Bool {
		var isOk;
		if ((isOk = super.initBaseTypedMaterial(materialOptions))) {
			var texture:Texture2D = Director.current.textureCache.addTextureFromImageAsset(imagePath, textureOptions);
			this.setTexture(texture);
		}

		return isOk;
	}


#if js
	public function initWithImageUrl(imageUrl:String, textureOptions:TextureOptions = null, userCallback:TextureMaterial -> Void = null, materialOptions:MaterialOptions = null):Bool {
		var isOk;
		if ((isOk = super.initBaseTypedMaterial(materialOptions))) {
			var texture:Texture2D = Director.current.textureCache.addTextureFromImageUrl(imageUrl, textureOptions, function (texture:Texture2D) {
				this.setTexture(texture);

				// Call user callback
				if (userCallback != null) {
					userCallback(this);
				}
			});
		}

		return isOk;
	}
#end

	public function initWithImageAssetAsync(imagePath:String, textureOptions:TextureOptions = null, userCallback:TextureMaterial -> Void = null, materialOptions:MaterialOptions = null):Bool {
		var isOk;
		if ((isOk = super.initBaseTypedMaterial(materialOptions))) {
			var texture:Texture2D = Director.current.textureCache.addTextureFromImageAssetAsync(imagePath, textureOptions, function (texture:Texture2D) {
				this.setTexture(texture);

				// Call user callback
				if (userCallback != null) {
					userCallback(this);
				}
			});
		}

		return isOk;
	}

	public function initWithColor(color:Color, textureOptions:TextureOptions = null, materialOptions:MaterialOptions = null):Bool {
		var isOk;
		if ((isOk = super.initBaseTypedMaterial(materialOptions))) {
			var texture:Texture2D = Director.current.textureCache.addTextureFromColor(color, textureOptions);
			this.setTexture(texture);

			if (color.alpha < 1.0) {
				this.transparent = true;
			}
		}

		return isOk;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public inline function get_texture():Texture2D {
		return this._texture;
	}

	public inline function set_texture(value:Texture2D) {
		this.setTexture(value);
		return this._texture;
	}

	public inline function get_uvScaleX():Float {
		return this._uvScaleOffset[0];
	}

	public inline function set_uvScaleX(value:Float) {
		this.setUvScaleOffset(value, this._uvScaleOffset[1], this._uvScaleOffset[2], this._uvScaleOffset[3]);
		return this._uvScaleOffset[0];
	}

	public inline function get_uvScaleY():Float {
		return this._uvScaleOffset[1];
	}

	public inline function set_uvScaleY(value:Float) {
		this.setUvScaleOffset(this._uvScaleOffset[0], value, this._uvScaleOffset[2], this._uvScaleOffset[3]);
		return this._uvScaleOffset[1];
	}

	public inline function get_uvOffsetX():Float {
		return this._uvScaleOffset[2];
	}

	public inline function set_uvOffsetX(value:Float) {
		this.setUvScaleOffset(this._uvScaleOffset[0], this._uvScaleOffset[1], value, this._uvScaleOffset[3]);
		return this._uvScaleOffset[2];
	}

	public inline function get_uvOffsetY():Float {
		return this._uvScaleOffset[3];
	}

	public inline function set_uvOffsetY(value:Float) {
		this.setUvScaleOffset(this._uvScaleOffset[0], this._uvScaleOffset[1], this._uvScaleOffset[2], value);
		return this._uvScaleOffset[3];
	}

	public inline function get_uvScaleOffset():Array<Float> {
		return this._uvScaleOffset;
	}

	public inline function get_contentSize():Size<Int> {
		if (this._texture != null) {
			return this._texture.contentSize;
		}
		return Size.createIntSize(1, 1);
	}



	/* --------- Implementation --------- */


	private override function getTypedMaterialName():String {
		return "texture";
	}

	private override function setTypedMaterialUniforms():Void {
		if (this._texture != null) {
			this.uniform("texture").texture = this._texture;
			this.uniform("uvScaleOffset").floatArrayValue = this._texture.uvScaleOffset;
		}
	}

	public function setTexture(value:Texture2D):Void {
		if (this._texture != null) {
			this._texture.release();
			this._texture = null;
		}

		if (value != null) {
			this._texture = value;
			this._texture.retain();

			this.uniform("texture").texture = this._texture;

			var textureUvScaleOffset = this._texture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

		} else {
			this.uniform("texture").texture = null;
		}
	}

	public function setUvScaleOffset(uvScaleX:Float, uvScaleY:Float, uvOffsetX:Float, uvOffsetY:Float):Void {
		this._uvScaleOffset[0] = uvScaleX;
		this._uvScaleOffset[1] = uvScaleY;
		this._uvScaleOffset[2] = uvOffsetX;
		this._uvScaleOffset[3] = uvOffsetY;

		this.uniform("uvScaleOffset").floatArrayValue = this._uvScaleOffset;
	}

}
