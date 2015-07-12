package kfsgl.utils.math;

import openfl.Vector;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;

class VectorHelper {


	private static var DEG_TO_RAD:Float = Math.PI / 180.0;

	public function new() {
	}

	/**
	 * Adds vector b to a and stores the result in a
 	 **/
	public static function add(a:Vector3D, b:Vector3D):Void {
		a.x += b.x;
		a.y += b.y;
		a.z += b.z;
	}

	/**
	 * Subtracts vector b from a and stores the result in a
 	 **/
	public static function subtract(a:Vector3D, b:Vector3D):Void {
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
	public static function translate(a:Vector3D, x:Float, y:Float, z:Float):Void {
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
	public static function rotateX(a:Vector3D, angle:Float, centerY:Float, centerZ:Float) {

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
	public static function rotateY(a:Vector3D, angle:Float, centerX:Float, centerZ:Float) {

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
	public static function rotateZ(a:Vector3D, angle:Float, centerX:Float, centerY:Float) {

		angle *= DEG_TO_RAD;
		var cosRY:Float = Math.cos(angle);
		var sinRY:Float = Math.sin(angle);

		var tempX:Float = a.x - centerX;
		var tempY:Float = a.y - centerY;

		a.x = (tempX * cosRY ) - (tempY * sinRY);
		a.y = (tempX * sinRY ) + (tempY * cosRY);
	}

	public static function transform(v:Vector3D, m:Matrix3D):Void {
		var x:Float = v.x;
		var y:Float = v.y;
		var z:Float = v.z;

		var rawData:Vector<Float> = m.rawData;

		v.x = (x * rawData[0] + y * rawData[4] + z * rawData[8] + rawData[12]);
		v.y = (x * rawData[1] + y * rawData[5] + z * rawData[9] + rawData[13]);
		v.z = (x * rawData[2] + y * rawData[6] + z * rawData[10] + rawData[14]);
		v.w = (x * rawData[3] + y * rawData[7] + z * rawData[11] + rawData[15]);
	}

	public static function applyProjection(v:Vector3D, m:Matrix3D):Void {
		var x:Float = v.x;
		var y:Float = v.y;
		var z:Float = v.z;

		var rawData:Vector<Float> = m.rawData;

		var d = 1.0 / (x * rawData[3] + y * rawData[7] + z * rawData[11] + rawData[15]);

		v.x = (x * rawData[0] + y * rawData[4] + z * rawData[8] + rawData[12]) * d;
		v.y = (x * rawData[1] + y * rawData[5] + z * rawData[9] + rawData[13]) * d;
		v.z = (x * rawData[2] + y * rawData[6] + z * rawData[10] + rawData[14]) * d;
	}


	public static function toArray(v:Vector3D, a:Array<Float>):Void {
		a[0] = v.x;
		a[1] = v.y;
		a[2] = v.z;
		a[3] = v.w;
	}

}
