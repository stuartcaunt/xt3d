package xt3d.geometry.primitives;

import xt3d.geometry.Geometry;

class Cylinder extends Cone {

	// properties

	// members

	public static function create(height:Float, radius:Float = 1.0, ns:Int = 8, nt:Int = 8, openEnded:Bool = true):Cone {
		var object = new Cylinder();

		if (object != null && !(object.initWithCylinderGeometry(height, radius, ns, nt, openEnded))) {
			object = null;
		}

		return object;
	}


	public function initWithCylinderGeometry(height:Float, radius:Float = 1.0, ns:Int = 8, nt:Int = 8, openEnded:Bool = true):Bool {
		var retval;
		if ((retval = super.initWithGeometry(height, radius, radius, ns, nt, openEnded))) {
		}

		return retval;
	}

	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


}
