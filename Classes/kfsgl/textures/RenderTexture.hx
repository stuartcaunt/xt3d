package kfsgl.textures;

import openfl.display.BitmapData;
import kfsgl.gl.KFGL;
import openfl.gl.GL;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLRenderbuffer;
import kfsgl.utils.Size;
import kfsgl.utils.Color;
import kfsgl.utils.KF;
class RenderTexture extends Texture2D {

	// properties
	public var frameBuffer(get, null):GLFramebuffer;
	public var clearFlags(get, null):Int;

	// members
	private var _frameBuffer:GLFramebuffer = null;
	private var _depthStencilRenderBuffer:GLRenderbuffer = null;
	private var _depthStencilFormat:Int;

	public static function create(size:Size<Int>, textureOptions:TextureOptions = null):RenderTexture {
		var object = new RenderTexture();

		if (object != null && !(object.init(size, textureOptions))) {
			object = null;
		}

		return object;
	}

	public function init(size:Size<Int>, textureOptions:TextureOptions = null, depthStencilFormat:Int = KFGL.DepthStencilFormatDepth):Bool {
		var retval;

		if (textureOptions  == null) {
			textureOptions = new TextureOptions();
			textureOptions.forcePOT = true;
			textureOptions.minFilter = KFGL.GL_NEAREST;
			textureOptions.magFilter = KFGL.GL_NEAREST;
			textureOptions.wrapS = KFGL.GL_REPEAT;
			textureOptions.wrapT = KFGL.GL_REPEAT;
			textureOptions.generateMipMaps = false;
		}

		if ((retval = super.initEmpty(size.width, size.height, textureOptions))) {
			this._depthStencilFormat = depthStencilFormat;

			this.createFrameAndRenderBuffer();
			this._isDirty = false;

			// Modify uvScaling to invert the image in y
			this._uvOffsetY = (1.0 - this._uvOffsetY) * this._uvScaleY;
			this._uvScaleY *= -1.0;

		}

		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public function get_frameBuffer():GLFramebuffer {
		return this._frameBuffer;
	}

	public function get_clearFlags():Int {
		var clearFlags = GL.COLOR_BUFFER_BIT;
		if (this._depthStencilFormat == KFGL.DepthStencilFormatDepth) {
			clearFlags |= GL.DEPTH_BUFFER_BIT;

		} else if (this._depthStencilFormat == KFGL.DepthStencilFormatStencil) {
			clearFlags |= GL.STENCIL_BUFFER_BIT;

		} else if (this._depthStencilFormat == KFGL.DepthStencilFormatDepthAndStencil) {
			clearFlags |= (GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT);
		}

		return clearFlags;
	}



	/* --------- Implementation --------- */


	override public function dispose():Void {
		super.dispose();

		var renderer = Director.current.renderer;
		var frameBufferManager = renderer.frameBufferManager;

		frameBufferManager.deleteFrameBuffer(this._frameBuffer);
		if (_depthStencilRenderBuffer != null) {
			frameBufferManager.deleteRenderBuffer(this._depthStencilRenderBuffer);
		}
	}

	private function createFrameAndRenderBuffer():Void {
		var renderer = Director.current.renderer;
		var frameBufferManager = renderer.frameBufferManager;

		// Create gl texture
		this.uploadTexture();

		this._frameBuffer = frameBufferManager.createFrameBuffer();

		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, this._glTexture, 0);

		if (this._depthStencilFormat != KFGL.DepthStencilFormatNone) {
			// Generate render buffer for depth and stencil
			this._depthStencilRenderBuffer = frameBufferManager.createRenderBuffer();

			if (this._depthStencilFormat == KFGL.DepthStencilFormatDepth) {
				GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, this._pixelsWidth, this._pixelsHeight);
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);

			} else if (this._depthStencilFormat == KFGL.DepthStencilFormatStencil) {
				GL.renderbufferStorage(GL.RENDERBUFFER, GL.STENCIL_INDEX8, this._pixelsWidth, this._pixelsHeight);
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.STENCIL_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);

			} else {
#if ios
				// GL_DEPTH24_STENCIL8_OES = 0x88F0
				GL.renderbufferStorage(GL.RENDERBUFFER, 0x88F0, this._pixelsWidth, this._pixelsHeight);
#else
				GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_STENCIL, this._pixelsWidth, this._pixelsHeight);
#end
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);
			}
		}

		var frameBufferStatus = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
		if (frameBufferStatus != GL.FRAMEBUFFER_COMPLETE) {
			KF.Error("Could not create complete framebuffer object with render texture");
		}
	}

}
