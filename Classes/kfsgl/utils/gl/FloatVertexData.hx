package kfsgl.utils.gl;

import openfl.utils.ArrayBufferView;
import openfl.utils.IMemoryRange;
import openfl.utils.Float32Array;
import openfl.gl.GL;

class FloatVertexData extends VertexData {

#if use_float32array
	private var _f32Array:Float32Array = new Float32Array(0);
	private var _capacity:Int = 0;
	private var _nextIndex:Int = -1;
#else
	private var _array:Array<Float> = new Array<Float>();
#end

	public static function create(attributeName:String):FloatVertexData {
		var object = new FloatVertexData();

		if (object != null && !(object.init(attributeName))) {
			object = null;
		}

		return object;
	}

#if use_float32array
#else
	public static function createWithArray(attributeName:String, array:Array<Float>):FloatVertexData {
		var object = new FloatVertexData();

		if (object != null && !(object.initWithArray(attributeName, array))) {
			object = null;
		}

		return object;
	}
#end

	override public function init(attributeName:String):Bool {
		var retval;
		if ((retval = super.init(attributeName))) {

		}

		return retval;
	}

#if use_float32array
#else
	public function initWithArray(attributeName:String, array:Array<Float>):Bool {
		var retval;
		if ((retval = super.init(attributeName))) {
			this._array = array;

		}

		return retval;
	}
#end



	public function new() {
		super();
	}

	// Number of elements
	override public function getLength():Int {
#if use_float32array
		return this._f32Array.length >> 2;
#else
		return this._array.length;
#end
	}

	override public function getByteLength():Int {
#if use_float32array
		return this._f32Array.length;
#else
		return getLength() * 4;
#end
	}

	override public function getBufferData():ArrayBufferView {
#if use_float32array
		return _f32Array;
#else
		return new Float32Array(_array);
#end
	}



	public inline function set(index:Int, value:Float):Void {
#if use_float32array
		handleArraySize(index + 1);
		_f32Array.buffer.position = index << 2;
		_f32Array.writeFloat(value);
		//_f32Array.setFloat32(index, value);
		_nextIndex = index + 1;
		this._isDirty = true;
#else
		_array[index] = value;
		this._isDirty = true;
#end
	}

	public inline function get(index:Int):Float {
#if use_float32array
		//return _f32Array.getFloat32(index);
		return 0;
#else
		return _array[index];
#end
	}

	public inline function push(value:Float):Void {
#if use_float32array
		handleArraySize(_nextIndex + 1);
//_f32Array.setFloat32(_nextIndex, value);
		_nextIndex++;
#else
		_array.push(value);
		this._isDirty = true;
#end
	}

	public inline function pop():Float {
#if use_float32array
		var value = this.get(_nextIndex - 1);
		handleArraySize(_nextIndex);
		_nextIndex--;

		return value;
#else
		return _array.pop();
		this._isDirty = true;
#end
	}



#if use_float32array
	private function handleArraySize(size:Int):Void {
		if (this._capacity <= size) {

			// Calculate new size
			var newCapacity = (this._capacity == 0) ? 1 : this._capacity << 1;
			while (newCapacity <= size) {
				newCapacity = this._capacity << 1;
			}

			// create new array of increased size
			var newFloatArray:Float32Array = new Float32Array(newCapacity);

			// Copy old data
			newFloatArray.set(_f32Array);

			// Set new array
			this._capacity = newCapacity;
			this._f32Array = newFloatArray;

		} else if (this._capacity >= size << 1) {

			// Calculate new size
			var newCapacity = this._capacity;
			while (newCapacity >= size << 1) {
				newCapacity = this._capacity >> 1;
			}

			// create new array of decreased size
			var newFloatArray:Float32Array = new Float32Array(newCapacity);

			// Copy old data
			newFloatArray.set(_f32Array.subarray(0, size));

			// Set new array
			this._capacity = newCapacity;
			this._f32Array = newFloatArray;
		}
	}
#end

}
