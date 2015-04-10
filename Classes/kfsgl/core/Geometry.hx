package kfsgl.core;

import kfsgl.utils.gl.GLBufferManager;
import kfsgl.utils.gl.VertexData;
import kfsgl.utils.gl.FloatVertexData;
import kfsgl.utils.gl.IndexData;
import kfsgl.errors.KFException;

typedef OffsetAndStride = {
	var offset: UInt;
	var stride: UInt;
}

class Geometry {

	// Default buffer names - !! NOTE !! identical to attribute names
	public static var bufferNames = {
		position: "position",
		normal: "normal",
		uv: "uv",
		color: "color"
	};

	// Number of elements per vertex
	public static var bufferVertexSizes = {
		position: 3,
		normal: 3,
		uv: 2,
		color: 4
	};

	// Buffers strides in bytes ?
//	public var bufferStrides = {
//		position: 3,
//		normal: 3,
//		uv: 2,
//		color: 4
//	};


// properties
	public var indices(get, set):IndexData;
	public var positions(get, set):FloatVertexData;
	public var normals(get, set):FloatVertexData;
	public var uvs(get, set):FloatVertexData;
	public var colors(get, set):FloatVertexData;
	public var vertexData(get, null):Map<String, VertexData>;
	public var vertexDataOffsets(get, null):Map<String, UInt>;
	public var isIndexed(get, null):Bool;
	public var isInterleaved(get, null):Bool;
	public var vertexCount(get, set):Int;
	public var indexCount(get, set):Int;

	// members
	public static var INTERLEAVED_BUFFER_NAME = "intlvd";
	private var _isInterleaved:Bool = false;
	private var _vertexData:Map<String, VertexData> = new Map<String, VertexData>(); // attribute name, raw data
	private var _vertexDataOffsets:Map<String, UInt> = new Map<String, UInt>(); // attribute name, offset
	private var _indexData:IndexData;
	private var _interleavedDataStructure:Map<String, OffsetAndStride>; // attribute name, OffsetAndStride
	private var _vertexCount:Int = -1;
	private var _inferredVertexCount:Int = 0;
	private var _indexCount:Int = -1;
	private var _inferredIndexCount:Int = 0;

	public static function create(isInterleaved:Bool = false, interleavedDataStructure:Map<String, OffsetAndStride> = null):Geometry {
		var object = new Geometry();

		if (object != null && !(object.init(isInterleaved, interleavedDataStructure))) {
			object = null;
		}

		return object;
	}

	public function init(isInterleaved:Bool = false, interleavedDataStructure:Map<String, OffsetAndStride> = null):Bool {
		this._isInterleaved = isInterleaved;
		this._interleavedDataStructure = interleavedDataStructure;

		if (this._isInterleaved) {
			if (_interleavedDataStructure == null) {
				throw new KFException("InterleavedGeometryBufferMustHaveStructure", "You must provide a structure for interleaved geometry buffer data");
			}

			// TODO
			//_bufferData.set(INTERLEAVED_BUFFER_NAME, new ...)

		} else {

			// Initialise offsets - can be changed by used later
			_vertexDataOffsets[bufferNames.position] = 0;
			_vertexDataOffsets[bufferNames.normal] = 0;
			_vertexDataOffsets[bufferNames.uv] = 0;
			_vertexDataOffsets[bufferNames.color] = 0;

		}


		return true;
	}

	public function new() {
	}


	/**
	 * Dispose of any opengl objects
	 */
	public function dispose():Void {
		// Dispose of vertex buffers
		for (vertexData in this._vertexData) {
			vertexData.dispose();
		}

		// Dispose of index buffer
		if (this._indexData != null) {
			this._indexData.dispose();
		}

	}

	/* ----------- Properties ----------- */


	public inline function get_indices():IndexData {
		return this.getIndexData();
	}


	public inline function set_indices(value:IndexData):IndexData {
		this.setIndexData(value);
		return value;
	}

	public inline function get_positions():FloatVertexData {
		return this.getPositionData();
	}


	public inline function set_positions(value:FloatVertexData):FloatVertexData {
		this.setPositionData(value);
		return value;
	}

	public inline function get_normals():FloatVertexData {
		return this.getNormalData();
	}


	public inline function set_normals(value:FloatVertexData):FloatVertexData {
		this.setNormalData(value);
		return value;
	}

	public inline function get_uvs():FloatVertexData {
		return this.getUVData();
	}


	public inline function set_uvs(value:FloatVertexData):FloatVertexData {
		this.setUVData(value);
		return value;
	}

	public inline function get_colors():FloatVertexData {
		return this.getColorData();
	}


	public inline function set_colors(value:FloatVertexData):FloatVertexData {
		this.setColorData(value);
		return value;
	}

	public inline function get_vertexData():Map<String, VertexData> {
		return this._vertexData;
	}

	public inline function get_vertexDataOffsets():Map<String, UInt> {
		return this._vertexDataOffsets;
	}

	public inline function get_isIndexed():Bool {
		return (this._indexData != null);
	}

	public inline function get_isInterleaved():Bool {
		return this._isInterleaved;
	}

	public inline function get_vertexCount():Int {
		return getVertexCount();
	}

	public inline function set_vertexCount(value:Int) {
		return this._vertexCount = value;
	}

	public inline function get_indexCount():Int {
		return getIndexCount();
	}

	public inline function set_indexCount(value:Int) {
		return this._indexCount = value;
	}


	/* --------- Implementation --------- */


	public inline function getIndexData():IndexData {
		return this._indexData;
	}

	public inline function setIndexData(data:IndexData):Void {
		this._indexData = data;
	}

	public inline function getVertexData(bufferName:String):VertexData {
		if (!_vertexData.exists(bufferName)) {
			throw new KFException("VertexBufferDoesNotExist", "The vertex buffer \"" + bufferName + "\" does not exist");
		}
		return _vertexData[bufferName];
	}

	public inline function setVertexData(bufferName:String, data:VertexData):Void {
		_vertexData[bufferName] = data;
	}

	public inline function getPositionData():FloatVertexData {
		if (_vertexData.exists(bufferNames.position)) {
			return cast _vertexData[bufferNames.position];
		}
		return null;
	}

	public inline function setPositionData(data:FloatVertexData):Void {
		_vertexData[bufferNames.position] = data;
	}

	public inline function getNormalData():FloatVertexData {
		if (_vertexData.exists(bufferNames.normal)) {
			return cast _vertexData[bufferNames.normal];
		}
		return null;
	}

	public inline function setNormalData(data:FloatVertexData):Void {
		_vertexData[bufferNames.normal] = data;
	}

	public inline function getUVData():FloatVertexData {
		if (_vertexData.exists(bufferNames.uv)) {
			return cast _vertexData[bufferNames.uv];
		}
		return null;
	}

	public inline function setUVData(data:FloatVertexData):Void {
		_vertexData[bufferNames.uv] = data;
	}

	public inline function getColorData():FloatVertexData {
		if (_vertexData.exists(bufferNames.color)) {
			return cast _vertexData[bufferNames.color];
		}
		return null;
	}

	public inline function setColorData(data:FloatVertexData):Void {
		_vertexData[bufferNames.color] = data;
	}

	public inline function createPositionData():FloatVertexData {
		return FloatVertexData.create(bufferNames.position, bufferVertexSizes.position);
	}

	public inline function createNormalData():FloatVertexData {
		return FloatVertexData.create(bufferNames.normal, bufferVertexSizes.normal);
	}

	public inline function createUVData():FloatVertexData {
		return FloatVertexData.create(bufferNames.uv, bufferVertexSizes.uv);
	}

	public inline function createColorData():FloatVertexData {
		return FloatVertexData.create(bufferNames.color, bufferVertexSizes.color);
	}

	public inline function createIndexData():IndexData {
		return IndexData.create();
	}

	public function getVertexCount():Int {
		if (this._vertexCount >= 0) {
			return this._vertexCount;

		} else {
			return this._inferredVertexCount;
		}
	}

	public function getIndexCount():Int {
		if (this._indexCount >= 0) {
			return this._indexCount;

		} else {
			return this._inferredIndexCount;
		}
	}

	/**
	 * Update any buffers that are dirty
	 */
	public function updateGeometry(bufferManager:GLBufferManager):Void {

		// Update vertex buffer attibutes
		var verticesUpdated:Bool = false;
		var vertexData = null;
		for (vertexDataIterator in this._vertexData) {

			// Write buffer (if needed)
			verticesUpdated = (verticesUpdated || vertexDataIterator.writeBuffer(bufferManager));
			vertexData = vertexDataIterator;
		}

		// Get vertex data count from vertex data
		if (verticesUpdated) {
			this._inferredVertexCount = vertexData.getVertexCount();
		}

		// Update indices buffer
		if (this._indexData != null) {
			if (this._indexData.writeBuffer(bufferManager)) {
				this._inferredIndexCount = this._indexData.getIndexCount();
			}
		}

	}
}
