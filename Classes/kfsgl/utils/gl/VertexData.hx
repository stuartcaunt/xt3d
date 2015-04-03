package kfsgl.utils.gl;

import openfl.utils.ArrayBufferView;
import kfsgl.utils.gl.GLBufferManager;
import kfsgl.utils.KF;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import kfsgl.errors.KFAbstractMethodError;
class VertexData {

	// properties
	public var isDirty(get, set):Bool;

	// members
	private var _attributeName:String;
	private var _buffer:GLBuffer = null;
	private var _isDirty = false;

	public function init(attributeName:String):Bool {
		this._attributeName = attributeName;

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

	/* --------- Implementation --------- */

	public function dispose() {
		GLBufferManager.getInstance().deleteBuffer(this._buffer);
	}

	public function getLength():Int {
		throw new KFAbstractMethodError();
	}

	public function getByteLength():Int {
		throw new KFAbstractMethodError();
	}

	public function setIsDirty(isDirty:Bool):Void {
		this._isDirty = isDirty;
	}

	public function getBufferData():ArrayBufferView {
		throw new KFAbstractMethodError();
	}

	public function writeBuffer():Void {
		if (this._isDirty) {
			var bufferData:ArrayBufferView = this.getBufferData();
			if (_buffer == null) {
				_buffer = GLBufferManager.getInstance().createVertexBuffer(bufferData);

			} else {
				GLBufferManager.getInstance().updateVertexBuffer(_buffer, bufferData);
			}

			this._isDirty = false;
		}
	}

}
