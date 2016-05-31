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
class InterleavedVertexData extends FloatVertexData {

	private static var FLOAT_32_SIZE:Int = 4;

	// properties
	public var stride(get, null):Int;

		// members
	public static var INTERLEAVED_BUFFER_NAME = "interleaved";

	private var _stride:Int; // # Float
	private var _interleavedDataStructure:Map<String, VertexInfo>;


	public static function create(stride:Int, interleavedDataStructure:Map<String, VertexInfo>):InterleavedVertexData {
		var object = new InterleavedVertexData();

		if (object != null && !(object.initInterleaved(stride, interleavedDataStructure))) {
			object = null;
		}

		return object;
	}

	public static function createWithFixedCapacity(fixedCapacity:Int, stride:Int, interleavedDataStructure:Map<String, VertexInfo>):InterleavedVertexData {
		var object = new InterleavedVertexData();

		if (object != null && !(object.initInterleavedWithFixedCapacity(fixedCapacity, stride, interleavedDataStructure))) {
			object = null;
		}

		return object;
	}

	public function initInterleaved(stride:Int, interleavedDataStructure:Map<String, VertexInfo>):Bool {
		var retval;
		if ((retval = super.init(INTERLEAVED_BUFFER_NAME, stride))) {
			this._stride = stride;
			this._interleavedDataStructure = interleavedDataStructure;
		}

		return retval;
	}

	public function initInterleavedWithFixedCapacity(fixedCapacity:Int, stride:Int, interleavedDataStructure:Map<String, VertexInfo>):Bool {
		var retval;
		if ((retval = super.initWithFixedCapacity(fixedCapacity, INTERLEAVED_BUFFER_NAME, stride))) {
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

	override public function clone():VertexData {
		// Clone structure
		var clonedStructure = new Map<String, VertexInfo>();
		for (attributeName in this._interleavedDataStructure.keys()) {
			clonedStructure.set(attributeName, this._interleavedDataStructure.get(attributeName));
		}

		var clone = InterleavedVertexData.create(this._stride, clonedStructure);
		clone._fixedCapacity = this._fixedCapacity;
		clone._length = this._length;
		clone._isDirty = this.getLength() > 0;

		if (this._f32Array != null) {
			clone._f32Array = new Float32Array(this._f32Array);
		}

		if (this._array != null) {
			clone._array = this._array.copy();
		}

		return clone;
	}

	override public function getVertexCount():Int {
		return Std.int(this.getLength() / this._stride);
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

	public function attributeExists(attributeName:String):Bool {
		return _interleavedDataStructure.exists(attributeName);
	}

	public function getAttributeOffset(attributeName:String):Int {
		if (_interleavedDataStructure.exists(attributeName)) {

			var vertexInfo:VertexInfo = _interleavedDataStructure.get(attributeName);

			return vertexInfo.offset;
		}

		return -1;
	}


	public function bindAttribute(attributeName:String, attributeLocation:Int, bufferManager:GLBufferManager):Bool {

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

}
