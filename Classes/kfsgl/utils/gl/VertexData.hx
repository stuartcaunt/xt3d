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
	public var buffer(get, null):GLBuffer;
	public var attributeName(get, null):String;
	public var vertexSize(get, null):Int;
	public var length(get, null):Int;

	// members
	private var _attributeName:String;
	private var _buffer:GLBuffer = null;
	private var _isDirty = false;

	public function initVertexData(attributeName:String):Bool {
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

	public inline function get_buffer():GLBuffer {
		return this._buffer;
	}

	public inline function get_length():Int {
		return this.getLength();
	}

	public inline function get_attributeName():String {
		return this._attributeName;
	}

	public function get_vertexSize():Int {
		throw new KFAbstractMethodError();
	}


	/* --------- Implementation --------- */

	public function dispose() {
		GLBufferManager.instance().deleteBuffer(this._buffer);
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

	public inline function getAttributeName():String {
		return this._attributeName;
	}

	public function getVertexCount():Int {
		return Std.int(this.getLength() / this.vertexSize);
	}

	public function writeBuffer():Bool {
		if (this._isDirty) {
			var bufferData:ArrayBufferView = this.getBufferData();
			if (this._buffer == null) {
				this._buffer = GLBufferManager.instance().createVertexBuffer(bufferData);

			} else {
				GLBufferManager.instance().updateVertexBuffer(this._buffer, bufferData);
			}

			this._isDirty = false;
			return true;
		}
		return false;
	}

	public function bindToAttribute(attributeLocation:Int):Void {
		throw new KFAbstractMethodError();
	}


}
