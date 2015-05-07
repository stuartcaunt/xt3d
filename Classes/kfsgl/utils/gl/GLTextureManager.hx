package kfsgl.utils.gl;

import kfsgl.textures.Texture2D;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;
import openfl.display.BitmapData;
import openfl.gl.GL;
import openfl.gl.GLTexture;
class GLTextureManager {

	// properties
	public var maxTextureSlots(get, null):Int;

	// members
	private var _currentTextures:Array<Texture2D> = new Array<Texture2D>();
	private var _activeTextureSlot:Int = 0;
	private var _maxTextureSlots:Int;
	private var _maxVertexTextures:Int;
	private var _maxTextureSize:Int;
	private var _maxCubemapSize:Int;

	public static function create():GLTextureManager {
		var object = new GLTextureManager();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		this._maxTextureSlots = GL.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
		this._maxVertexTextures = GL.getParameter(GL.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
		this._maxTextureSize = GL.getParameter(GL.MAX_TEXTURE_SIZE);
		this._maxCubemapSize = GL.getParameter(GL.MAX_CUBE_MAP_TEXTURE_SIZE);

		for (i in 0 ... this._maxTextureSlots) {
			_currentTextures.push(null);
		}

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	public function get_maxTextureSlots():Int {
		return this._maxTextureSlots;
	}



	/* --------- Implementation --------- */

	public function createTexture():GLTexture {
		var texture = GL.createTexture();
		if (texture == null) {
			KF.Error("Cannot create a new GLTexture");
		}
		return texture;
	}


	public function deleteTexture(texture:Texture2D):Void {
		if (texture != null && texture.glTexture != null) {
			GL.deleteTexture(texture.glTexture);

			for (i in 0 ... this._maxTextureSlots) {
				if (this._currentTextures[i] == texture) {
					this.setActiveTextureSlot(i);
					this.bindTexture(null);
				}
			}
		}
	}

	public function setTexture(texture:Texture2D, textureSlot:Int):Void {
		if (texture != null) {

			// Set texture slot
			this.setActiveTextureSlot(textureSlot);

			// Upload or just bind texture
			if (texture.isDirty) {
				this.uploadTexture(texture);

			} else {
				this.bindTexture(texture);
			}
		}
	}

	public function setActiveTextureSlot(textureSlot:Int):Void {
		if (textureSlot > this._maxTextureSlots) {
			KF.Error("Desired texture slot " + textureSlot + " exceeds maxium allowed " + this._maxTextureSlots);
		} else {
			if (textureSlot != this._activeTextureSlot) {
				GL.activeTexture(GL.TEXTURE0 + textureSlot);
				this._activeTextureSlot = textureSlot;
			}
		}
	}

	private function bindTexture(texture:Texture2D):Void {
		if (this._currentTextures[this._activeTextureSlot] != texture) {
			this._currentTextures[this._activeTextureSlot] = texture;
			GL.bindTexture(GL.TEXTURE_2D, texture.glTexture);
		}
	}

	public function uploadTexture(texture:Texture2D):Bool {
		if (texture.isDirty) {
			texture.isDirty = false;

			// Create GL Texture
			if (texture.glTexture == null) {
				texture.glTexture = this.createTexture();
				if (texture.glTexture == null) {
					KF.Error("Cannot create a new GLTexture");
					return false;
				}
			}

			this.bindTexture(texture);

			// Handle texture params
			this.handleTextureParams(texture);

			// Upload image data
			this.uploadImageData(texture.bitmapData, texture.pixelsWidth, texture.pixelsHeight);

			// Mipmapping
			if (texture.generateMipMaps) {
				GL.generateMipmap(GL.TEXTURE_2D);
			}
		}

		return true;
	}

	private function handleTextureParams(texture:Texture2D):Void {
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, KFGL.toGLParam(texture.minFilter));
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, KFGL.toGLParam(texture.magFilter));
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, KFGL.toGLParam(texture.wrapS));
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, KFGL.toGLParam(texture.wrapT));
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

		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, textureWidth, textureHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, source);
	}

}
