package kfsgl.gl.vertexdata;

import kfsgl.utils.errors.KFException;
import openfl.utils.ArrayBufferView;
import kfsgl.gl.GLBufferManager;
import openfl.utils.Int16Array;
import openfl.gl.GLBuffer;
import openfl.gl.GL;

import kfsgl.utils.KF;
import kfsgl.utils.errors.KFAbstractMethodError;

class IndexData {

	// properties
	public var isDirty(get, set):Bool;
	public var count(get, null):Int;
	public var buffer(get, null):GLBuffer;
	public var type(get, null):Int;

	// members
	private var _i16Array:Int16Array = null;
	private var _fixedCapacity:Int = 0;
	private var _nextIndex:Int = 0;

	private var _array:Array<UInt> = new Array<UInt>();
	private var _buffer:GLBuffer = null;
	private var _isDirty = false;

	public static function create():IndexData {
		var object = new IndexData();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public static function createWithArray(array:Array<UInt>):IndexData {
		var object = new IndexData();

		if (object != null && !(object.initWithArray(array))) {
			object = null;
		}

		return object;
	}

	public static function createWithFixedCapacity(fixedCapacity:Int):IndexData {
		var object = new IndexData();

		if (object != null && !(object.initWithFixedCapacity(fixedCapacity))) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		return true;
	}

	public function initWithArray(array:Array<UInt>):Bool {
		this._array = array;

		return true;
	}

	public function initWithFixedCapacity(fixedCapacity:Int):Bool {
		this._i16Array = new Int16Array(fixedCapacity);
		this._fixedCapacity = fixedCapacity;

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

	public inline function get_count():Int {
		return this.getLength();
	}

	public inline function get_buffer():GLBuffer {
		return this._buffer;
	}

	public inline function get_type():UInt {
		return GL.UNSIGNED_SHORT;
	}


	/* --------- Implementation --------- */

	public inline function dispose() {
		if (this._buffer != null) {
			GL.deleteBuffer(this._buffer);
		}
	}

	// Number of elements
	public inline function getLength():Int {
		if (this._i16Array != null) {
			return this._nextIndex;
		} else {
			return this._array.length;
		}
	}

	public inline function setIsDirty(isDirty:Bool):Void {
		this._isDirty = isDirty;
	}

	public inline function getIndexCount():Int {
		return this.getLength();
	}

	public function writeBuffer(bufferManager:GLBufferManager):Bool {
		if (this._isDirty) {
			var bufferData = this.getBufferData();
			if (this._buffer == null) {
				this._buffer = bufferManager.createElementBuffer(bufferData);

			} else {
				bufferManager.updateElementBuffer(this._buffer, bufferData);
			}

			this._isDirty = false;
			return true;
		}
		return false;
	}

	private inline function getBufferData():ArrayBufferView {
		if (this._i16Array != null) {
			return this._i16Array;
		} else {
			return new Int16Array(this._array);
		}
	}


	public inline function bind(bufferManager:GLBufferManager):Void {
		bufferManager.setElementBuffer(this._buffer);
	}

	public inline function set(index:Int, value:Int):Void {
		if (this._i16Array != null) {
			this.handleIndex(index, true);
			this._i16Array[this._nextIndex++] = value;

		} else {
			this._array[index] = value;
		}
		this._isDirty = true;
	}

	public inline function get(index:Int):Int {
		if (this._i16Array != null) {
			this.handleIndex(index, false);
			return this._i16Array[index];

		} else {
			return _array[index];
		}
	}

	public inline function push(value:Int):Void {
		if (this._i16Array != null) {
			this.handleIndex(this._nextIndex, false);
			this._i16Array[this._nextIndex++] = value;

		} else {
			_array.push(value);
		}
		this._isDirty = true;
	}

	public inline function pop():Int {
		if (this._i16Array != null) {
			if (this._nextIndex <= 0) {
				throw new KFException("IndexOutOfBounds", "Cannot pop from empty array");
			}
			this._nextIndex--;

			this._isDirty = true;
			return this._i16Array[this._nextIndex];

		} else {
			this._isDirty = true;
			return _array.pop();
		}
	}

	private inline function handleIndex(index:Int, updateNextIndex:Bool):Void {
		if (index >= this._fixedCapacity) {
			throw new KFException("IndexOutOfBounds", "The index " + index + " is outside the fixed capacity of " + this._fixedCapacity);
		}
		if (updateNextIndex && index > this._nextIndex) {
			this._nextIndex = index;
		}
	}

}
