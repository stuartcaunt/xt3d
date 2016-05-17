package xt3d.events.picking;

import xt3d.utils.XT;
import xt3d.core.Geometry;

/**
 * Picker used when we know that the geometry is based on quads where two triangles in a quad are made up of
 * four consecutive vertices.
 **/
class QuadFacePickerGeometry extends Geometry {

	// properties

	// members
	private var _nVertices:Int;

	public static function create(nVertices:Int = 0):QuadFacePickerGeometry {
		var object = new QuadFacePickerGeometry();

		if (object != null && !(object.init(nVertices))) {
			object = null;
		}

		return object;
	}

	public function init(nVertices:Int = 0):Bool {
		var initOk;
		if ((initOk = super.initGeometry())) {

			if (nVertices == 0) {
				nVertices = Geometry.MAX_INDEXED_VERTICES;
			}
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

		var index:Int;
		for (high in 0 ... 64) {
			for (low in 0 ... 256) {
				for (i in 0 ... 4) {
					index = 2 * ((high * 256 + low) * 4 + i);
				}
			}
		}

		faceInfo.isDirty = true;
	}

}