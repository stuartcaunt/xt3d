package xt3d.utils.color;

import lime.utils.Float32Array;

class Color  {

	public static var black:Color = Color.createWithRGBHex(0x000000);
	public static var white:Color = Color.createWithRGBHex(0xffffff);
	public static var red:Color = Color.createWithRGBHex(0xff0000);
	public static var green:Color = Color.createWithRGBHex(0x00ff00);
	public static var blue:Color = Color.createWithRGBHex(0x0000ff);
	public static var yellow:Color = Color.createWithRGBHex(0xffff00);
	public static var cyan:Color = Color.createWithRGBHex(0x00ffff);
	public static var magenta:Color = Color.createWithRGBHex(0xff00ff);

	// properties
	public var r(get, set):Float;
	public var g(get, set):Float;
	public var b(get, set):Float;
	public var a(get, set):Float;
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
		this.r = red;
		this.g = green;
		this.b = blue;
		this.a = alpha;

		return true;
	}

	public function initWithRGBHex(hex:UInt):Bool {
		this.r   = ((hex >> 16) & 0xFF) / 255.0;
		this.g = ((hex >>  8) & 0xFF) / 255.0;
		this.b  = ((hex >>  0) & 0xFF) / 255.0;
		this.a = 1.0;

		return true;
	}

	public function initWithRGBAHex(hex:UInt):Bool {
		this.r   = ((hex >> 24) & 0xFF) / 255.0;
		this.g = ((hex >> 16) & 0xFF) / 255.0;
		this.b = ((hex >>  8) & 0xFF) / 255.0;
		this.a = ((hex >>  0) & 0xFF) / 255.0;

		return true;
	}

	public function new():Void {
	}

	/* ----------- Properties ----------- */

	public inline function get_r():Float {
		return this._colorArray[0];
	}

	public inline function set_r(value:Float) {
		this._colorArray[0] = value;
		return value;
	}

	public inline function get_g():Float {
		return this._colorArray[1];
	}

	public inline function set_g(value:Float) {
		this._colorArray[1] = value;
		return value;
	}

	public inline function get_b():Float {
		return this._colorArray[2];
	}

	public inline function set_b(value:Float) {
		this._colorArray[2] = value;
		return value;
	}

	public inline function get_a():Float {
		return this._colorArray[3];
	}

	public inline function set_a(value:Float) {
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
		return Std.int(this.r * 255) << 24 | Std.int(this.g * 255) << 16 | Std.int(this.b * 255) << 8 | Std.int(this.a * 255) << 0;
	}

	public function toString():String {
		return "#" + StringTools.hex(Std.int(this.r * 255)) + StringTools.hex(Std.int(this.g * 255)) + StringTools.hex(Std.int(this.b * 255)) + StringTools.hex(Std.int(this.a * 255));
	}

	public function equals(color:Color):Bool {
		if (color == null) {
			return false;
		}

		return color.r == this.r && color.g == this.g && color.b == this.b && color.a == this.a;
	}

}