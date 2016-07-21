package xt3d.gl;

import lime.utils.Float32Array;
import xt3d.utils.errors.XTException;
import lime.graphics.Image;
import lime.utils.Int16Array;
import lime.utils.ArrayBufferView;
import xt3d.utils.XT;
import xt3d.textures.Texture2D;
import lime.utils.UInt8Array;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;

class GLTextureManager {

	// properties

	// members
	private var _currentTextures:Array<Texture2D> = new Array<Texture2D>();
	private var _activeTextureSlot:Int = 0;
	private var _glInfo:GLInfo;

	public static function create(glInfo:GLInfo):GLTextureManager {
		var object = new GLTextureManager();

		if (object != null && !(object.init(glInfo))) {
			object = null;
		}

		return object;
	}

	public function init(glInfo:GLInfo):Bool {
		this._glInfo = glInfo;

		for (i in 0 ... glInfo.maxCombinedTextureImageUnits) {
			_currentTextures.push(null);
		}

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */


	/* --------- Implementation --------- */

	public function createTexture():GLTexture {
		var texture = GL.createTexture();
		if (texture == null) {
			XT.Error("Cannot create a new GLTexture");
		}
		return texture;
	}


	public function deleteTexture(texture:Texture2D):Void {
		if (texture != null && texture.glTexture != null) {
			GL.deleteTexture(texture.glTexture);

			for (i in 0 ... this._glInfo.maxCombinedTextureImageUnits) {
				if (this._currentTextures[i] == texture) {
					this.setActiveTextureSlot(i);
					this.bindTexture(null);
				}
			}
		}
	}

	public function setTexture(texture:Texture2D, textureSlot:Int):Void {
		//XT.Log("set texture " + texture.name + " at " + textureSlot);

		// Set texture slot
		this.setActiveTextureSlot(textureSlot);

		// Upload or just bind texture
		if (texture != null && texture.isDirty) {
			this.uploadTexture(texture);

		} else {
			this.bindTexture(texture);
		}
	}

	public function setActiveTextureSlot(textureSlot:Int):Void {
		if (textureSlot > this._glInfo.maxCombinedTextureImageUnits) {
			XT.Error("Desired texture slot " + textureSlot + " exceeds maxium allowed " + this._glInfo.maxCombinedTextureImageUnits);
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
			var glTexture = texture != null ? texture.glTexture : null;
			GL.bindTexture(GL.TEXTURE_2D, glTexture);
			//XT.Log("Binding texture " + texture.name);
		}
	}

	public function uploadTexture(texture:Texture2D):Bool {
		if (texture.isDirty) {
			texture.isDirty = false;

			// Create GL Texture
			if (texture.glTexture == null) {
				texture.glTexture = this.createTexture();
				if (texture.glTexture == null) {
					XT.Error("Cannot create a new GLTexture");
					return false;
				}
			}

			this.bindTexture(texture);

			// Handle texture params
			this.handleTextureParams(texture);

			// Upload image data
			this.uploadImageData(texture.image, texture.pixelsWidth, texture.pixelsHeight, texture.pixelFormat);

			// Mipmapping
			if (texture.generateMipMaps) {
				GL.generateMipmap(GL.TEXTURE_2D);
			}
		}

		return true;
	}

	private function handleTextureParams(texture:Texture2D):Void {
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, XTGL.toGLParam(texture.magFilter));
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, XTGL.toGLParam(texture.minFilter));
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, XTGL.toGLParam(texture.wrapS));
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, XTGL.toGLParam(texture.wrapT));
	}



	private function uploadImageData(image:Image, textureWidth:Int, textureHeight:Int, pixelFormat:Int):Void {

		if (textureWidth > this._glInfo.maxTextureSize || textureHeight > this._glInfo.maxTextureSize) {
			throw new XTException("TextureSizeExceedsMaximum", "The texture size " + textureWidth + "x" + textureHeight + " exceeds the maximum " + this._glInfo.maxTextureSize);
		}

		var formattedDataSource;
		if (image == null) {
			formattedDataSource = null;

		} else {
			formattedDataSource = this.formatData(image.data, textureWidth, textureHeight, pixelFormat);
		}

		var bitsPerPixel:Int = this.getBitsPerPixelForFormat(pixelFormat);
		var bytesPerRow:Int = Std.int(textureWidth * bitsPerPixel / 8);

		if(bytesPerRow % 8 == 0) {
			GL.pixelStorei(GL.UNPACK_ALIGNMENT, 8);

		} else if(bytesPerRow % 4 == 0) {
			GL.pixelStorei(GL.UNPACK_ALIGNMENT, 4);

		} else if(bytesPerRow % 2 == 0) {
			GL.pixelStorei(GL.UNPACK_ALIGNMENT, 2);

		} else {
			GL.pixelStorei(GL.UNPACK_ALIGNMENT, 1);
		}

		if (pixelFormat == XTGL.Texture2DPixelFormat_RGBA8888) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, textureWidth, textureHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB888) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, textureWidth, textureHeight, 0, GL.RGB, GL.UNSIGNED_BYTE, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGBA4444) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, textureWidth, textureHeight, 0, GL.RGBA, GL.UNSIGNED_SHORT_4_4_4_4, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB565) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, textureWidth, textureHeight, 0, GL.RGB, GL.UNSIGNED_SHORT_5_6_5, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB5A1) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, textureWidth, textureHeight, 0, GL.RGBA, GL.UNSIGNED_SHORT_5_5_5_1, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_A8) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.ALPHA, textureWidth, textureHeight, 0, GL.ALPHA, GL.UNSIGNED_BYTE, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_I8) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.LUMINANCE, textureWidth, textureHeight, 0, GL.LUMINANCE, GL.UNSIGNED_BYTE, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_AI88) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.LUMINANCE_ALPHA, textureWidth, textureHeight, 0, GL.LUMINANCE_ALPHA, GL.UNSIGNED_BYTE, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float1) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.LUMINANCE, textureWidth, textureHeight, 0, GL.LUMINANCE, GL.FLOAT, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float2) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.LUMINANCE_ALPHA, textureWidth, textureHeight, 0, GL.LUMINANCE_ALPHA, GL.FLOAT, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float3) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, textureWidth, textureHeight, 0, GL.RGB, GL.FLOAT, formattedDataSource);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float4) {
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, textureWidth, textureHeight, 0, GL.RGBA, GL.FLOAT, formattedDataSource);
		}
	}

	private function formatData(source:UInt8Array, width:Int, height:Int, pixelFormat:Int):ArrayBufferView {
		var numberOfPixels = width * height;
		var outPosition = 0;
		var inPosition = 0;
		var r, g, b, a;

		// Does data from asset ever NOT have alpha ? In this case need to handle 3 bytes per pixel as source
		if (pixelFormat == XTGL.Texture2DPixelFormat_RGB888) {
			var formattedLength = numberOfPixels * 3;
			var formattedSource = new UInt8Array(formattedLength);
			for (i in 0 ... numberOfPixels) {
				r = (source[inPosition++]);
				g = (source[inPosition++]);
				b = (source[inPosition++]);
				inPosition++;
				formattedSource[outPosition++] = r;
				formattedSource[outPosition++] = g;
				formattedSource[outPosition++] = b;
			}
			return formattedSource;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGBA4444) {
			var formattedSource = new Int16Array(numberOfPixels);
			for (i in 0 ... numberOfPixels) {
				r = (source[inPosition++] >> 4);
				g = (source[inPosition++] >> 4);
				b = (source[inPosition++] >> 4);
				a = (source[inPosition++] >> 4);
				formattedSource[outPosition++] = (r << 12) | (g << 8) | (b << 4) | (a << 0);
			}
			return formattedSource;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB565) {
			var formattedSource = new Int16Array(numberOfPixels);
			for (i in 0 ... numberOfPixels) {
				r = (source[inPosition++] >> 3);
				g = (source[inPosition++] >> 2);
				b = (source[inPosition++] >> 3);
				inPosition++;
				formattedSource[outPosition++] = (r << 11) | (g << 5) | (b << 0);
			}
			return formattedSource;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB5A1) {
			var formattedSource = new Int16Array(numberOfPixels);
			for (i in 0 ... numberOfPixels) {
				r = (source[inPosition++] >> 3);
				g = (source[inPosition++] >> 3);
				b = (source[inPosition++] >> 3);
				a = (source[inPosition++] >> 7);
				formattedSource[outPosition++] = (r << 11) | (g << 6) | (b << 1) | (a << 0);
			}
			return formattedSource;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_A8) {
			var formattedSource = new UInt8Array(numberOfPixels);
			for (i in 0 ... numberOfPixels) {
				inPosition += 3;
				a = (source[inPosition++]);
				formattedSource[outPosition++] = a;
			}
			return formattedSource;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float1) {
			return new Float32Array(source.buffer);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float2) {
			return new Float32Array(source.buffer);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float3) {
			return new Float32Array(source.buffer);

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float4) {
			return new Float32Array(source.buffer);
		}

		return source;
	}

	private function getBitsPerPixelForFormat(pixelFormat:Int):Int {
		if (pixelFormat == XTGL.Texture2DPixelFormat_RGBA8888) {
			return 32;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB888) {
			return 24;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGBA4444) {
			return 16;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB565) {
			return 16;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_RGB5A1) {
			return 16;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_A8) {
			return 8;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_I8) {
			return 8;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_AI88) {
			return 16;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float1) {
			return 8;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float2) {
			return 16;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float3) {
			return 24;

		} else if (pixelFormat == XTGL.Texture2DPixelFormat_Float4) {
			return 32;
		}
		return 32;
	}

}
