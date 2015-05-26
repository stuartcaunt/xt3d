package kfsgl.gl;

import openfl.gl.GLFramebuffer;
import openfl.gl.GLRenderbuffer;
import openfl.gl.GL;
class GLFrameBufferManager {

// members

// State
	private var _currentFrameBuffer:GLFramebuffer = null;
	private var _currentRenderBuffer:GLRenderbuffer = null;


	public static function create():GLFrameBufferManager {
		var object = new GLFrameBufferManager();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
// If we want to use unsigned int index arrays (in webgl):
//var uintExtension = GL.getExtension('OES_element_index_uint');

		return true;
	}

	public function new() {
	}


/* --------- Implementation --------- */


	public inline function createFrameBuffer():GLFramebuffer {
		var frameBuffer = GL.createFramebuffer();

		// Set framebuffer
		this.setFrameBuffer(frameBuffer);

		return frameBuffer;
	}

	public inline function createRenderBuffer():GLRenderbuffer {
		var renderBuffer = GL.createRenderbuffer();

		// Set renderbuffer
		this.setRenderBuffer(renderBuffer);

		return renderBuffer;
	}

	public inline function deleteFrameBuffer(frameBuffer:GLFramebuffer):Void {
		GL.deleteFramebuffer(frameBuffer);

		// Set framebuffer to null
		this.setFrameBuffer(null);
	}

	public inline function deleteRenderBuffer(renderBuffer:GLRenderbuffer):Void {
		GL.deleteRenderbuffer(renderBuffer);

		// Set renderbuffer to null
		this.setRenderBuffer(null);
	}


	public inline function setFrameBuffer(frameBuffer:GLFramebuffer):Void {
		if (this._currentFrameBuffer != frameBuffer) {
			this._currentFrameBuffer = frameBuffer;

			GL.bindFramebuffer(GL.FRAMEBUFFER, this._currentFrameBuffer);
		}
	}

	public inline function setRenderBuffer(renderBuffer:GLRenderbuffer):Void {
		if (this._currentRenderBuffer != renderBuffer) {
			this._currentRenderBuffer = renderBuffer;

			GL.bindRenderbuffer(GL.RENDERBUFFER, this._currentRenderBuffer);
		}
	}

}

