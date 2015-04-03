package kfsgl.node;

import kfsgl.material.Material;

class RenderObject extends Node3D {

	// properties
	public var material(get, set):Material;

	// members
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

	/* ----------- Properties ----------- */

	public function get_material():Material {
		return this._material;
	}

	public function set_material(value:Material) {
		this.setMaterial(value);
		return this._material;
	}

	/* --------- Implementation --------- */


	public function getMaterial():Material {
		return this._material;
	}

	public function setMaterial(value:Material) {
		this._material = value;
	}

	/* --------- Scene graph --------- */

	override public function updateObject():Void {
		super.updateObject();
	}

}
