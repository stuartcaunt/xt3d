package kfsgl.utils.gl;

/**
 * Used to mask if we immediately use:
 *  - an ArrayBuffer to hold vertex data, avoiding copying data but maybe slower access
 *  - a standard Array object, doubling data usage but maybe easier access
 **/
import openfl.utils.ArrayBufferView;
import openfl.utils.IMemoryRange;
import openfl.utils.Float32Array;
import openfl.gl.GL;


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

	public function init(stride:Int, interleavedDataStructure:Map<String, VertexInfo>):Bool {
		var retval;
		if ((retval = super.initVertexData())) {
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
		return this._array.length;
	}

	override public function getBufferData():ArrayBufferView {
		return new Float32Array(this._array);
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
		_array[index] = value;
		this._isDirty = true;
	}

	public inline function get(index:Int):Float {
		return _array[index];
	}

	public inline function push(value:Float):Void {
		_array.push(value);
		this._isDirty = true;
	}

	public inline function pop():Float {
		return _array.pop();
		this._isDirty = true;
	}



}
