package xt3d.utils.math;

class Vector4 {

	// properties
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	public var w(get, set):Float;
	@:isVar public var length(get, null):Float;
	@:isVar public var lengthSquared(get, null):Float;

	// members
	private var _x:Float;
	private var _y:Float;
	private var _z:Float;
	private var _w:Float;

	inline public static function create():Vector4 {
		var object = new Vector4();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	inline public static function createWithComponents(x:Float, y:Float, z:Float, w:Float):Vector4 {
		var object = new Vector4();

		if (object != null && !(object.initWithComponents(x, y, z, w))) {
			object = null;
		}

		return object;
	}

	inline public static function createWithVector4(v:Vector4):Vector4 {
		var object = new Vector4();

		if (object != null && !(object.initWithVector4(v))) {
			object = null;
		}

		return object;
	}

	inline public function init():Bool {
		this._x = 0;
		this._y = 0;
		this._z = 0;
		this._w = 0;

		return true;
	}

	inline public function initWithComponents(x:Float, y:Float, z:Float, w:Float):Bool {
		this._x = x;
		this._y = y;
		this._z = z;
		this._w = w;

		return true;
	}

	inline public function initWithVector4(v:Vector4):Bool {
		this._x = v._x;
		this._y = v._y;
		this._z = v._z;
		this._w = v._w;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	public inline function get_x() {
		return this._x;
	}

	public inline function set_x(value) {
		return this._x = value;
	}

	public inline function get_y() {
		return this._y;
	}

	public inline function set_y(value) {
		return this._y = value;
	}

	public inline function get_z() {
		return this._z;
	}

	public inline function set_z(value) {
		return this._z = value;
	}

	public inline function get_w() {
		return this._w;
	}

	public inline function set_w(value) {
		return this._w = value;
	}

	public inline function get_length():Float {
		return this.getLength();
	}

	public inline function get_lengthSquared():Float {
		return this.getLengthSquared();
	}


	/* --------- Implementation --------- */

	public inline function getLength():Float {
		return Math.sqrt(this.getLengthSquared());
	}

	public inline function getLengthSquared():Float {
		return this._x * this._x + this._y * this._y + this._z * this._z + this._w * this._w;
	}

	inline public function add(v:Vector4):Vector4 {
		return Vector4.createWithComponents(this._x + v._x, this._y + v._y, this._z + v._z, this._w + v._w);
	}

	inline public function addToSelf(v:Vector4):Void {
		this._x += v._x;
		this._y += v._y;
		this._z += v._z;
		this._w += v._w;
	}

	inline public static function addInto(a:Vector4, b:Vector4, c:Vector4):Void {
		c._x = a._x + b._x;
		c._y = a._y + b._y;
		c._z = a._z + b._z;
		c._w = a._w + b._w;
	}

	inline public function sub(v:Vector4):Vector4 {
		return Vector4.createWithComponents(this._x - v._x, this._y - v._y, this._z - v._z, this._w - v._w);
	}

	inline public function subFromSelf(v:Vector4):Void {
		this._x -= v._x;
		this._y -= v._y;
		this._z -= v._z;
		this._w -= v._w;
	}

	inline public static function subInto(a:Vector4, b:Vector4, c:Vector4):Void {
		c._x = a._x - b._x;
		c._y = a._y - b._y;
		c._z = a._z - b._z;
		c._w = a._w - b._w;
	}

	inline public function scale(s:Float):Vector4 {
		return Vector4.createWithComponents(this._x * s, this._y * s, this._z * s, this._w * s);
	}

	inline public function scaleBy(s:Float):Void {
		this._x *= s;
		this._y *= s;
		this._z *= s;
		this._w *= s;
	}

	inline public function clone():Vector4 {
		return Vector4.createWithComponents(this._x, this._y, this._z, this._w);
	}

	inline public function copyFrom(v:Vector4):Void {
		this._x = v._x;
		this._y = v._y;
		this._z = v._z;
		this._w = v._w;
	}

	inline public function setTo(x:Float, y:Float, z:Float, w:Float) {
		this._x = x;
		this._y = y;
		this._z = z;
		this._w = w;
	}

	inline public function reset() {
		this._x = 0.0;
		this._y = 0.0;
		this._z = 0.0;
		this._w = 0.0;
	}

	inline public function toArray(a:Array<Float>):Void {
		a[0] = this._x;
		a[1] = this._y;
		a[2] = this._z;
		a[3] = this._w;
	}


	inline public function dot(v:Vector4):Float {
		return (this._x * v._x + this._y * v._y + this._z * v._z + this._w * v._w);
	}

	inline public function normalize():Float {
		var l = this.getLength();

		if (l != 0) {
			this._x /= l;
			this._y /= l;
			this._z /= l;
			this._w /= l;
		}

		return l;
	}


	inline public function equals(v:Vector4):Bool {
		return this._x == v._x && this._y == v._y && this._z == v._z && this._w == v._w;
	}

	inline public function nearEquals(v:Vector4, epsilon:Float):Bool {
		return Math.abs(this._x - v._x) < epsilon && Math.abs(this._y - v._y) < epsilon && Math.abs(this._z - v._z) < epsilon && Math.abs(this._w - v._w) < epsilon;
	}

	inline public function toString ():String {
		return "Vector4(" + this._x + ", " + this._y + ", " + this._z + ", " + this._w + ")";
	}

}
