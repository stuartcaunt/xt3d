package kfsgl.node;

import kfsgl.material.KFMaterial;

class KFRenderObject extends KFNode3D {

	private var _material:KFMaterial;

	public function new(material:KFMaterial) {
		super();

		_material = material;
	}

}
