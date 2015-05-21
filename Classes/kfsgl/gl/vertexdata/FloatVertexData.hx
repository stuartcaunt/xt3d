package kfsgl.gl.vertexdata;

import kfsgl.utils.errors.KFException;
import kfsgl.gl.vertexdata.PrimitiveVertexData;
import openfl.utils.ArrayBufferView;
import openfl.utils.IMemoryRange;
import openfl.utils.Float32Array;
import openfl.gl.GL;

class FloatVertexData extends PrimitiveVertexData {

	// properties

	// members
	private var _f32Array:Float32Array = null;
	private var _fixedCapacity:Int = 0;
	private var _nextIndex:Int = 0;
	
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


	/* --------- Implementation --------- */



	// Number of elements
	override public function getLength():Int {
		if (this._f32Array != null) {
			return this._nextIndex;
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
			this._f32Array[this._nextIndex++] = value;

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
			this.handleIndex(this._nextIndex, false);
			this._f32Array[this._nextIndex++] = value;

		} else {
			_array.push(value);
		}
		this._isDirty = true;
	}

	public inline function pop():Float {
		if (this._f32Array != null) {
			if (this._nextIndex <= 0) {
				throw new KFException("IndexOutOfBounds", "Cannot pop from empty array");
			}
			this._nextIndex--;

			this._isDirty = true;
			return this._f32Array[this._nextIndex];

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
