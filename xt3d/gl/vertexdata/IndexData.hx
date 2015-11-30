package xt3d.gl.vertexdata;

import lime.utils.UInt16Array;
import xt3d.utils.errors.XTException;
import lime.utils.ArrayBufferView;
import xt3d.gl.GLBufferManager;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GL;

import xt3d.utils.XT;
import xt3d.utils.errors.XTAbstractMethodError;

class IndexData {

	private static var MAX_INDEX_CAPACITY = 2 << 16 - 1;

	// properties
	public var uint16Array(get, null):UInt16Array;
	public var length(get, set):Int;
	public var isDirty(get, set):Bool;
	public var count(get, null):Int;
	public var buffer(get, null):GLBuffer;
	public var type(get, null):Int;

	// members
	private var _ui16Array:UInt16Array = null;
	private var _fixedCapacity:Int = 0;
	private var _length:Int = 0;

	private var _array:Array<UInt> = new Array<UInt>();
	private var _buffer:GLBuffer = null;
	private var _bufferByteLength:Int = 0;
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
		if (fixedCapacity > MAX_INDEX_CAPACITY) {
			throw new XTException("IndexDataCapacityExceedMaximum", "The index data capacity " + fixedCapacity + " exceeds the maximum " + MAX_INDEX_CAPACITY);
		}

		this._ui16Array = new UInt16Array(fixedCapacity);
		this._fixedCapacity = fixedCapacity;

		return true;
	}

	public function new() {

	}

	/* ----------- Properties ----------- */

	function get_uint16Array():UInt16Array {
		return this._ui16Array;
	}

	function get_length():Int {
		return this._length;
	}

	function set_length(value:Int) {
		return this._length = value;
	}

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
			this._buffer = null;
		}
	}

	// Number of elements
	public inline function getLength():Int {
		if (this._ui16Array != null) {
			return this._length;
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
			var bufferByteLength = bufferData.byteLength;

			if (this._buffer == null) {
				// Create new buffer
				this._buffer = bufferManager.createElementBuffer(bufferData);
				this._bufferByteLength = bufferByteLength;

			} else {
				if (bufferByteLength > this._bufferByteLength) {
					// Delete previous buffer
					GL.deleteBuffer(this._buffer);

					// Create new buffer
					this._buffer = bufferManager.createElementBuffer(bufferData);
					this._bufferByteLength = bufferByteLength;

				} else {
					// Update existing buffer
					bufferManager.updateElementBuffer(this._buffer, bufferData);
				}
			}

			this._isDirty = false;
			return true;
		}
		return false;
	}

	private inline function getBufferData():ArrayBufferView {
		if (this._ui16Array != null) {
			return this._ui16Array;
		} else {
			return new UInt16Array(this._array);
		}
	}


	public inline function bind(bufferManager:GLBufferManager):Void {
		bufferManager.setElementBuffer(this._buffer);
	}

	public inline function set(index:Int, value:Int):Void {
		if (this._ui16Array != null) {
			this.handleIndex(index, true);
			this._ui16Array[index] = value;

		} else {
			if (index > MAX_INDEX_CAPACITY) {
				throw new XTException("IndexDataCapacityExceedMaximum", "The index data capacity " + index + " exceeds the maximum " + MAX_INDEX_CAPACITY);
			}
			this._array[index] = value;
		}
		this._isDirty = true;
	}

	public inline function get(index:Int):Int {
		if (this._ui16Array != null) {
			this.handleIndex(index, false);
			return this._ui16Array[index];

		} else {
			return _array[index];
		}
	}

	public inline function push(value:Int):Void {
		if (this._ui16Array != null) {
			this.handleIndex(this._length, false);
			this._ui16Array[this._length++] = value;

		} else {
			_array.push(value);
			if (this._array.length > MAX_INDEX_CAPACITY) {
				throw new XTException("IndexDataCapacityExceedMaximum", "The index data capacity " + this._array.length + " exceeds the maximum " + MAX_INDEX_CAPACITY);
			}
		}
		this._isDirty = true;
	}

	public inline function pop():Int {
		if (this._ui16Array != null) {
			if (this._length <= 0) {
				throw new XTException("IndexOutOfBounds", "Cannot pop from empty array");
			}
			this._length--;

			this._isDirty = true;
			return this._ui16Array[this._length];

		} else {
			this._isDirty = true;
			return _array.pop();
		}
	}

	private inline function handleIndex(index:Int, updateNextIndex:Bool):Void {
		if (index >= this._fixedCapacity) {
			throw new XTException("IndexOutOfBounds", "The index " + index + " is outside the fixed capacity of " + this._fixedCapacity);
		}
		if (updateNextIndex && index > this._length) {
			this._length = index;
		}
	}

}
