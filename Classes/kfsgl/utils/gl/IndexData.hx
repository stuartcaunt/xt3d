package kfsgl.utils.gl;

import kfsgl.utils.gl.GLBufferManager;
import openfl.utils.Int16Array;
import openfl.gl.GLBuffer;
import openfl.gl.GL;

import kfsgl.utils.KF;
import kfsgl.errors.KFAbstractMethodError;

class IndexData {

	// properties
	public var isDirty(get, set):Bool;

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

/* --------- Implementation --------- */

	public function dispose() {
		GLBufferManager.getInstance().deleteBuffer(this._buffer);
	}

	// Number of elements
	public function getLength():Int {
		return this._array.length;
	}

	public function setIsDirty(isDirty:Bool):Void {
		this._isDirty = isDirty;
	}

	public function writeBuffer():Void {
		if (this._isDirty) {
			if (_buffer == null) {
				_buffer = GLBufferManager.getInstance().createElementBuffer(new Int16Array(_array));

			} else {
				GLBufferManager.getInstance().updateElementBuffer(_buffer, new Int16Array(_array));
			}

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
