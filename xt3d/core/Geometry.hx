package xt3d.core;

import xt3d.utils.XTObject;
import xt3d.gl.vertexdata.UByteVertexData;
import xt3d.gl.vertexdata.PrimitiveVertexData;
import xt3d.gl.GLBufferManager;
import xt3d.gl.vertexdata.VertexData;
import xt3d.gl.vertexdata.FloatVertexData;
import xt3d.gl.vertexdata.InterleavedVertexData;
import xt3d.gl.vertexdata.IndexData;
import xt3d.utils.errors.XTException;


class Geometry extends XTObject {

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

	public static inline var MAX_INDEXED_VERTICES:Int = 1 << 16;

	private static var defaultInterleavedStructure:Map<String, VertexInfo> = [
		bufferNames.position => { name: bufferNames.position, vertexSize: bufferVertexSizes.position, offset: -1}, // not used by default
		bufferNames.normal => { name: bufferNames.normal, vertexSize: bufferVertexSizes.normal, offset: -1}, // not used by default
		bufferNames.uv => { name: bufferNames.uv, vertexSize: bufferVertexSizes.uv, offset: -1}, // not used by default
		bufferNames.color => { name: bufferNames.color, vertexSize: bufferVertexSizes.color, offset: -1} // not used by default
	];


	// properties
	public var indices(get, set):IndexData;
	public var positions(get, set):FloatVertexData;
	public var normals(get, set):FloatVertexData;
	public var uvs(get, set):FloatVertexData;
	public var floatColors(get, set):FloatVertexData;
	public var byteColors(get, set):UByteVertexData;
	public var allVertexData(get, set):Map<String, PrimitiveVertexData>;
	public var interleavedVertexData(get, set):InterleavedVertexData;
	public var isIndexed(get, null):Bool;
	public var vertexCount(get, set):Int;
	public var indexCount(get, set):Int;

	// members
	private var _vertexData:Map<String, PrimitiveVertexData> = new Map<String, PrimitiveVertexData>(); // attribute name, raw data
	private var _interleavedVertexData:InterleavedVertexData = null;
	private var _indexData:IndexData;
	private var _vertexCount:Int = -1;
	private var _inferredVertexCount:Int = 0;
	private var _indexCount:Int = -1;
	private var _inferredIndexCount:Int = 0;

	public static function create():Geometry {
		var object = new Geometry();

		if (object != null && !(object.initGeometry())) {
			object = null;
		}

		return object;
	}

	public function initGeometry():Bool {

		return true;
	}

	public function new() {
		super();
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

	public inline function get_floatColors():FloatVertexData {
		return this.getFloatColorData();
	}

	public inline function set_floatColors(value:FloatVertexData):FloatVertexData {
		this.setFloatColorData(value);
		return value;
	}

	public inline function get_byteColors():UByteVertexData {
		return this.getByteColorData();
	}

	public inline function set_byteColors(value:UByteVertexData):UByteVertexData {
		this.setByteColorData(value);
		return value;
	}

	public inline function get_allVertexData():Map<String, PrimitiveVertexData> {
		return this._vertexData;
	}

	public inline function set_allVertexData(vertexData:Map<String, PrimitiveVertexData>):Map<String, PrimitiveVertexData> {
		this.setAllVertexData(vertexData);
		return this._vertexData;
	}

	public inline function get_interleavedVertexData():InterleavedVertexData {
		return this._interleavedVertexData;
	}

	public inline function set_interleavedVertexData(interleavedVertexData:InterleavedVertexData):InterleavedVertexData {
		this.setInterleavedVertexData(interleavedVertexData);
		return this._interleavedVertexData;
	}

	public inline function get_isIndexed():Bool {
		return (this._indexData != null);
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


	public inline function cloneDefaultInterleavedStructure():Map<String, VertexInfo> {
		var clone = new Map<String, VertexInfo>();
		for (vertexInfo in defaultInterleavedStructure) {
			clone.set(vertexInfo.name, vertexInfo);
		}

		return clone;
	}

	public inline function getIndexData():IndexData {
		return this._indexData;
	}

	public inline function setIndexData(data:IndexData):Void {
		this._indexData = data;
	}

	public inline function getVertexData(bufferName:String):PrimitiveVertexData {
		if (!_vertexData.exists(bufferName)) {
			throw new XTException("VertexBufferDoesNotExist", "The vertex buffer \"" + bufferName + "\" does not exist");
		}
		return _vertexData[bufferName];
	}

	public inline function setVertexData(bufferName:String, data:PrimitiveVertexData):Void {
		this._vertexData[bufferName] = data;
	}

	public inline function setAllVertexData(vertexData:Map<String, PrimitiveVertexData>):Void {
		this._vertexData = vertexData;
	}

	public inline function getAllVertexData():Map<String, PrimitiveVertexData> {
		return this._vertexData;
	}

	public inline function getInterleavedVertexData():InterleavedVertexData {
		return this._interleavedVertexData;
	}

	public inline function setInterleavedVertexData(data:InterleavedVertexData):Void {
		this._interleavedVertexData = data;
	}

	public inline function getPositionData():FloatVertexData {
		return cast _vertexData[bufferNames.position];
	}

	public inline function setPositionData(data:FloatVertexData):Void {
		this._vertexData[bufferNames.position] = data;
	}

	public inline function getNormalData():FloatVertexData {
		return cast _vertexData[bufferNames.normal];
	}

	public inline function setNormalData(data:FloatVertexData):Void {
		this._vertexData[bufferNames.normal] = data;
	}

	public inline function getUVData():FloatVertexData {
		return cast _vertexData[bufferNames.uv];
	}

	public inline function setUVData(data:FloatVertexData):Void {
		this._vertexData[bufferNames.uv] = data;
	}

	public inline function getFloatColorData():FloatVertexData {
		return cast _vertexData[bufferNames.color];
	}

	public inline function setFloatColorData(data:FloatVertexData):Void {
		this._vertexData[bufferNames.color] = data;
	}

	public inline function getByteColorData():UByteVertexData {
		return cast _vertexData[bufferNames.color];
	}

	public inline function setByteColorData(data:UByteVertexData):Void {
		this._vertexData[bufferNames.color] = data;
	}

	public inline function getCustomFloatData(bufferName:String):FloatVertexData {
		return cast this._vertexData[bufferName];
	}

	public inline function setCustomFloatData(bufferName:String, data:FloatVertexData):Void {
		this._vertexData[bufferName] = data;
	}

	public inline function getCustomByteData(bufferName:String):UByteVertexData {
		return cast this._vertexData[bufferName];
	}

	public inline function setCustomByteData(bufferName:String, data:UByteVertexData):Void {
		this._vertexData[bufferName] = data;
	}

	public inline function createInterleavedVertexData(stride:Int, interleavedDataStructure:Map<String, VertexInfo> = null, fixedCapacity:Int = 0):InterleavedVertexData {
		if (interleavedDataStructure == null) {
			interleavedDataStructure = this.cloneDefaultInterleavedStructure();
		}
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = InterleavedVertexData.createWithFixedCapacity(fixedCapacity, stride, interleavedDataStructure);

		} else {
			vertexData = InterleavedVertexData.create(stride, interleavedDataStructure);
		}
		this.setInterleavedVertexData(vertexData);
		return vertexData;
	}

	public inline function createPositionData(fixedCapacity:Int = 0):FloatVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = FloatVertexData.createWithFixedCapacity(fixedCapacity, bufferNames.position, bufferVertexSizes.position);

		} else {
			vertexData = FloatVertexData.create(bufferNames.position, bufferVertexSizes.position);
		}
		this.setPositionData(vertexData);
		return vertexData;
	}

	public inline function createNormalData(fixedCapacity:Int = 0):FloatVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = FloatVertexData.createWithFixedCapacity(fixedCapacity, bufferNames.normal, bufferVertexSizes.normal);

		} else {
			vertexData = FloatVertexData.create(bufferNames.normal, bufferVertexSizes.normal);
		}
		this.setNormalData(vertexData);
		return vertexData;
	}

	public inline function createUVData(fixedCapacity:Int = 0):FloatVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = FloatVertexData.createWithFixedCapacity(fixedCapacity, bufferNames.uv, bufferVertexSizes.uv);

		} else {
			vertexData = FloatVertexData.create(bufferNames.uv, bufferVertexSizes.uv);
		}
		this.setUVData(vertexData);
		return vertexData;
	}

	public inline function createFloatColorData(fixedCapacity:Int = 0):FloatVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = FloatVertexData.createWithFixedCapacity(fixedCapacity, bufferNames.color, bufferVertexSizes.color);

		} else {
			vertexData = FloatVertexData.create(bufferNames.color, bufferVertexSizes.color);
		}
		this.setFloatColorData(vertexData);
		return vertexData;
	}

	public inline function createByteColorData(fixedCapacity:Int = 0):UByteVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = UByteVertexData.createWithFixedCapacity(fixedCapacity, bufferNames.color, bufferVertexSizes.color);

		} else {
			vertexData = UByteVertexData.create(bufferNames.color, bufferVertexSizes.color);
		}
		this.setByteColorData(vertexData);
		return vertexData;
	}

	public inline function createCustomFloatData(bufferName:String, bufferVertexSize:Int, fixedCapacity:Int = 0):FloatVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = FloatVertexData.createWithFixedCapacity(fixedCapacity, bufferName, bufferVertexSize);

		} else {
			vertexData = FloatVertexData.create(bufferName, bufferVertexSize);
		}
		this.setCustomFloatData(bufferName, vertexData);
		return vertexData;
	}

	public inline function createCustomByteData(bufferName:String, bufferVertexSize:Int, fixedCapacity:Int = 0):UByteVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = UByteVertexData.createWithFixedCapacity(fixedCapacity, bufferName, bufferVertexSize);

		} else {
			vertexData = UByteVertexData.create(bufferName, bufferVertexSize);
		}
		this.setCustomByteData(bufferName, vertexData);
		return vertexData;
	}

	public inline function createIndexData(fixedCapacity:Int = 0):IndexData {
		var indexData = null;
		if (fixedCapacity > 0) {
			indexData = IndexData.createWithFixedCapacity(fixedCapacity);

		} else {
			indexData = IndexData.create();
		}
		this.setIndexData(indexData);
		return indexData;
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
			verticesUpdated = (vertexDataIterator.writeBuffer(bufferManager) || verticesUpdated);
			vertexData = vertexDataIterator;
		}

		// Update interleaved vertex buffer data
		if (this._interleavedVertexData != null) {
			verticesUpdated = (this._interleavedVertexData.writeBuffer(bufferManager) || verticesUpdated);
		}

		// Get vertex data count from vertex data
		if (verticesUpdated) {
			if (this._interleavedVertexData != null) {
				this._inferredVertexCount = this._interleavedVertexData.getVertexCount();

			} else {
				this._inferredVertexCount = vertexData.getVertexCount();
			}
		}

		// Update indices buffer
		if (this._indexData != null) {
			if (this._indexData.writeBuffer(bufferManager)) {
				this._inferredIndexCount = this._indexData.getIndexCount();
			}
		}
	}


	public function bindVertexBufferToAttribute(attributeName:String, attributeLocation:Int, bufferManager:GLBufferManager):Bool {
		// Check for interleaved attribute first
		if ((this._interleavedVertexData != null) && this._interleavedVertexData.bindToAttribute(attributeName, attributeLocation, bufferManager)) {
			// Interleaved buffer has been bound to program attribute
			return true;
		}

		// Otherwise look for individual buffer
		if (this._vertexData.exists(attributeName)) {
			var vertexData = this._vertexData.get(attributeName);

			// Bind to attribute location for individual buffer
			vertexData.bindToAttribute(attributeLocation, bufferManager);

			return true;
		}

		return false;
	}

}
