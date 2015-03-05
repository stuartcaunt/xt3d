package kfsgl.math;

import flash.geom.Vector3D;
import openfl.Vector;
import flash.geom.Matrix3D;

import kfsgl.math.Quaternion;
import kfsgl.utils.KF;

class MatrixHelper {

	public function new() {
	}

	/**
	 * Sets the rotation of a matrix to a specific angle about a specified axis.
	 * The translation components of the matrix are not affected.
	 * @param m The matrix.
	 * @param angle The angle of rotation in degrees.
	 * @param x The x component of the axis of rotation.
	 * @param y The y component of the axis of rotation.
	 * @param z The z component of the axis of rotation.
	 */
	public static function setRotation(m:Matrix3D, axis:Vector3D, angle:Float):Void {
		var q:Quaternion = Quaternion.createFromAxisAngle(axis, angle);

		setRotationFromQuaternion(m, q);
	}


	/**
	 * Calculates the rotational component of the matrix from euler angles.
	 * The translation components of the matrix are not affected.
	 * @param m The matrix.
	 * @param rotationX The rotation about the x axis.
	 * @param rotationY The rotation about the y axis.
	 * @param rotationZ The rotation about the z axis.
	 */
	public static function setRotationFromEuler(m:Matrix3D, rotationX:Float, rotationY:Float, rotationZ:Float):Void {
		var q:Quaternion = Quaternion.createFromEuler(rotationX, rotationY, rotationZ);

		setRotationFromQuaternion(m, q);
	}

	/**
	 * Sets the rotational component of the matrix from a quaternion
	 * @param m The matrix.
	 * @param a The quaternion.
	 **/
	public static function setRotationFromQuaternion(m:Matrix3D, q:Quaternion) {
		var x:Float = q.x;
		var y:Float = q.y;
		var z:Float = q.z;
		var w:Float = q.w;

		var xy:Float = x * y;
		var xz:Float = x * z;
		var xw:Float = x * w;

		var yy:Float = y * y;
		var yz:Float = y * z;
		var yw:Float = y * w;

		var zz:Float = z * z;
		var zw:Float = z * w;

		var ww:Float = w * w;

		var raw:Vector<Float> = m.rawData;
		raw[0] = 1 - 2 * (zz + ww);
		raw[1] =     2 * (yz + xw);
		raw[2] =     2 * (yw - xz);

		raw[4] =     2 * (yz - xw);
		raw[5] = 1 - 2 * (yy + ww);
		raw[6] =     2 * (xy + zw);

		raw[8] =     2 * (xz + yw);
		raw[9] =     2 * (zw - xy);
		raw[10] = 1 - 2 * (yy + zz);

		// Set raw back again?
		KF.Log("TODO: MatrixHelp.setRotationFromQuaternion check set raw data to matrix");
	}

}
