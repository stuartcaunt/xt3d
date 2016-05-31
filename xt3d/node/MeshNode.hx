package xt3d.node;


import xt3d.node.RenderObject;
import xt3d.geometry.Geometry;
import xt3d.material.Material;

class MeshNode extends RenderObject {

	// properties

	// members

	public static function create(geometry:Geometry, material:Material):MeshNode {
		var object = new MeshNode();

		if (object != null && !(object.initMesh(geometry, material))) {
			object = null;
		}

		return object;
	}

	public function initMesh(geometry:Geometry, material:Material):Bool {
		var retval;
		if ((retval = super.initRenderObject(geometry, material))) {

		}

		return retval;
	}

	public function new() {
		super();
	}



	/* ----------- Properties ----------- */


	/* --------- Implementation --------- */

}
