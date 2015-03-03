package kfsgl.node;

import kfsgl.material.Material;

class RenderObject extends Node3D {

	private var _material:Material;

	public function new(material:Material) {
		super();

		_material = material;
	}

}
