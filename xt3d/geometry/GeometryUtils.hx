package xt3d.geometry;

import xt3d.gl.XTGL;
import xt3d.gl.vertexdata.FloatVertexData;
import xt3d.utils.errors.XTException;

class GeometryUtils {


	public static function generateTangents(geometry:Geometry, interleave:Bool = true):Void {
		var positionVertexData:FloatVertexData = null;
		var uvVertexData:FloatVertexData = null;
		var tangentVertexData:FloatVertexData = null;

		var positionOffset = 0;
		var uvOffset = 0;
		var tangentOffset = 0;
		var positionStride = 3;
		var uvStride = 2;
		var tangentStride = 3;

		var bufferNames = Geometry.bufferNames;

		if (geometry.interleavedVertexData != null) {
			var interleavedVertexData = geometry.interleavedVertexData;

			// Check that we have uv, normal and tangent data specified
			positionOffset = interleavedVertexData.getAttributeOffset(bufferNames.position);
			uvOffset = interleavedVertexData.getAttributeOffset(bufferNames.uv);
			positionStride = interleavedVertexData.stride;
			uvStride = interleavedVertexData.stride;

			if (positionOffset == -1 || uvOffset == -1) {
				throw new XTException("CannotGenerateTangentData", "Cannot generate tanget vertex data without coherent interleaved data");
			}

			positionVertexData = interleavedVertexData;
			uvVertexData = interleavedVertexData;

			if (tangentOffset == -1 || !interleave) {
				// Create new buffer for tangent data
				var tangentDataSize = Std.int(positionVertexData.length / positionStride * 3);
				tangentVertexData = geometry.createTangentData(tangentDataSize);

			} else {
				// Use interleaved data
				tangentOffset = interleavedVertexData.getAttributeOffset(bufferNames.tangent);
				tangentStride = interleavedVertexData.stride;
				tangentVertexData = interleavedVertexData;
			}

		} else {
			positionVertexData = geometry.getPositionData();
			uvVertexData = geometry.getUVData();

			if (positionVertexData == null || uvVertexData == null) {
				throw new XTException("CannotGenerateTangentData", "Cannot generate tanget vertex data without coherent interleaved data");
			}

			// Create new buffer for tangent data
			tangentVertexData = geometry.createTangentData(positionVertexData.length);
		}

		var nVertices = Std.int(positionVertexData.length / positionStride);
		var nTriangles = Std.int(nVertices / 3);
		var indexData = geometry.indices;
		if (indexData != null) {
			nTriangles = Std.int(indexData.length / 3);
		}

		// Initialise tangent values
		for (iv in 0 ... nVertices) {
			var index0 = (indexData != null) ? indexData.get(iv + 0) : iv + 0;

			tangentVertexData.set(index0 * tangentStride + tangentOffset + 0, 0.0);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 1, 0.0);
			tangentVertexData.set(index0 * tangentStride + tangentOffset + 2, 0.0);
		}

		for (it in 0 ... nTriangles) {
			var i = it * 3;
			var index0 = (indexData != null) ? indexData.get(i + 0) : i + 0;
			var index1 = (indexData != null) ? indexData.get(i + 1) : i + 1;
			var index2 = (indexData != null) ? indexData.get(i + 2) : i + 2;

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
			var index0 = (indexData != null) ? indexData.get(iv + 0) : iv + 0;

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

	public static function convertToLineGeometry(geometry:Geometry):Geometry {
		var lineGeometry = geometry.clone();
		lineGeometry.drawMode = XTGL.GL_LINES;

		var positionVertexData:FloatVertexData = null;
		var positionStride = 3;
		if (geometry.interleavedVertexData != null) {
			var interleavedVertexData = geometry.interleavedVertexData;

			positionStride = interleavedVertexData.stride;
			positionVertexData = interleavedVertexData;

		} else {
			positionVertexData = geometry.positions;
		}

		var nVertices = Std.int(positionVertexData.length / positionStride);
		var nTriangles = Std.int(nVertices / 3);
		var indexData = geometry.indices;
		if (indexData != null) {
			nTriangles = Std.int(indexData.length / 3);
		}

		var nLines = Std.int(nTriangles * 3);
		var nLineIndices = nLines * 2;
		var linesIndices = lineGeometry.createIndexData(nLineIndices);
		var triangleIndices = geometry.indices;
		var useIndices = (triangleIndices != null);

		for (i in 0 ... nTriangles) {
			var i0 = useIndices ? triangleIndices.get(i * 3 + 0) : i * 3 + 0;
			var i1 = useIndices ? triangleIndices.get(i * 3 + 1) : i * 3 + 1;
			var i2 = useIndices ? triangleIndices.get(i * 3 + 2) : i * 3 + 2;

			linesIndices.set(i * 6 + 0, i0);
			linesIndices.set(i * 6 + 1, i1);
			linesIndices.set(i * 6 + 2, i1);
			linesIndices.set(i * 6 + 3, i2);
			linesIndices.set(i * 6 + 4, i2);
			linesIndices.set(i * 6 + 5, i0);
		}

		return lineGeometry;
	}

}
