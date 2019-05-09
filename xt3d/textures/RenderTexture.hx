package xt3d.textures;

import xt3d.view.View;
import lime.math.Rectangle;
import xt3d.core.RendererOverrider;
import xt3d.utils.color.Color;
import xt3d.gl.XTGL;
import xt3d.gl.GLCurrentContext.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import xt3d.utils.geometry.Size;
import xt3d.utils.XT;
import xt3d.core.Director;

class RenderTexture extends Texture2D {

	// properties
	public var frameBuffer(get, null):GLFramebuffer;
	public var clearFlags(get, null):Int;
	public var clearColor(get, set):Color;

	// members
	private var _frameBuffer:GLFramebuffer = null;
	private var _depthStencilRenderBuffer:GLRenderbuffer = null;
	private var _depthStencilFormat:Int;

	private var _viewport:Rectangle;
	private var _clearColor:Color = Color.createWithRGBAHex(0x00000000);
	private var _oldRenderTarget:RenderTexture = null;

	public static function create(size:Size<Int>, textureOptions:TextureOptions = null, depthStencilFormat:Int = XTGL.DepthStencilFormatDepth):RenderTexture {
		var object = new RenderTexture();

		if (object != null && !(object.init(size, textureOptions, depthStencilFormat))) {
			object = null;
		}

		return object;
	}

	public function init(size:Size<Int>, textureOptions:TextureOptions = null, depthStencilFormat:Int = XTGL.DepthStencilFormatDepth):Bool {
		var retval;

		if (textureOptions  == null) {
			textureOptions = TextureOptions.NEAREST_REPEAT_POT;
			//textureOptions = TextureOptions.NEAREST_CLAMP;
		}

		if ((retval = super.initEmpty(size.width, size.height, textureOptions))) {
			this._depthStencilFormat = depthStencilFormat;

			this.createFrameAndRenderBuffer();
			this._isDirty = false;

			// Modify uvScaling to invert the image in y
			this._uvOffsetY = (1.0 - this._uvOffsetY) * this._uvScaleY;
			this._uvScaleY *= -1.0;

			this._viewport = new Rectangle(0.0, 0.0, size.width, size.height);
		}

		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public inline function get_frameBuffer():GLFramebuffer {
		return this._frameBuffer;
	}

	public inline function get_clearFlags():Int {
		var clearFlags = GL.COLOR_BUFFER_BIT;
		if (this._depthStencilFormat == XTGL.DepthStencilFormatDepth) {
			clearFlags |= GL.DEPTH_BUFFER_BIT;

		} else if (this._depthStencilFormat == XTGL.DepthStencilFormatStencil) {
			clearFlags |= GL.STENCIL_BUFFER_BIT;

		} else if (this._depthStencilFormat == XTGL.DepthStencilFormatDepthAndStencil) {
			clearFlags |= (GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT);
		}

		return clearFlags;
	}

	public inline function get_clearColor():Color {
		return this._clearColor;
	}

	public inline function set_clearColor(value:Color) {
		return this._clearColor = value;
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

		if (this._depthStencilFormat != XTGL.DepthStencilFormatNone) {
			// Generate render buffer for depth and stencil
			this._depthStencilRenderBuffer = frameBufferManager.createRenderBuffer();

			if (this._depthStencilFormat == XTGL.DepthStencilFormatDepth) {
				GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, this._pixelsWidth, this._pixelsHeight);
				GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, this._depthStencilRenderBuffer);

			} else if (this._depthStencilFormat == XTGL.DepthStencilFormatStencil) {
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
			XT.Error("Could not create complete framebuffer object with render texture");
		}
	}

	public function beginWithClear(clearColor:Color = null):Void {
		var renderer = Director.current.renderer;

		this.begin();

		if (clearColor == null) {
			clearColor = this._clearColor;
		}

		// Clear render target
		renderer.clear(clearColor, this.clearFlags);
	}

	public function begin():Void {
		var renderer = Director.current.renderer;

		// Get old render target
		this._oldRenderTarget = renderer.renderTarget;

		// Bind to render texture frame buffer
		renderer.renderTarget = this;

		// Set viewport with full rectangle
		renderer.setViewport(this._viewport);

		// Disable scissor tests
		renderer.disableScissor();
	}

	public function updateView(view:View, rendererOverrider:RendererOverrider = null):Void {
		// Update the view
		view.updateView(rendererOverrider);
	}

	public function render(view:View, rendererOverrider:RendererOverrider = null):Void {
		// Render the view
		view.render(rendererOverrider);
	}

	public function end():Void {
		var renderer = Director.current.renderer;

		// Put back old render target
		renderer.renderTarget = this._oldRenderTarget;
	}

	public function renderWithClear(view:View, rendererOverrider:RendererOverrider = null, clearColor:Color = null):Void {
		// Clear and set viewport
		this.beginWithClear(clearColor);

		// Render
		this.render(view, rendererOverrider);

		// End
		this.end();
	}

}
