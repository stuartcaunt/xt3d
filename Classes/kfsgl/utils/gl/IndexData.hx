package kfsgl.utils.gl;

import kfsgl.utils.gl.GLBufferManager;
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

	public function init():Bool {
		return true;
	}

	public function initWithArray(array:Array<UInt>):Bool {
		this._array = array;

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

	public function dispose() {
		if (this._buffer != null) {
			GL.deleteBuffer(this._buffer);
		}
	}

	// Number of elements
	public function getLength():Int {
		return this._array.length;
	}

	public function setIsDirty(isDirty:Bool):Void {
		this._isDirty = isDirty;
	}

	public function getIndexCount():Int {
		return this.getLength();
	}

	public function writeBuffer(bufferManager:GLBufferManager):Bool {
		if (this._isDirty) {
			if (this._buffer == null) {
				this._buffer = bufferManager.createElementBuffer(new Int16Array(this._array));

			} else {
				bufferManager.updateElementBuffer(this._buffer, new Int16Array(this._array));
			}

			this._isDirty = false;
			return true;
		}
		return false;
	}

	public function bind(bufferManager:GLBufferManager):Void {
		bufferManager.setElementBuffer(this._buffer);
	}

	public inline function set(index:Int, value:UInt):Void {
		this._array[index] = value;
		this._isDirty = true;
	}

	public inline function get(index:Int):UInt {
		return this._array[index];
	}

	public inline function push(value:UInt):Void {
		this._array.push(value);
		this._isDirty = true;
	}

	public inline function pop():UInt {
		return _array.pop();
		this._isDirty = true;
	}

}
