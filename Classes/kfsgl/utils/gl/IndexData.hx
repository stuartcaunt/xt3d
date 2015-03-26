package kfsgl.utils.gl;

import openfl.utils.Int16Array;
import openfl.gl.GLBuffer;
import openfl.gl.GL;

import kfsgl.utils.KF;
import kfsgl.errors.KFAbstractMethodError;
import kfsgl.errors.KFAbstractMethodError;
import kfsgl.errors.KFAbstractMethodError;

class IndexData {

	// properties
	public var isDirty(get, set):Bool;

	// members
	private var _array:Array<UInt> = new Array<UInt>();
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

	// Number of elements
	public function getLength():Int {
		return this._array.length;
	}


	public function bufferData():Void {
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(_array), GL.STATIC_DRAW);
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
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this._buffer);

			this.bufferData();

			//GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);

			this._isDirty = false;
		}
	}


	public inline function set(index:Int, value:UInt):Void {
		_array[index] = value;
		this._isDirty = true;
	}

	public inline function get(index:Int):UInt {
		return _array[index];
	}

	public inline function push(value:UInt):Void {
		_array.push(value);
		this._isDirty = true;
	}

	public inline function pop():UInt {
		return _array.pop();
		this._isDirty = true;
	}

}
