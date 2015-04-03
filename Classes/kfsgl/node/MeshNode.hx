package kfsgl.node;


import kfsgl.node.RenderObject;
import kfsgl.core.Geometry;
import kfsgl.material.Material;

class MeshNode extends RenderObject {

	// properties
	public var geometry(get, set):Geometry;

	// members
	public var _geometry:Geometry;

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



	/* ----------- Properties ----------- */

	public function get_geometry():Geometry {
		return this._geometry;
	}

	public function set_geometry(value:Geometry) {
		this.setGeometry(value);
		return this._geometry;
	}


	/* --------- Implementation --------- */

	public function getGeometry():Geometry {
		return this._geometry;
	}

	public function setGeometry(value:Geometry) {
		this._geometry = value;
	}

	/* --------- Scene graph --------- */

	override public function updateObject():Void {
		super.updateObject();

		// Make sure the geometry data is written to opengl buffers
		this.geometry.updateGeometry();
	}

}
