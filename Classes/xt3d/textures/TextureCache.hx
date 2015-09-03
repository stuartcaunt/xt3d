package xt3d.textures;

import xt3d.utils.color.Color;
import xt3d.gl.GLTextureManager;
import xt3d.utils.XT;
class TextureCache {

	// properties

	// members
	private var _textures:Map<String, Texture2D>;


	private function new() {
	}


	public static function create():TextureCache {
		var object = new TextureCache();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	private function init():Bool {
		this._textures = new Map<String, Texture2D>();

		return true;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function addTextureWithURL(url:String, callback:Void -> Texture2D):Void {

	}

	public function addTextureFromImageAsset(imagePath:String, textureOptions:TextureOptions = null):Texture2D {
		if (this._textures.exists(imagePath)) {
			return this._textures.get(imagePath);
		}

		var texture = Texture2D.createFromImageAsset(imagePath, textureOptions);
		this._textures.set(imagePath, texture);

		return texture;
	}

#if js
	public function addTextureFromImageUrl(imageUrl:String, textureOptions:TextureOptions = null):Texture2D {
		if (this._textures.exists(imageUrl)) {
			return this._textures.get(imageUrl);
		}

		var texture = Texture2D.createFromImageUrl(imageUrl, textureOptions);
		this._textures.set(imageUrl, texture);

		return texture;
	}
#end

	public function addTextureFromImageAssetAsync(imagePath:String, textureOptions:TextureOptions = null, callback:Texture2D -> Void = null):Texture2D {
		if (this._textures.exists(imagePath)) {
			return this._textures.get(imagePath);
		}

		var texture = Texture2D.createFromImageAssetAsync(imagePath, textureOptions, callback);
		this._textures.set(imagePath, texture);

		return texture;
	}

	public function addTextureFromColor(color:Color, textureOptions:TextureOptions = null):Texture2D {
		if (this._textures.exists(color.toString())) {
			return this._textures.get(color.toString());
		}

		var texture = Texture2D.createFromColor(color, textureOptions);
		this._textures.set(color.toString(), texture);

		return texture;
	}


	public function textureForKey(textureKey:String):Texture2D {
		if (this._textures.exists(textureKey)) {
			return this._textures.get(textureKey);
		} else {
			XT.Warn("Texture for key \"" + textureKey + "\" does not exist");
			return null;
		}
	}


	public function removeTextureForKey(textureKey:String):Void {
		if (this._textures.exists(textureKey)) {
			var texture = this._textures.get(textureKey);

			// Dispose of the gl object
			texture.dispose();

			this._textures.remove(textureKey);
		}
	}


	public function removeAllTextures():Void {
		var textureKeys = this._textures.keys();
		// Dispose all textures
		for (key in textureKeys) {
			this.removeTextureForKey(key);
		}
	}


	public function removeUnusedTextures():Void {
		// Get textures that are not used
		var unusedTextureKeys:Array<String> = new Array<String>();
		var textureKeys = this._textures.keys();
		while (textureKeys.hasNext()) {
			var textureKey = textureKeys.next();
			var texture = this._textures.get(textureKey);

			if (texture.retainCount == 0) {
				unusedTextureKeys.push(textureKey);
			}
		}

		// Remove unused textures
		for (unusedTextureKey in unusedTextureKeys) {
			this.removeTextureForKey(unusedTextureKey);
		}
	}


}
