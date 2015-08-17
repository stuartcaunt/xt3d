package xt3d.gl.vertexdata;

import xt3d.utils.XT;
import xt3d.utils.errors.XTException;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import lime.graphics.opengl.GL;


typedef VertexInfo = {
	var name:String;
	var vertexSize:Int; // # Float
	var offset:Int; // # Float
};


/**
 * Interleaved data - only float type
 */
class InterleavedVertexData extends VertexData {

	private static var FLOAT_32_SIZE:Int = 4;

	// properties
	public var stride(get, null):Int;

	// members
	public static var INTERLEAVED_BUFFER_NAME = "interleaved";

	private var _f32Array:Float32Array = null;
	private var _fixedCapacity:Int = 0;
	private var _nextIndex:Int = 0;

	private var _array:Array<Float> = new Array<Float>();
	private var _stride:Int; // # Float
	private var _interleavedDataStructure:Map<String, VertexInfo>;


	public static function create(stride:Int, interleavedDataStructure:Map<String, VertexInfo>):InterleavedVertexData {
		var object = new InterleavedVertexData();

		if (object != null && !(object.init(stride, interleavedDataStructure))) {
			object = null;
		}

		return object;
	}

	public static function createWithFixedCapacity(fixedCapacity:Int, stride:Int, interleavedDataStructure:Map<String, VertexInfo>):InterleavedVertexData {
		var object = new InterleavedVertexData();

		if (object != null && !(object.initWithFixedCapacity(fixedCapacity, stride, interleavedDataStructure))) {
			object = null;
		}

		return object;
	}

	public function init(stride:Int, interleavedDataStructure:Map<String, VertexInfo>):Bool {
		var retval;
		if ((retval = super.initVertexData())) {
			this._stride = stride;
			this._interleavedDataStructure = interleavedDataStructure;
		}

		return retval;
	}

	public function initWithFixedCapacity(fixedCapacity:Int, stride:Int, interleavedDataStructure:Map<String, VertexInfo>):Bool {
		var retval;
		if ((retval = super.initVertexData())) {
			this._f32Array = new Float32Array(fixedCapacity);
			this._fixedCapacity = fixedCapacity;
			this._stride = stride;
			this._interleavedDataStructure = interleavedDataStructure;
		}

		return retval;
	}

	public function new() {
		super();
	}



	/* ----------- Properties ----------- */

	public inline function get_stride():Int {
		return this._stride;
	}


	/* --------- Implementation --------- */


	override public function getVertexCount():Int {
		return Std.int(this.getLength() / this._stride);
	}

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

	public function setAttributeSize(attributeName:String, size:Int):Void {
		if (_interleavedDataStructure.exists(attributeName)) {

			var vertexInfo:VertexInfo = _interleavedDataStructure.get(attributeName);

			vertexInfo.vertexSize = size;
		}
	}

	public function setAttributeOffset(attributeName:String, offset:Int):Void {
		if (_interleavedDataStructure.exists(attributeName)) {

			var vertexInfo:VertexInfo = _interleavedDataStructure.get(attributeName);

			vertexInfo.offset = offset;
		}
	}

	public function bindToAttribute(attributeName:String, attributeLocation:Int, bufferManager:GLBufferManager):Bool {

		// Check attribute exists in structure
		if (_interleavedDataStructure.exists(attributeName)) {

			// Get the interleaved element
			var vertexInfo:VertexInfo = _interleavedDataStructure.get(attributeName);

			// Verify that the attribute is really used (offset = -1 if not)
			if (vertexInfo.offset >= 0) {
				// Bind the buffer
				bufferManager.setVertexBuffer(this._buffer);

				// attach buffer to attribute
				GL.vertexAttribPointer(attributeLocation, vertexInfo.vertexSize, GL.FLOAT, false,
				this._stride * FLOAT_32_SIZE, vertexInfo.offset * FLOAT_32_SIZE);

				return true;
			}
		}

		return false;
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
				throw new XTException("IndexOutOfBounds", "Cannot pop from empty array");
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
			throw new XTException("IndexOutOfBounds", "The index " + index + " is outside the fixed capacity of " + this._fixedCapacity);
		}
		if (updateNextIndex && index > this._nextIndex) {
			this._nextIndex = index;
		}
	}

}
