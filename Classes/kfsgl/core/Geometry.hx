package kfsgl.core;

import kfsgl.utils.gl.VertexData;
import kfsgl.utils.gl.FloatVertexData;
import kfsgl.utils.gl.IndexData;
import kfsgl.errors.KFException;

typedef OffsetAndStride = {
	var offset: UInt;
	var stride: UInt;
}

class Geometry {

	public static var bufferNames = {
		position: "position",
		normal: "normal",
		uv: "uv",
		color: "color"
	};

	public static var bufferStrides = {
		position: 3,
		normal: 3,
		uv: 2,
		color: 4
	};


	// properties
	public var indices(get, set):IndexData;
	public var positions(get, set):FloatVertexData;
	public var normals(get, set):FloatVertexData;
	public var uvs(get, set):FloatVertexData;
	public var colors(get, set):FloatVertexData;

	// members
	public static var INTERLEAVED_BUFFER_NAME = "intlvd";
	private var _isInterleaved:Bool = false;
	private var _isIndexed:Bool = false;
	private var _vertexData:Map<String, VertexData> = new Map<String, VertexData>(); // attribute name, raw data
	private var _vertexDataStrides:Map<String, UInt> = new Map<String, UInt>(); // attribute name, stride
	private var _indexData:IndexData;
	private var _interleavedDataStructure:Map<String, OffsetAndStride>; // attribute name, OffsetAndStride

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
		}


		// Initialise strides - can be changed by used later
		_vertexDataStrides[bufferNames.position] = bufferStrides.position;
		_vertexDataStrides[bufferNames.normal] = bufferStrides.normal;
		_vertexDataStrides[bufferNames.uv] = bufferStrides.uv;
		_vertexDataStrides[bufferNames.color] = bufferStrides.color;

		return true;
	}

	public function new() {
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

	/* --------- Implementation --------- */


	public inline function getIndexData():IndexData {
		return _indexData;
	}

	public inline function setIndexData(data:IndexData):Void {
		_indexData = data;
		//data.isDirty = true;
	}

	public inline function getVertexData(bufferName:String):VertexData {
		if (!_vertexData.exists(bufferName)) {
			throw new KFException("VertexBufferDoesNotExist", "The vertex buffer \"" + bufferName + "\" does not exist");
		}
		return _vertexData[bufferName];
	}

	public inline function setVertexData(bufferName:String, data:VertexData):Void {
		_vertexData[bufferName] = data;
		//data.isDirty = true;
	}

	public inline function setVertexDataStride(bufferName:String, stride:UInt):Void {
		_vertexDataStrides[bufferName] = stride;
	}

	public inline function getPositionData():FloatVertexData {
		if (_vertexData[bufferNames.position] == null) {
			return null;
		}
		return cast _vertexData[bufferNames.position];
	}

	public inline function setPositionData(data:FloatVertexData):Void {
		_vertexData[bufferNames.position] = data;
		//data.isDirty = true;
	}

	public inline function getNormalData():FloatVertexData {
		if (_vertexData[bufferNames.normal] == null) {
			return null;
		}
		return cast _vertexData[bufferNames.normal];
	}

	public inline function setNormalData(data:FloatVertexData):Void {
		_vertexData[bufferNames.normal] = data;
		//data.isDirty = true;
	}

	public inline function getUVData():FloatVertexData {
		if (_vertexData[bufferNames.uv] == null) {
			return null;
		}
		return cast _vertexData[bufferNames.uv];
	}

	public inline function setUVData(data:FloatVertexData):Void {
		_vertexData[bufferNames.uv] = data;
		//data.isDirty = true;
	}

	public inline function getColorData():FloatVertexData {
		if (_vertexData[bufferNames.color] == null) {
			return null;
		}
		return cast _vertexData[bufferNames.color];
	}

	public inline function setColorData(data:FloatVertexData):Void {
		_vertexData[bufferNames.color] = data;
		//data.isDirty = true;
	}

}
