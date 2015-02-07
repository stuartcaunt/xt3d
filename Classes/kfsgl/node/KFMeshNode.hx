package kfsgl.object;


import kfsgl.core.KFGeometry;
import kfsgl.material.KFMaterial;
import kfsgl.node.KFNode;

class KFMeshNode extends KFNode {

	private var _geometry:KFGeometry;
	private var _material:KFMaterial;

	public function new(geometry:KFGeometry, material:KFMaterial) {
		_geometry = geometry;
		_material = material;
	}

}
