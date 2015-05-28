package kfsgl.utils;

class Color  {

	public var red(default, default):Float = 0.0;
	public var green(default, default):Float = 0.0;
	public var blue(default, default):Float = 0.0;
	public var alpha(default, default):Float = 1.0;

	public function new(red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 1.0):Void {
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
	}

	public function intValue():UInt {
		return Std.int(this.red * 255) << 16 | Std.int(this.green * 255) << 8 | Std.int(this.blue * 255) << 0 | Std.int(this.alpha * 255) << 24;
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