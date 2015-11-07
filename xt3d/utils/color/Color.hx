package xt3d.utils.color;

import lime.utils.Float32Array;

class Color  {

	public static var black:Color = Color.createWithRGBHex(0x000000);
	public static var white:Color = Color.createWithRGBHex(0xffffff);

	// properties
	public var red(get, set):Float;
	public var green(get, set):Float;
	public var blue(get, set):Float;
	public var alpha(get, set):Float;
	public var rgbaArray(get, null):Array<Float>;
	public var rgbArray(get, null):Array<Float>;

	// members
	private var _colorArray = [0.0, 0.0, 0.0, 1.0];

	public static function create():Color {
		var object = new Color();

		if (object != null && !(object.initWithComponents(0.0, 0.0, 0.0, 1.0))) {
			object = null;
		}

		return object;
	}

	public static function createWithComponents(red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 1.0):Color {
		var object = new Color();

		if (object != null && !(object.initWithComponents(red, green, blue, alpha))) {
			object = null;
		}

		return object;
	}

	public static function createWithRGBHex(hex:UInt):Color {
		var object = new Color();

		if (object != null && !(object.initWithRGBHex(hex))) {
			object = null;
		}

		return object;
	}

	public static function createWithRGBAHex(hex:UInt):Color {
		var object = new Color();

		if (object != null && !(object.initWithRGBAHex(hex))) {
			object = null;
		}

		return object;
	}

	public function initWithComponents(red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 1.0):Bool {
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;

		return true;
	}

	public function initWithRGBHex(hex:UInt):Bool {
		this.red   = ((hex >> 16) & 0xFF) / 255.0;
		this.green = ((hex >>  8) & 0xFF) / 255.0;
		this.blue  = ((hex >>  0) & 0xFF) / 255.0;
		this.alpha = 1.0;

		return true;
	}

	public function initWithRGBAHex(hex:UInt):Bool {
		this.red   = ((hex >> 24) & 0xFF) / 255.0;
		this.green = ((hex >> 16) & 0xFF) / 255.0;
		this.blue  = ((hex >>  8) & 0xFF) / 255.0;
		this.alpha = ((hex >>  0) & 0xFF) / 255.0;

		return true;
	}

	public function new():Void {
	}

	/* ----------- Properties ----------- */

	public inline function get_red():Float {
		return this._colorArray[0];
	}

	public inline function set_red(value:Float) {
		this._colorArray[0] = value;
		return value;
	}

	public inline function get_green():Float {
		return this._colorArray[1];
	}

	public inline function set_green(value:Float) {
		this._colorArray[1] = value;
		return value;
	}

	public inline function get_blue():Float {
		return this._colorArray[2];
	}

	public inline function set_blue(value:Float) {
		this._colorArray[2] = value;
		return value;
	}

	public inline function get_alpha():Float {
		return this._colorArray[3];
	}

	public inline function set_alpha(value:Float) {
		this._colorArray[3] = value;
		return value;
	}

	public inline function get_rgbaArray():Array<Float> {
		return this._colorArray;
	}

	public inline function get_rgbArray():Array<Float> {
		return this._colorArray.slice(0, 3);
	}

	public inline function copyFrom(color:Color):Void {
		for (i in 0 ... 4) {
			this._colorArray[i] = color._colorArray[i];
		}
	}

	/* --------- Implementation --------- */

	public function intValue():UInt {
		return Std.int(this.red * 255) << 24 | Std.int(this.green * 255) << 16 | Std.int(this.blue * 255) << 8 | Std.int(this.alpha * 255) << 0;
	}

	public function toString():String {
		return "#" + StringTools.hex(Std.int(this.red * 255)) + StringTools.hex(Std.int(this.green * 255)) + StringTools.hex(Std.int(this.blue * 255)) + StringTools.hex(Std.int(this.alpha * 255));
	}

	public function equals(color:Color):Bool {
		if (color == null) {
			return false;
		}

		return color.red == this.red && color.green == this.green && color.blue == this.blue && color.alpha == this.alpha;
	}

}