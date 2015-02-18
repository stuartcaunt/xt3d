package kfsgl.object;


import kfsgl.node.KFRenderObject;
import kfsgl.core.KFGeometry;
import kfsgl.material.KFMaterial;

class KFMeshNode extends KFRenderObject {

	private var _geometry:KFGeometry;

	public function new(geometry:KFGeometry, material:KFMaterial) {
		super(material);
		_geometry = geometry;
	}

}
