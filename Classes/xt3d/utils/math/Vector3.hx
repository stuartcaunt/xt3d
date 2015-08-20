package xt3d.utils.math;

class Vector3 {

	public static var Forward:Vector3 = Vector3.createWithComponents(0.0, 0.0, -1.0);
	public static var Backward:Vector3 = Vector3.createWithComponents(0.0, 0.0, 1.0);
	public static var Left:Vector3 = Vector3.createWithComponents(-1.0, 0.0, 0.0);
	public static var Right:Vector3 = Vector3.createWithComponents(1.0, 0.0, 0.0);
	public static var Up:Vector3 = Vector3.createWithComponents(0.0, 1.0, 0.0);
	public static var Down:Vector3 = Vector3.createWithComponents(0.0, -1.0, 0.0);
	public static var AxisX:Vector3 = Vector3.createWithComponents(1.0, 0.0, 0.0);
	public static var AxisY:Vector3 = Vector3.createWithComponents(0.0, 1.0, 0.0);
	public static var AxisZ:Vector3 = Vector3.createWithComponents(0.0, 0.0, 1.0);

	// properties
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	@:isVar public var length(get, null):Float;
	@:isVar public var lengthSquared(get, null):Float;

	// members
	private var _x:Float;
	private var _y:Float;
	private var _z:Float;

	inline public static function create():Vector3 {
		var object = new Vector3();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	inline public static function createWithComponents(x:Float, y:Float, z:Float):Vector3 {
		var object = new Vector3();

		if (object != null && !(object.initWithComponents(x, y, z))) {
			object = null;
		}

		return object;
	}

	inline public static function createWithVector3(v:Vector3):Vector3 {
		var object = new Vector3();

		if (object != null && !(object.initWithVector3(v))) {
			object = null;
		}

		return object;
	}

	inline public function init():Bool {
		this._x = 0;
		this._y = 0;
		this._z = 0;

		return true;
	}

	inline public function initWithComponents(x:Float, y:Float, z:Float):Bool {
		this._x = x;
		this._y = y;
		this._z = z;

		return true;
	}

	inline public function initWithVector3(v:Vector3):Bool {
		this._x = v._x;
		this._y = v._y;
		this._z = v._z;

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
		return this._x * this._x + this._y * this._y + this._z * this._z;
	}

	inline public function add(v:Vector3):Vector3 {
		return Vector3.createWithComponents(this._x + v._x, this._y + v._y, this._z + v._z);
	}

	inline public function addToSelf(v:Vector3):Void {
		this._x += v._x;
		this._y += v._y;
		this._z += v._z;
	}

	inline public function translateBy(x:Float, y:Float, z:Float):Void {
		this._x += x;
		this._y += y;
		this._z += z;
	}

	inline public static function addInto(a:Vector3, b:Vector3, c:Vector3):Void {
		c._x = a._x + b._x;
		c._y = a._y + b._y;
		c._z = a._z + b._z;
	}

	inline public function sub(v:Vector3):Vector3 {
		return Vector3.createWithComponents(this._x - v._x, this._y - v._y, this._z - v._z);
	}

	inline public function subFromSelf(v:Vector3):Void {
		this._x -= v._x;
		this._y -= v._y;
		this._z -= v._z;
	}

	inline public static function subInto(a:Vector3, b:Vector3, c:Vector3):Void {
		c._x = a._x - b._x;
		c._y = a._y - b._y;
		c._z = a._z - b._z;
	}

	inline public function scale(s:Float):Vector3 {
		return Vector3.createWithComponents(this._x * s, this._y * s, this._z * s);
	}

	inline public function scaleBy(s:Float):Void {
		this._x *= s;
		this._y *= s;
		this._z *= s;
	}

	inline public function clone():Vector3 {
		return Vector3.createWithComponents(this._x, this._y, this._z);
	}

	inline public function copyFrom(v:Vector3):Void {
		this._x = v._x;
		this._y = v._y;
		this._z = v._z;
	}

	inline public function setTo(x:Float, y:Float, z:Float) {
		this._x = x;
		this._y = y;
		this._z = z;
	}

	inline public function reset() {
		this._x = 0.0;
		this._y = 0.0;
		this._z = 0.0;
	}

	inline public function toArray(a:Array<Float>):Void {
		a[0] = this._x;
		a[1] = this._y;
		a[2] = this._z;
	}


	inline public function dot(v:Vector3):Float {
		return (this._x * v._x + this._y * v._y + this._z * v._z);
	}

	inline public function cross(v:Vector3):Vector3 {
		return Vector3.createWithComponents(this._y * v._z - this._z * v._y, this._z * v._x - this._x * v._z, this._x * v._y - this._y * v._x);
	}

	inline public static function crossInto(a:Vector3, b:Vector3, c:Vector3):Void{
		c._x = a._y * b._z - a._z * b._y;
		c._y = a._z * b._x - a._x * b._z;
		c._z = a._x * b._y - a._y * b._x;
	}

	inline public function normalize():Float {
		var l = this.getLength();

		if (l != 0) {
			this._x /= l;
			this._y /= l;
			this._z /= l;
		}

		return l;
	}

	inline public function negate():Void {
		this._x *= -1.0;
		this._y *= -1.0;
		this._z *= -1.0;
	}

	inline public function equals(v:Vector3):Bool {
		return this._x == v._x && this._y == v._y && this._z == v._z;
	}

	inline public function nearEquals(v:Vector3, epsilon:Float):Bool {
		return Math.abs(this._x - v._x) < epsilon && Math.abs(this._y - v._y) < epsilon && Math.abs(this._z - v._z) < epsilon;
	}

	inline public static function angleBetween(a:Vector3, b:Vector3):Float {
		var a0:Vector3 = a.clone();
		a0.normalize();

		var b0:Vector3 = b.clone();
		b0.normalize();

		return Math.acos(a0.dot(b0));
	}

	inline public static function distanceBetween(pt1:Vector3, pt2:Vector3):Float {
		var x:Float = pt1._x - pt2._x;
		var y:Float = pt1._y - pt2._y;
		var z:Float = pt1._z - pt2._z;

		return Math.sqrt(x * x + y * y + z * z);
	}

	inline public function toString ():String {
		return "Vector3(" + this._x + ", " + this._y + ", " + this._z + ")";
	}

	inline public function rotateX(angle:Float, anchorY:Float, anchorZ:Float):Void {
		var cosA:Float = Math.cos(angle);
		var sinA:Float = Math.sin(angle);

		var tempY:Float = this._y - anchorY;
		var tempZ:Float = this._z - anchorZ;

		this._y = (tempY * cosA) - (tempZ * sinA) + anchorY;
		this._z = (tempY * sinA) + (tempZ * cosA) + anchorZ;
	}

	inline public function rotateY(angle:Float, anchorX:Float, anchorZ:Float):Void {
		var cosA:Float = Math.cos(angle);
		var sinA:Float = Math.sin(angle);

		var tempZ:Float = this._z - anchorZ;
		var tempX:Float = this._x - anchorX;

		this._z = (tempZ * cosA) - (tempX * sinA) + anchorZ;
		this._x = (tempZ * sinA) + (tempX * cosA) + anchorX;
	}

	inline public function rotateZ(angle:Float, anchorX:Float, anchorY:Float):Void {
		var cosA:Float = Math.cos(angle);
		var sinA:Float = Math.sin(angle);

		var tempX:Float = this._x - anchorX;
		var tempY:Float = this._y - anchorY;

		this._x = (tempX * cosA) - (tempY * sinA) + anchorX;
		this._y = (tempX * sinA) + (tempY * cosA) + anchorY;
	}
}
