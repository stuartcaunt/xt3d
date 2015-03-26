package kfsgl.utils.gl;

import kfsgl.utils.KF;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import kfsgl.errors.KFAbstractMethodError;
class VertexData {

	// properties
	public var isDirty(get, set):Bool;

	// members
	private var _buffer:GLBuffer = null;
	private var _isDirty = false;

	public function new() {

	}

	/* ----------- Properties ----------- */

	public inline function get_isDirty():Bool {
		return this._isDirty;
	}


	public inline function set_isDirty(value:Bool):Bool {
		return this._isDirty = value;
	}

	/* --------- Implementation --------- */

	public function dispose() {
		if (_buffer != null) {
			GL.deleteBuffer(this._buffer);
		}

	}

	public function getLength():Int {
		throw new KFAbstractMethodError();
	}

	public function getByteLength():Int {
		throw new KFAbstractMethodError();
	}

	public function bufferData():Void {
		throw new KFAbstractMethodError();
	}

	public function setIsDirty(isDirty:Bool):Void {
		this._isDirty = isDirty;
	}

	public function writeBuffer():Void {
		if (this._isDirty) {
			if (_buffer == null) {
				_buffer = GL.createBuffer();
			}

			KF.Log("TODO: Use buffer manager");
			GL.bindBuffer(GL.ARRAY_BUFFER, this._buffer);

			this.bufferData();

			//GL.bindBuffer(GL.ARRAY_BUFFER, null);

			this._isDirty = false;
		}
	}

}
