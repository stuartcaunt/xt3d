package kfsgl.node;


import openfl.gl.GL;
import kfsgl.node.RenderObject;
import kfsgl.core.Geometry;
import kfsgl.core.Material;

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
		if ((retval = super.initRenderObject(geometry, material, GL.TRIANGLES))) {

		}

		return retval;
	}

	public function new() {
		super();
	}



	/* ----------- Properties ----------- */


	/* --------- Implementation --------- */

	/* --------- Scene graph --------- */

	override public function updateObject(scene:Scene):Void {
		super.updateObject(scene);
	}

}
