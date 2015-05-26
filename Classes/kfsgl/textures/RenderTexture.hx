package kfsgl.textures;

import kfsgl.gl.KFGL;
import openfl.gl.GL;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLRenderbuffer;
import kfsgl.utils.Size;
import kfsgl.utils.Color;
import kfsgl.utils.KF;
import kfsgl.gl.GLTextureManager;
class RenderTexture extends Texture2D {

	// properties

	// members
	private var _frameBuffer:GLFramebuffer = null;
	private var _depthStencilRenderBuffer:GLRenderbuffer = null;
	private var _depthStencilFormat:Int = KFGL.DepthStencilFormatDepthAndStencil;

	public static function create(size:Size<Int>, textureOptions:TextureOptions = null):RenderTexture {
		var object = new RenderTexture();

		if (object != null && !(object.init(size, textureOptions))) {
			object = null;
		}

		return object;
	}

	public function init(size:Size<Int>, textureOptions:TextureOptions = null):Bool {
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


		if ((retval = super.initEmpty(size.width, size.height, textureOptions, null))) {
			this.createFrameAndRenderBuffer();
			this._isDirty = false;
		}

		return retval;
	}


	public function new() {
		super();
	}



	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


	override public function dispose(textureManager:GLTextureManager):Void {
		super.dispose(textureManager);

		var renderer = Director.current.renderer;
		var frameBufferManager = renderer.frameBufferManager;

		frameBufferManager.deleteFrameBuffer(this._frameBuffer);
		if (_depthStencilRenderBuffer != null) {
			frameBufferManager.deleteRenderBuffer(this._depthStencilRenderBuffer);
		}
	}

	private function createFrameAndRenderBuffer():Void {
		var renderer = Director.current.renderer;
		var textureManager = renderer.textureManager;
		var frameBufferManager = renderer.frameBufferManager;

		// Create gl texture
		textureManager.uploadTexture(this);

		this._frameBuffer = frameBufferManager.createFrameBuffer();

		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, this._glTexture, 0);

		if (this._depthStencilFormat != KFGL.DepthStencilFormatNone) {
			// Generate render buffer for depth and stencil
			this._depthStencilRenderBuffer = frameBufferManager.createRenderBuffer();

//#if ios
//			GL.renderbufferStorage(GL.RENDERBUFFER, 0x88F0, this._pixelsWidth, this._pixelsHeight);
//#else
//			GL.renderbufferStorage(GL.RENDERBUFFER, GL.RGBA, this._pixelsWidth, this._pixelsHeight);
//#end

			if (this._depthStencilFormat == KFGL.DepthStencilFormatDepth) {
				GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, this._pixelsWidth, this._pixelsHeight);
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);

			} else if (this._depthStencilFormat == KFGL.DepthStencilFormatStencil) {
				GL.renderbufferStorage(GL.RENDERBUFFER, GL.STENCIL_INDEX8, this._pixelsWidth, this._pixelsHeight);
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.STENCIL_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);

			} else {
				GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_STENCIL, this._pixelsWidth, this._pixelsHeight);
#if ios
				// TODO : not working in ios with stencil
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);
//				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.STENCIL_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);
#else
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);
#end
			}
		}


		var frameBufferStatus = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
		if (frameBufferStatus != GL.FRAMEBUFFER_COMPLETE) {
			KF.Error("Could not create complete framebuffer object with render texture");
		}

	}

	public function begin() {
		var renderer = Director.current.renderer;
		var frameBufferManager = renderer.frameBufferManager;

		frameBufferManager.setFrameBuffer(this._frameBuffer);

// State manager?
//		if (enableDepthAndStencil) {
//			GL.enable (GL.DEPTH_TEST);
//			GL.enable (GL.STENCIL_TEST);
//		}
	}

	public function end() {
//		var renderer = Director.current.renderer;
//		var frameBufferManager = renderer.frameBufferManager;
//
//		frameBufferManager.setFrameBuffer(this._frameBuffer);
	}

}
