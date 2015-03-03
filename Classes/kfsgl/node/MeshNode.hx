package kfsgl.object;


import kfsgl.node.RenderObject;
import kfsgl.core.Geometry;
import kfsgl.material.Material;

class MeshNode extends RenderObject {

	private var _geometry:Geometry;

	public function new(geometry:Geometry, material:Material) {
		super(material);
		_geometry = geometry;
	}

}
