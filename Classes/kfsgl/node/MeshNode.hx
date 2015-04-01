package kfsgl.node;


import kfsgl.node.RenderObject;
import kfsgl.core.Geometry;
import kfsgl.material.Material;

class MeshNode extends RenderObject {

	private var _geometry:Geometry;

	public static function create(geometry:Geometry, material:Material):MeshNode {
		var object = new MeshNode();

		if (object != null && !(object.initWithGeometryAndMaterial(geometry, material))) {
			object = null;
		}

		return object;
	}

	public function initWithGeometryAndMaterial(geometry:Geometry, material:Material):Bool {
		var retval;
		if ((retval = super.initWithMaterial(material))) {
			_geometry = geometry;

		}

		return retval;
	}

	public function new() {
		super();
	}

}
