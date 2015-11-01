package xt3d.math;

import lime.math.Vector4;

class Quaternion {


	// properties
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	public var z(get_z, set_z):Float;
	public var w(get_w, set_w):Float;

	// members
	private var _x:Float;
	private var _y:Float;
	private var _z:Float;
	private var _w:Float;

	public static function create(x:Float, y:Float, z:Float, w:Float):Quaternion {
		var object = new Quaternion();
		return object;
	}

	public static function createFromEuler(ax:Float, ay:Float, az:Float):Quaternion {
		var object = new Quaternion();
		return object.fromEuler(ax, ay, az);
	}

	public static function createFromAxisAngle(axis:Vector4, angle:Float):Quaternion {
		var object = new Quaternion();
		return object.fromAxisAngle(axis, angle);
	}

	public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) {
		this._x = x;
		this._x = x;
		this._y = y;
		this._w = w;
	}


	/* ----------- Properties ----------- */


	public inline function get_x():Float {
		return _x;
	}

	public inline function set_x(value:Float) {
		return this._x = value;
	}

	public inline function get_y():Float {
		return _y;
	}

	public inline function set_y(value:Float) {
		return this._y = value;
	}

	public inline function get_z():Float {
		return _z;
	}

	public inline function set_z(value:Float) {
		return this._z = value;
	}

	public inline function get_w():Float {
		return _w;
	}

	public inline function set_w(value:Float) {
		return this._w = value;
	}



	/* --------- Implementation --------- */


	public inline function magnitude():Float {
		return Math.sqrt(_x * _x + _y * _y + _z * _z + _w * _w);
	}

	public function multiplyBy(q:Quaternion):Quaternion {
		var x1:Float = _x;
		var y1:Float = _y;
		var z1:Float = _z;
		var w1:Float = _w;
		var x2:Float = q.x;
		var y2:Float = q.y;
		var z2:Float = q.z;
		var w2:Float = q.w;

		_x = w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2;
		_y = w1 * y2 + y1 * w2 + z1 * x2 - x1 * z2;
		_z = w1 * z2 + z1 * w2 + x1 * y2 - y1 * x2;
		_w = w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2;

		return this;
	}


	public function multiply(q:Quaternion):Quaternion {
		var x1:Float = _x;
		var y1:Float = _y;
		var z1:Float = _z;
		var w1:Float = _w;
		var x2:Float = q.x;
		var y2:Float = q.y;
		var z2:Float = q.z;
		var w2:Float = q.w;

		var x = w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2;
		var y = w1 * y2 + y1 * w2 + z1 * x2 - x1 * z2;
		var z = w1 * z2 + z1 * w2 + x1 * y2 - y1 * x2;
		var w = w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2;

		return new Quaternion(x, y, z, w);
	}

	public function multiplyVector(vector:Vector4):Quaternion {
		var x1:Float = _x;
		var y1:Float = _y;
		var z1:Float = _z;
		var w1:Float = _w;
		var x2:Float = vector.x;
		var y2:Float = vector.y;
		var z2:Float = vector.z;

		_x = w1 * x2 + y1 * z2 - z1 * y2;
		_y = w1 * y2 - x1 * z2 + z1 * x2;
		_z = w1 * z2 + x1 * y2 - y1 * x2;
		_w = -x1 * x2 - y1 * y2 - z1 * z2;

		return this;
	}

	public function fromAxisAngle(axis:Vector4, angle:Float):Quaternion {
		var sin_a:Float = Math.sin(angle / 2);
		var cos_a:Float = Math.cos(angle / 2);
		_x = axis.x * sin_a;
		_y = axis.y * sin_a;
		_z = axis.z * sin_a;
		_w = cos_a;
		normalize();

		return this;
	}

	public function normalize():Quaternion {
		var mag:Float = 1.0 / magnitude();
		_x *= mag;
		_y *= mag;
		_z *= mag;
		_w *= mag;

		return this;
	}

	public function fromEuler(ax:Float, ay:Float, az:Float):Quaternion {
		var DEG_TO_RAD:Float = Math.PI / 180.0;

		ax = 0.5 * DEG_TO_RAD * ax;
		ay = 0.5 * DEG_TO_RAD * ay;
		az = 0.5 * DEG_TO_RAD * az;

		var sax:Float = Math.sin(ax);
		var cax:Float = Math.cos(ax);
		var say:Float = Math.sin(ay);
		var cay:Float = Math.cos(ay);
		var saz:Float = Math.sin(az);
		var caz:Float = Math.cos(az);

		_x = cax * cay * caz + sax * say * saz;
		_y = sax * cay * caz - cax * say * saz;
		_z = cax * say * caz + sax * cay * saz;
		_w = cax * cay * saz - sax * say * caz;

		return this;
	}

}
