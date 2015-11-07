package xt3d.material;

import xt3d.utils.color.Color;

class ColorMaterial extends BaseTypedMaterial {

	// properties

	// members

	public static function create():ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(null))) {
			object = null;
		}

		return object;
	}

	public static function createWithColor(color:Color):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(color))) {
			object = null;
		}

		return object;
	}


	public static function createWithComponents(red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 1.0):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(Color.createWithComponents(red, green, blue, alpha)))) {
			object = null;
		}

		return object;
	}

	public static function createWithRGBHex(hex:UInt):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(Color.createWithRGBHex(hex)))) {
			object = null;
		}

		return object;
	}

	public static function createWithRGBAHex(hex:UInt):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(Color.createWithRGBAHex(hex)))) {
			object = null;
		}

		return object;
	}

	public function initWithColor(color:Color):Bool {
		var isOk;
		if ((isOk = super.initBaseTypedMaterial())) {

			if (color != null) {
				// Set color value
				this.setColor(color);
			}
		}

		return isOk;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	private override function getTypedMaterialName():String {
		// Nothing extra...
		return "";
	}

}
