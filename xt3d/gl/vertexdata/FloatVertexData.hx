package xt3d.gl.vertexdata;

import xt3d.utils.errors.XTException;
import xt3d.gl.vertexdata.PrimitiveVertexData;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import lime.graphics.opengl.GL;

class FloatVertexData extends PrimitiveVertexData {

	// properties
	public var float32Array(get, null):Float32Array;
//	public var arrayLength(get, set):Int;

	// members
	private var _f32Array:Float32Array = null;
	private var _fixedCapacity:Int = 0;
	private var _length:Int = 0;
	
	private var _array:Array<Float> = new Array<Float>();

	public static function create(attributeName:String, vertexSize:Int):FloatVertexData {
		var object = new FloatVertexData();

		if (object != null && !(object.init(attributeName, vertexSize))) {
			object = null;
		}

		return object;
	}

	public static function createWithArray(attributeName:String, array:Array<Float>, vertexSize:Int):FloatVertexData {
		var object = new FloatVertexData();

		if (object != null && !(object.initWithArray(attributeName, array, vertexSize))) {
			object = null;
		}

		return object;
	}

	public static function createWithFixedCapacity(fixedCapacity:Int, attributeName:String, vertexSize:Int):FloatVertexData {
		var object = new FloatVertexData();

		if (object != null && !(object.initWithFixedCapacity(fixedCapacity, attributeName, vertexSize))) {
			object = null;
		}

		return object;
	}

	public function init(attributeName:String, vertexSize:Int):Bool {
		var retval;
		if ((retval = super.initPrimitiveVertexData(attributeName, vertexSize))) {
		}

		return retval;
	}

	public function initWithArray(attributeName:String, array:Array<Float>, vertexSize:Int):Bool {
		var retval;
		if ((retval = super.initPrimitiveVertexData(attributeName, vertexSize))) {
			this._array = array;
		}

		return retval;
	}

	public function initWithFixedCapacity(fixedCapacity:Int, attributeName:String, vertexSize:Int):Bool {
		var retval;
		if ((retval = super.initPrimitiveVertexData(attributeName, vertexSize))) {
			this._f32Array = new Float32Array(fixedCapacity);
			this._fixedCapacity = fixedCapacity;
		}

		return retval;
	}


	public function new() {
		super();
	}

	/* ----------- Properties ----------- */

	function get_float32Array():Float32Array {
		return this._f32Array;
	}

//	function get_arrayLength():Int {
//		return this._length;
//	}
//
//	function set_arrayLength(value:Int) {
//		return this._length = value;
//	}

	/* --------- Implementation --------- */



	// Number of elements
	override public function getLength():Int {
		if (this._f32Array != null) {
			return this._length;
		} else {
			return this._array.length;
		}
	}


	override public function getBufferData():ArrayBufferView {
		if (this._f32Array != null) {
			return this._f32Array;
		} else {
			return new Float32Array(this._array);
		}
	}

	override public function bindToAttribute(attributeLocation:Int, bufferManager:GLBufferManager):Void {
		// Bind the buffer
		bufferManager.setVertexBuffer(this._buffer);

		// attach buffer to attribute
		GL.vertexAttribPointer(attributeLocation, this._vertexSize, GL.FLOAT, false, 0, 0);
	}


	public inline function set(index:Int, value:Float):Void {
		if (this._f32Array != null) {
			this.handleIndex(index, true);
			this._f32Array[index] = value;

		} else {
			this._array[index] = value;
		}
		this._isDirty = true;
	}

	public inline function get(index:Int):Float {
		if (this._f32Array != null) {
			this.handleIndex(index, false);
			return this._f32Array[index];

		} else {
			return _array[index];
		}
	}

	public inline function push(value:Float):Void {
		if (this._f32Array != null) {
			this.handleIndex(this._length, false);
			this._f32Array[this._length++] = value;

		} else {
			_array.push(value);
		}
		this._isDirty = true;
	}

	public inline function pop():Float {
		if (this._f32Array != null) {
			if (this._length <= 0) {
				throw new XTException("IndexOutOfBounds", "Cannot pop from empty array");
			}
			this._length--;

			this._isDirty = true;
			return this._f32Array[this._length];

		} else {
			this._isDirty = true;
			return _array.pop();
		}
	}



	private inline function handleIndex(index:Int, updateNextIndex:Bool):Void {
		if (index >= this._fixedCapacity) {
			throw new XTException("IndexOutOfBounds", "The index " + index + " is outside the fixed capacity of " + this._fixedCapacity);
		}
		if (updateNextIndex && index > (this._length - 1)) {
			this._length = index + 1;
		}
	}

}
