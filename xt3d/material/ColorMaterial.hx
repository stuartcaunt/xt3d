package xt3d.material;

import xt3d.utils.color.Color;

class ColorMaterial extends BaseTypedMaterial {

	// properties

	// members

	public static function create(materialOptions:MaterialOptions = null):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(null, materialOptions))) {
			object = null;
		}

		return object;
	}

	public static function createWithColor(color:Color, materialOptions:MaterialOptions = null):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(color, materialOptions))) {
			object = null;
		}

		return object;
	}


	public static function createWithComponents(red:Float = 1.0, green:Float = 1.0, blue:Float = 1.0, alpha:Float = 1.0, materialOptions:MaterialOptions = null):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(Color.createWithComponents(red, green, blue, alpha), materialOptions))) {
			object = null;
		}

		return object;
	}

	public static function createWithRGBHex(hex:UInt, materialOptions:MaterialOptions = null):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(Color.createWithRGBHex(hex), materialOptions))) {
			object = null;
		}

		return object;
	}

	public static function createWithRGBAHex(hex:UInt, materialOptions:MaterialOptions = null):ColorMaterial {
		var object = new ColorMaterial();

		if (object != null && !(object.initWithColor(Color.createWithRGBAHex(hex), materialOptions))) {
			object = null;
		}

		return object;
	}

	public function initWithColor(color:Color, materialOptions:MaterialOptions = null):Bool {
		var isOk;
		if ((isOk = super.initBaseTypedMaterial(materialOptions))) {

			if (color != null) {
				// Set color value
				this.setColor(color);

				if (color.a < 1.0) {
					this.transparent = true;
				}

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
