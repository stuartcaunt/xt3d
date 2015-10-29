package xt3d.gl.vertexdata;

import lime.utils.ArrayBufferView;
import xt3d.gl.GLBufferManager;
import xt3d.utils.XT;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import xt3d.utils.errors.XTAbstractMethodError;
class VertexData {

	// properties
	public var isDirty(get, set):Bool;
	public var buffer(get, null):GLBuffer;
	public var length(get, null):Int;

	// members
	private var _buffer:GLBuffer = null;
	private var _isDirty = false;

	public function initVertexData():Bool {

		return true;
	}

	public function new() {
	}

	/* ----------- Properties ----------- */

	public inline function get_isDirty():Bool {
		return this._isDirty;
	}

	public inline function set_isDirty(value:Bool):Bool {
		return this._isDirty = value;
	}

	public inline function get_buffer():GLBuffer {
		return this._buffer;
	}

	public inline function get_length():Int {
		return this.getLength();
	}


	/* --------- Implementation --------- */

	public function dispose() {
		if (this._buffer != null) {
			GL.deleteBuffer(this._buffer);
			this._buffer = null;
		}
	}

	public function getLength():Int {
		throw new XTAbstractMethodError();
	}

	public function setIsDirty(isDirty:Bool):Void {
		this._isDirty = isDirty;
	}

	public function getBufferData():ArrayBufferView {
		throw new XTAbstractMethodError();
	}

	public function getVertexCount():Int {
		throw new XTAbstractMethodError();
	}

	public function writeBuffer(bufferManager:GLBufferManager):Bool {
		if (this._isDirty) {
			var bufferData:ArrayBufferView = this.getBufferData();
			if (this._buffer == null) {
				this._buffer = bufferManager.createVertexBuffer(bufferData);

			} else {
				bufferManager.updateVertexBuffer(this._buffer, bufferData);
			}

			this._isDirty = false;
			return true;
		}
		return false;
	}

}
