package xt3d.geometry;

import xt3d.gl.XTGL;
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
		color: "color",
		tangent: "tangent"
	};

	// Number of elements per vertex
	public static var bufferVertexSizes = {
		position: 3,
		normal: 3,
		uv: 2,
		color: 4,
		tangent: 3
	};

	public static inline var MAX_INDEXED_VERTICES:Int = 1 << 16;

	private static var defaultInterleavedStructure:Map<String, VertexInfo> = [
		bufferNames.position => { name: bufferNames.position, vertexSize: bufferVertexSizes.position, offset: -1}, // not used by default
		bufferNames.normal => { name: bufferNames.normal, vertexSize: bufferVertexSizes.normal, offset: -1}, // not used by default
		bufferNames.uv => { name: bufferNames.uv, vertexSize: bufferVertexSizes.uv, offset: -1}, // not used by default
		bufferNames.color => { name: bufferNames.color, vertexSize: bufferVertexSizes.color, offset: -1}, // not used by default
		bufferNames.tangent => { name: bufferNames.tangent, vertexSize: bufferVertexSizes.tangent, offset: -1} // not used by default
	];


	// properties
	public var indices(get, set):IndexData;
	public var positions(get, set):FloatVertexData;
	public var normals(get, set):FloatVertexData;
	public var uvs(get, set):FloatVertexData;
	public var tangents(get, set):FloatVertexData;
	public var floatColors(get, set):FloatVertexData;
	public var byteColors(get, set):UByteVertexData;
	public var allVertexData(get, set):Map<String, PrimitiveVertexData>;
	public var interleavedVertexData(get, set):InterleavedVertexData;
	public var isIndexed(get, null):Bool;
	public var vertexCount(get, set):Int;
	public var indexCount(get, set):Int;
	public var drawMode(get, set):Int;

	// members
	private var _vertexData:Map<String, PrimitiveVertexData> = new Map<String, PrimitiveVertexData>(); // attribute name, raw data
	private var _interleavedVertexData:InterleavedVertexData = null;
	private var _indexData:IndexData;
	private var _vertexCount:Int = -1;
	private var _inferredVertexCount:Int = 0;
	private var _indexCount:Int = -1;
	private var _inferredIndexCount:Int = 0;
	private var _drawMode:Int = XTGL.GL_TRIANGLES;

	public static function create(drawMode:Int = 0):Geometry {
		var object = new Geometry();

		if (object != null && !(object.initGeometry(drawMode))) {
			object = null;
		}

		return object;
	}

	public function initGeometry(drawMode:Int = 0):Bool {
		if (drawMode == 0) {
			drawMode = XTGL.GL_TRIANGLES;
		}
		this._drawMode = drawMode;

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

	public inline function get_tangents():FloatVertexData {
		return this.getTangentData();
	}

	public inline function set_tangents(value:FloatVertexData):FloatVertexData {
		this.setTangentData(value);
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

	function get_drawMode():Int {
		return this._drawMode;
	}

	function set_drawMode(value:Int) {
		return this._drawMode = value;
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

	public inline function getTangentData():FloatVertexData {
		return cast _vertexData[bufferNames.tangent];
	}

	public inline function setTangentData(data:FloatVertexData):Void {
		this._vertexData[bufferNames.tangent] = data;
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

	public inline function createTangentData(fixedCapacity:Int = 0):FloatVertexData {
		var vertexData = null;
		if (fixedCapacity > 0) {
			vertexData = FloatVertexData.createWithFixedCapacity(fixedCapacity, bufferNames.tangent, bufferVertexSizes.tangent);

		} else {
			vertexData = FloatVertexData.create(bufferNames.tangent, bufferVertexSizes.tangent);
		}
		this.setTangentData(vertexData);
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
		if ((this._interleavedVertexData != null) && this._interleavedVertexData.bindAttribute(attributeName, attributeLocation, bufferManager)) {
			// Interleaved buffer has been bound to program attribute
			return true;
		}

		// Otherwise look for individual buffer
		if (this._vertexData.exists(attributeName)) {
			var vertexData = this._vertexData.get(attributeName);

			// Verify that vertex data has data
			if (vertexData.length > 0) {
				// Bind to attribute location for individual buffer
				vertexData.bindToAttribute(attributeLocation, bufferManager);

				return true;
			}
		}

		return false;
	}

	public function isEmpty():Bool {
		// Verify that we have vertices or indices to render
		var isEmpty:Bool = true;
		for (vertexData in this._vertexData) {
			isEmpty = isEmpty && (vertexData.length == 0);
		}

		if (this._interleavedVertexData != null) {
			isEmpty = isEmpty && (this._interleavedVertexData.length == 0);
		}

		if (this._indexData != null) {
			isEmpty = isEmpty && (this._indexData.length == 0);
		}

		return isEmpty;
	}

	public function calculateTangents(interleave:Bool = true):Void {
		var positionVertexData:FloatVertexData = null;
		var uvVertexData:FloatVertexData = null;
		var tangentVertexData:FloatVertexData = null;

		var positionOffset = 0;
		var uvOffset = 0;
		var tangentOffset = 0;
		var positionStride = 3;
		var uvStride = 2;
		var tangentStride = 3;

		if (this._interleavedVertexData != null) {
			// Check that we have uv, normal and tangent data specified
 			positionOffset = this._interleavedVertexData.getAttributeOffset(bufferNames.position);
			uvOffset = this._interleavedVertexData.getAttributeOffset(bufferNames.uv);
			positionStride = this._interleavedVertexData.stride;
			uvStride = this._interleavedVertexData.stride;

			if (positionOffset == -1 || uvOffset == -1) {
				throw new XTException("CannotGenerateTangentData", "Cannot generate tanget vertex data without coherent interleaved data");
			}

			positionVertexData = this._interleavedVertexData;
			uvVertexData = this._interleavedVertexData;

			if (tangentOffset == -1 || !interleave) {
				// Create new buffer for tangent data
				var tangentDataSize = Std.int(positionVertexData.length / positionStride * 3);
				tangentVertexData = this.createTangentData(tangentDataSize);

			} else {
				// Use interleaved data
				tangentOffset = this._interleavedVertexData.getAttributeOffset(bufferNames.tangent);
				tangentStride = this._interleavedVertexData.stride;
				tangentVertexData = this._interleavedVertexData;
			}


		} else {
			positionVertexData = this.getPositionData();
			uvVertexData = this.getUVData();

			if (positionVertexData == null || uvVertexData == null) {
				throw new XTException("CannotGenerateTangentData", "Cannot generate tanget vertex data without coherent interleaved data");
			}

			// Create new buffer for tangent data
			tangentVertexData = this.createTangentData(positionVertexData.length);
		}

		var nVertices = Std.int(positionVertexData.length / positionStride);
		var nTriangles = Std.int(nVertices / 3);
		if (this._indexData != null) {
			nTriangles = Std.int(this._indexData.length / 3);
		}

		// Initialise tangent values
		for (iv in 0 ... nVertices) {
			var index0 = (this._indexData != null) ? this._indexData.get(iv + 0) : iv + 0;

			tangentVertexData.set(index0 * tangentStride + tangentOffset + 0, 0.0);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 1, 0.0);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 2, 0.0);
		}

		for (it in 0 ... nTriangles) {
			var i = it * 3;
			var index0 = (this._indexData != null) ? this._indexData.get(i + 0) : i + 0;
			var index1 = (this._indexData != null) ? this._indexData.get(i + 1) : i + 1;
			var index2 = (this._indexData != null) ? this._indexData.get(i + 2) : i + 2;

			var px0 = positionVertexData.get(index0 * positionStride + positionOffset + 0);
			var py0 = positionVertexData.get(index0 * positionStride + positionOffset + 1);
			var pz0 = positionVertexData.get(index0 * positionStride + positionOffset + 2);
			var px1 = positionVertexData.get(index1 * positionStride + positionOffset + 0);
			var py1 = positionVertexData.get(index1 * positionStride + positionOffset + 1);
			var pz1 = positionVertexData.get(index1 * positionStride + positionOffset + 2);
			var px2 = positionVertexData.get(index2 * positionStride + positionOffset + 0);
			var py2 = positionVertexData.get(index2 * positionStride + positionOffset + 1);
			var pz2 = positionVertexData.get(index2 * positionStride + positionOffset + 2);

			var u0 = uvVertexData.get(index0 * uvStride + uvOffset + 0);
			var v0 = uvVertexData.get(index0 * uvStride + uvOffset + 1);
			var u1 = uvVertexData.get(index1 * uvStride + uvOffset + 0);
			var v1 = uvVertexData.get(index1 * uvStride + uvOffset + 1);
			var u2 = uvVertexData.get(index2 * uvStride + uvOffset + 0);
			var v2 = uvVertexData.get(index2 * uvStride + uvOffset + 1);

			var tx0 = tangentVertexData.get(index0 * tangentStride + tangentOffset + 0);
			var ty0 = tangentVertexData.get(index0 * tangentStride + tangentOffset + 1);
			var tz0 = tangentVertexData.get(index0 * tangentStride + tangentOffset + 2);
			var tx1 = tangentVertexData.get(index1 * tangentStride + tangentOffset + 0);
			var ty1 = tangentVertexData.get(index1 * tangentStride + tangentOffset + 1);
			var tz1 = tangentVertexData.get(index1 * tangentStride + tangentOffset + 2);
			var tx2 = tangentVertexData.get(index2 * tangentStride + tangentOffset + 0);
			var ty2 = tangentVertexData.get(index2 * tangentStride + tangentOffset + 1);
			var tz2 = tangentVertexData.get(index2 * tangentStride + tangentOffset + 2);

			var ex1 = px1 - px0;
			var ey1 = py1 - py0;
			var ez1 = pz1 - pz0;
			var ex2 = px2 - px0;
			var ey2 = py2 - py0;
			var ez2 = pz2 - pz0;

			var du1 = u1 - u0;
			var dv1 = v1 - v0;
			var du2 = u2 - u0;
			var dv2 = v2 - v0;

			var f = 1.0 / (du1 * dv2 - du2 * dv1);

			var tangentX = f * (dv2 * ex1 - dv1 * ex2);
			var tangentY = f * (dv2 * ey1 - dv1 * ey2);
			var tangentZ = f * (dv2 * ez1 - dv1 * ez2);

			tangentVertexData.set(index0 * tangentStride + tangentOffset + 0, tx0 + tangentX);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 1, ty0 + tangentY);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 2, tz0 + tangentZ);
			tangentVertexData.set(index1 * tangentStride + tangentOffset + 0, tx1 + tangentX);
			tangentVertexData.set(index1 * tangentStride + tangentOffset + 1, ty1 + tangentY);
			tangentVertexData.set(index1 * tangentStride + tangentOffset + 2, tz1 + tangentZ);
			tangentVertexData.set(index2 * tangentStride + tangentOffset + 0, tx2 + tangentX);
			tangentVertexData.set(index2 * tangentStride + tangentOffset + 1, ty2 + tangentY);
			tangentVertexData.set(index2 * tangentStride + tangentOffset + 2, tz2 + tangentZ);
		}

		// Normalise tangents
		for (iv in 0 ... nVertices) {
			var index0 = (this._indexData != null) ? this._indexData.get(iv + 0) : iv + 0;

			var tx0 = tangentVertexData.get(index0 * tangentStride + tangentOffset + 0);
			var ty0 = tangentVertexData.get(index0 * tangentStride + tangentOffset + 1);
			var tz0 = tangentVertexData.get(index0 * tangentStride + tangentOffset + 2);

			var len = Math.sqrt(tx0 * tx0 + ty0 * ty0 + tz0 * tz0);
			tx0 /= len;
			ty0 /= len;
			tz0 /= len;

			tangentVertexData.set(index0 * tangentStride + tangentOffset + 0, tx0);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 1, ty0);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 2, tz0);
		}
	}

}
