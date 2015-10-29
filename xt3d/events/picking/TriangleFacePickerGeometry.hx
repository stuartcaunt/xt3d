package xt3d.events.picking;

import xt3d.core.Geometry;

/**
 * Picker used when we know that the geometry is based on triangles, such as for a non-indexed geometry
 **/
class TriangleFacePickerGeometry extends Geometry {

	// properties

	// members
	private var _nVertices:Int;

	public static function create(nVertices:Int = Geometry.MAX_INDEXED_VERTICES):TriangleFacePickerGeometry {
		var object = new TriangleFacePickerGeometry();

		if (object != null && !(object.init(nVertices))) {
			object = null;
		}

		return object;
	}

	public function init(nVertices:Int = Geometry.MAX_INDEXED_VERTICES):Bool {
		var initOk;
		if ((initOk = super.initGeometry())) {
			this._nVertices = nVertices;

			this.createGeometry();
		}

		return initOk;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	private function createGeometry():Void {
		// Create a geometry where we change value every 4 vertices
		var faceInfo = super.createCustomByteData("faceId", 2, this._nVertices * 2);
		faceInfo.arrayLength = this._nVertices * 2;
		var faceInfoArray = faceInfo.uint8Array;
		var nTriangles = Std.int(this._nVertices / 3);

		var triangle:Int = 0;
		while (triangle < nTriangles) {
			var high = Std.int(triangle / 256);
			var low  = triangle % 256;

			for (i in 0 ... 3) {
				var index = 2 * (triangle * 3 + i);
				faceInfoArray[index + 0] = high;
				faceInfoArray[index + 1] = low;
			}
		}

		faceInfo.isDirty = true;
	}

}