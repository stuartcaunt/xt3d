package xt3d.textures;

import xt3d.view.View;
import lime.math.Rectangle;
import xt3d.node.Camera;
import xt3d.math.Vector4;
import xt3d.core.RendererOverrider;
import xt3d.utils.color.Color;
import xt3d.node.Scene;
import xt3d.node.Node3D;
import xt3d.gl.XTGL;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import xt3d.utils.geometry.Size;
import xt3d.utils.XT;
import xt3d.core.Director;

class RenderTexture extends Texture2D {

	// properties
	public var frameBuffer(get, null):GLFramebuffer;
	public var clearFlags(get, null):Int;
	public var backgroundColor(get, set):Color;
	public var camera(get, set):Camera;
	public var view(get, set):View;

	// members
	private var _frameBuffer:GLFramebuffer = null;
	private var _depthStencilRenderBuffer:GLRenderbuffer = null;
	private var _depthStencilFormat:Int;

	private var _view:View = View.create();
	private var _viewport:Rectangle;

	public static function create(size:Size<Int>, textureOptions:TextureOptions = null):RenderTexture {
		var object = new RenderTexture();

		if (object != null && !(object.init(size, textureOptions))) {
			object = null;
		}

		return object;
	}

	public function init(size:Size<Int>, textureOptions:TextureOptions = null, depthStencilFormat:Int = XTGL.DepthStencilFormatDepth):Bool {
		var retval;

		if (textureOptions  == null) {
			textureOptions = new TextureOptions();
			textureOptions.forcePOT = true;
			textureOptions.minFilter = XTGL.GL_NEAREST;
			textureOptions.magFilter = XTGL.GL_NEAREST;
			textureOptions.wrapS = XTGL.GL_REPEAT;
			textureOptions.wrapT = XTGL.GL_REPEAT;
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

		// Create scene
		this._view.scene = Scene.create();

		// Create camera (by default already with perspective projection)
		this._view.camera = Camera.create(this._view);


		this._view.displaySize = Size.createIntSize(this._contentSize.width, this._contentSize.height);

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

	public inline function get_backgroundColor():Color {
		return this._view.backgroundColor;
	}

	public inline function set_backgroundColor(value:Color) {
		return this._view.backgroundColor = value;
	}

	function get_camera():Camera {
		return this._view.camera;
	}

	function set_camera(value:Camera) {
		return this._view.camera = value;
	}

	public inline function get_view():View {
		return this._view;
	}

	public inline function set_view(value:View) {
		return this._view = value;
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


	public function render(node:Node3D, clear:Bool = true, clearColor:Color = null, rendererOverrider:RendererOverrider = null):Void {
		var scene = this._view.scene;

		// Make of copy of original position
		var originalPosition = node.position;

		if (Type.getClass(node) == Scene) {
			this._view.scene = cast node;

		} else {
			// Set node matrix to identity matrix
			node.position = new Vector4();

			// Take temporary ownership of the node
			scene.borrowChild(node);
		}

		var renderer = Director.current.renderer;

		// Get old render target
		var oldRenderTarget = renderer.renderTarget;

		// Bind to render texture frame buffer
		renderer.renderTarget = this;

		// Set clear flags
		this._view.clearFlags = this.clearFlags;

		// Render the view
		this._view.render();

		// Put back old render target
		renderer.renderTarget = oldRenderTarget;

		if (scene != node) {
			// Replace node in original heirarchy
			this._view.scene.returnBorrowedChild(node);

			// Put back origin matrix
			node.position = originalPosition;
		}
	}

}
