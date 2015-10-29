package xt3d.utils.math;

import lime.math.Matrix4;
import lime.math.Vector4;

class VectorHelper {


	private static var DEG_TO_RAD:Float = Math.PI / 180.0;

	public function new() {
	}

	/**
	 * Adds vector b to a and stores the result in a
 	 **/
	public static function add(a:Vector4, b:Vector4):Void {
		a.x += b.x;
		a.y += b.y;
		a.z += b.z;
	}

	/**
	 * Subtracts vector b from a and stores the result in a
 	 **/
	public static function subtract(a:Vector4, b:Vector4):Void {
		a.x -= b.x;
		a.y -= b.y;
		a.z -= b.z;
	}

	/**
	 * Translates a vector by a given amount.
	 * @param a The vector.
	 * @param x The x translation.
	 * @param y The y translation.
	 * @param z The z translation.
	 */
	public static function translate(a:Vector4, x:Float, y:Float, z:Float):Void {
		a.x += x;
		a.y += y;
		a.z += z;
	}


	/**
	 * Rotates a given position around the x-axis by a specified angle centered on a given point in the y-z plane.
	 * @param a The vector position.
	 * @param angle The amount of rotation in degrees.
	 * @param centerY The center of the rotation in the y-z plane along the y-axis.
	 * @param centerZ The center of the rotation in the y-z plane along the z-axis.
	 */
	public static function rotateX(a:Vector4, angle:Float, centerY:Float, centerZ:Float) {

		angle *= DEG_TO_RAD;
		var cosRY:Float = Math.cos(angle);
		var sinRY:Float = Math.sin(angle);

		var tempY:Float = a.y - centerY;
		var tempZ:Float = a.z - centerZ;

		a.y = (tempY * cosRY) - (tempZ * sinRY) + centerY;
		a.z = (tempY * sinRY) + (tempZ * cosRY) + centerZ;

	}

	/**
	 * Rotates a given position around the y-axis by a specified angle centered on a given point in the x-z plane.
	 * @param a The vector position.
	 * @param angle The amount of rotation in degrees.
	 * @param centerX The center of the rotation in the x-z plane along the x-axis.
	 * @param centerZ The center of the rotation in the x-z plane along the z-axis.
	 */
	public static function rotateY(a:Vector4, angle:Float, centerX:Float, centerZ:Float) {

		angle *= DEG_TO_RAD;
		var cosRY:Float = Math.cos(angle);
		var sinRY:Float = Math.sin(angle);

		var tempX:Float = a.x - centerX;
		var tempZ:Float = a.z - centerZ;

		a.x = (tempX * cosRY) +  (tempZ * sinRY) + centerX;
		a.z = (tempX * -sinRY) + (tempZ * cosRY) + centerZ;

	}

	/**
	 * Rotates a given position around the z-axis by a specified angle centered on a given point in the x-y plane.
	 * @param a The vector position.
	 * @param angle The amount of rotation in degrees.
	 * @param centerX The center of the rotation in the x-y plane along the x-axis.
	 * @param centerY The center of the rotation in the x-y plane along the y-axis.
	 */
	public static function rotateZ(a:Vector4, angle:Float, centerX:Float, centerY:Float) {

		angle *= DEG_TO_RAD;
		var cosRY:Float = Math.cos(angle);
		var sinRY:Float = Math.sin(angle);

		var tempX:Float = a.x - centerX;
		var tempY:Float = a.y - centerY;

		a.x = (tempX * cosRY ) - (tempY * sinRY);
		a.y = (tempX * sinRY ) + (tempY * cosRY);
	}

	public static function transform(v:Vector4, m:Matrix4):Void {
		var x:Float = v.x;
		var y:Float = v.y;
		var z:Float = v.z;

		v.x = (x * m[0] + y * m[4] + z * m[8] + m[12]);
		v.y = (x * m[1] + y * m[5] + z * m[9] + m[13]);
		v.z = (x * m[2] + y * m[6] + z * m[10] + m[14]);
		v.w = (x * m[3] + y * m[7] + z * m[11] + m[15]);
	}

	public static function applyProjection(v:Vector4, m:Matrix4):Void {
		var x:Float = v.x;
		var y:Float = v.y;
		var z:Float = v.z;

		var d = 1.0 / (x * m[3] + y * m[7] + z * m[11] + m[15]);

		v.x = (x * m[0] + y * m[4] + z * m[8] + m[12]) * d;
		v.y = (x * m[1] + y * m[5] + z * m[9] + m[13]) * d;
		v.z = (x * m[2] + y * m[6] + z * m[10] + m[14]) * d;
	}


	public inline static function toArray(v:Vector4, a:Array<Float>):Void {
		a[0] = v.x;
		a[1] = v.y;
		a[2] = v.z;
		a[3] = v.w;
	}

	public inline static function set(v:Vector4, x:Float, y:Float, z:Float, w:Float):Void {
		v.x = x;
		v.y = y;
		v.z = z;
		v.w = w;
	}
}
