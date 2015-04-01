package kfsgl.node;

import kfsgl.material.Material;

class RenderObject extends Node3D {

	private var _material:Material;

	public function initWithMaterial(material:Material):Bool {
		var retval;
		if ((retval = super.init())) {
			this._material = material;

		}

		return retval;
	}

	private function new() {
		super();

	}

}
