package kfsgl.utils.math;

import openfl.geom.Vector3D;
import openfl.Vector;
import openfl.geom.Matrix3D;

import kfsgl.utils.math.Quaternion;

class MatrixHelper {

//	float sxx; // 0
//	float syx; // 1
//	float szx; // 2
//	float swx; // 3
//	float sxy; // 4
//	float syy; // 5
//	float szy; // 6
//	float swy; // 7
//	float sxz; // 8
//	float syz; // 9
//	float szz; // 10
//	float swz; // 11
//	float tx;  // 12
//	float ty;  // 13
//	float tz;  // 14
//	float tw;  // 15


	static public var RAW_DATA_CONTAINER(get, null):Vector<Float>;
	static private function get_RAW_DATA_CONTAINER():Vector<Float> {
		return [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ];
	}


	private static function rawDataContainerWithColumnMajorValues(
		v0, v1, v2, v3,
		v4, v5, v6, v7,
		v8, v9, v10, v11,
		v12, v13, v14, v15):Vector<Float> {

		var raw:Vector<Float> = MatrixHelper.RAW_DATA_CONTAINER;

		raw[0] = v0;
		raw[1] = v1;
		raw[2] = v2;
		raw[3] = v3;

		raw[4] = v4;
		raw[5] = v5;
		raw[6] = v6;
		raw[7] = v7;

		raw[8] = v8;
		raw[9] = v9;
		raw[10] = v10;
		raw[11] = v11;

		raw[12] = v12;
		raw[13] = v13;
		raw[14] = v14;
		raw[15] = v15;

		return raw;
	}

	static private function rawDataContainerWithRowMajorValues(
		v0, v1, v2, v3,
		v4, v5, v6, v7,
		v8, v9, v10, v11,
		v12, v13, v14, v15):Vector<Float> {

		var raw:Vector<Float> = MatrixHelper.RAW_DATA_CONTAINER;

		raw[0] = v0;
		raw[4] = v1;
		raw[8] = v2;
		raw[12] = v3;

		raw[1] = v4;
		raw[5] = v5;
		raw[9] = v6;
		raw[13] = v7;

		raw[2] = v8;
		raw[6] = v9;
		raw[10] = v10;
		raw[14] = v11;

		raw[3] = v12;
		raw[7] = v13;
		raw[11] = v14;
		raw[15] = v15;

		return raw;
	}

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
	}

	/**
	 * Returns the equivalent Euler angles of the rotational components of a matrix.
	 * @param m The matrix.
	 * @result Vector containing the rotations about x, y and z (in degrees)
	 */
	public static function getEulerRotationFromMatrix(m:Matrix3D):Vector3D {
		var raw:Vector<Float> = m.rawData;

		// Get rotation about X
		var rotX:Float = -Math.atan2(raw[6], raw[10]);

		// Create rotation matrix around X
		var matrix = new Matrix3D();
		MatrixHelper.setRotation(matrix, new Vector3D(1, 0, 0), rotX * 180.0 / Math.PI);

		// left-multipy rotation matrix with self to remove X rotation from transformation
		matrix.append(m);
		raw = matrix.rawData;

		// Get rotation about Y
		var cosRotY:Float = Math.sqrt(raw[0] * raw[0] + raw[1] * raw[1]);
		var rotY:Float = Math.atan2(-raw[2], cosRotY);

		// get rotation about Z
		var rotZ:Float = Math.atan2(-raw[4], raw[5]);


		// Fix angles (from Away3D)
		if (Math.round(rotZ / Math.PI) == 1.0) {
			if (rotY > 0.0) {
				rotY = -(rotY - Math.PI);
			} else {
				rotY = -(rotY + Math.PI);
			}

			rotZ -= Math.PI;

			if (rotX > 0.0) {
				rotX -= Math.PI;
			} else {
				rotX += Math.PI;
			}

		} else if (Math.round(rotZ / Math.PI) == -1.0) {
			if (rotY > 0.0)
				rotY = -(rotY - Math.PI);
			else
				rotY = -(rotY + Math.PI);

			rotZ += Math.PI;

			if (rotX > 0.0) {
				rotX -= Math.PI;
			} else {
				rotX += Math.PI;
			}

		} else if (Math.round(rotX / Math.PI) == 1.0) {
			if (rotY > 0.0) {
				rotY = -(rotY - Math.PI);
			} else {
				rotY = -(rotY + Math.PI);
			}

			rotX -= Math.PI;

			if (rotZ > 0.0) {
				rotZ -= Math.PI;
			} else {
				rotZ += Math.PI;
			}

		} else if (Math.round(rotX / Math.PI) == -1.0) {
			if (rotY > 0.0) {
				rotY = -(rotY - Math.PI);
			} else {
				rotY = -(rotY + Math.PI);
			}

			rotX += Math.PI;

			if (rotZ > 0.0) {
				rotZ -= Math.PI;
			} else {
				rotZ += Math.PI;
			}
		}

		return new Vector3D(-rotX * 180.0 / Math.PI, rotY * 180.0 / Math.PI, rotZ * 180.0 / Math.PI);

	}


	/**
	 * Calculates a view matrix for a given eye position, a look-at position and an up vector.
	 * @param eyex The x component of the eye position.
	 * @param eyey The y component of the eye position.
	 * @param eyez The z component of the eye position.
	 * @param centerx The x componenent of the look-at position that is in the center of the view.
	 * @param centery The y componenent of the look-at position that is in the center of the view.
	 * @param centerz The z componenent of the look-at position that is in the center of the view.
	 * @param upx The x componenent of the vector mapped to the y-direction of the view matrix.
	 * @param upy The y componenent of the vector mapped to the y-direction of the view matrix.
	 * @param upz The z componenent of the vector mapped to the y-direction of the view matrix.
	 * @return the calculated view matrix.
	 */
	public static function lookAt(eye:Vector3D, center:Vector3D, up:Vector3D) {

		// remember: z out of screen
		var zx:Float = eye.x - center.x;
		var zy:Float = eye.y - center.y;
		var zz:Float = eye.z - center.z;

		// normalise z
		var zlen:Float = Math.sqrt(zx * zx + zy * zy + zz * zz);
		zx /= zlen;
		zy /= zlen;
		zz /= zlen;

		// Calculate cross product of up and z to get x
		// (x coming out of plane containing up and z: up not necessarily perpendicular to z)
		var xx:Float =  up.y * zz - up.z * zy;
		var xy:Float = -up.x * zz + up.z * zx;
		var xz:Float =  up.x * zy - up.y * zx;

		// up not necessarily a unit vector so normalise x
		var xlen:Float = Math.sqrt(xx * xx + xy * xy + xz * xz);
		xx /= xlen;
		xy /= xlen;
		xz /= xlen;

		// calculate y: cross product of z and x (x and z unit vector so no need to normalise after)
		var yx:Float =  zy * xz - zz * xy;
		var yy:Float = -zx * xz + zz * xx;
		var yz:Float =  zx * xy - zy * xx;

		// Create rotation matrix from new coorinate system
		var lookat = new Matrix3D();
		var raw:Vector<Float> = rawDataContainerWithRowMajorValues(xx, xy, xz, 0.0, yx, yy, yz, 0.0, zx, zy, zz, 0.0, 0.0, 0.0, 0.0, 1.0);
		lookat.copyRawDataFrom(raw);

		// create translation matrix
		var translation = new Matrix3D();
		var raw:Vector<Float> = rawDataContainerWithRowMajorValues(1, 0, 0, -eye.x, 0, 1, 0, -eye.y, 0, 0, 1, -eye.z, 0, 0, 0, 1);
		translation.copyRawDataFrom(raw);

		// calculate final lookat (projection) matrix from combination of both rotation and translation
		lookat.prepend(translation);

		return lookat;
	}

	/**
	 * Calculates a projection matrix for a perspective view.
	 * @param fovy The field of view in the y direction.
	 * @param aspect The aspect ratio of the display.
	 * @param near The nearest distance along the z-axis for which elements are rendered.
	 * @param far the furthest distance along the z-axis for which elements are rendered.
	 * @param zoom The zoom factor.
	 * @param orientation indicates the rotation (about z) for the projection.
	 */
	public static function perspectiveMatrix(fovy:Float, aspect:Float, near:Float, far:Float, zoom:Float /*, orientation:DeviceOrientation */):Matrix3D {
//		if (orientation == Isgl3dOrientation90Clockwise || orientation == Isgl3dOrientation90CounterClockwise) {
//			aspect = 1. / aspect;
//		}

		var top:Float = Math.tan(fovy * Math.PI / 360.0) * near / zoom;
		var bottom:Float = -top;
		var left:Float = aspect * bottom;
		var right:Float = aspect * top;

		var matrix:Matrix3D = new Matrix3D();
		var raw:Vector<Float> = matrix.rawData;

		raw[0] = (2 * near) / (right - left);
		raw[1] = 0;
		raw[2] = 0;
		raw[3] = 0;

		raw[4] = 0;
		raw[5] = 2 * near / (top - bottom);
		raw[6] = 0;
		raw[7] = 0;

		raw[8] = (right + left) / (right - left);
		raw[9] = (top + bottom) / (top - bottom);
		raw[10] = -(far + near) / (far - near);
		raw[11] = -1;

		raw[12] = 0;
		raw[13] = 0;
		raw[14] = -(2.0 * far * near) / (far - near);
		raw[15] = 0;

//		if (orientation == Isgl3dOrientation90Clockwise) {
//			float orientationArray[9] = {0, -1, 0, 1, 0, 0, 0, 0, 1};
//			Isgl3dMatrix4 orientationMatrix = im4CreateFromArray9(orientationArray);
//
//			im4MultiplyOnLeft3x3(&matrix, &orientationMatrix);
//
//		} else if (orientation == Isgl3dOrientation180) {
//			float orientationArray[9] = {-1, 0, 0, 0, -1, 0, 0, 0, 1};
//			Isgl3dMatrix4 orientationMatrix = im4CreateFromArray9(orientationArray);
//
//			im4MultiplyOnLeft3x3(&matrix, &orientationMatrix);
//
//		} else if (orientation == Isgl3dOrientation90CounterClockwise) {
//			float orientationArray[9] = {0, 1, 0, -1, 0, 0, 0, 0, 1};
//			Isgl3dMatrix4 orientationMatrix = im4CreateFromArray9(orientationArray);
//
//			im4MultiplyOnLeft3x3(&matrix, &orientationMatrix);
//		}

		return matrix;
	}


	/**
	 * Calculates a projection matrix for an orthographic view.
	 * @param left The left-most position along the x-axis for which elements are rendered.
	 * @param right The right-most position along the x-axis for which elements are rendered.
	 * @param bottom The bottom-most position along the y-axis for which elements are rendered.
	 * @param top The top-most position along the y-axis for which elements are rendered.
	 * @param near The nearest distance along the z-axis for which elements are rendered.
	 * @param far the furthest distance along the z-axis for which elements are rendered.
	 * @param zoom The zoom factor.
	 * @param orientation indicates the rotation (about z) for the projection.
	 */
	public static function orthoMatrix(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float, zoom:Float /*, orientation:DeviceOrientation*/):Matrix3D {
		var tx:Float = (left + right) / ((right - left) * zoom);
		var ty:Float = (top + bottom) / ((top - bottom) * zoom);
		var tz:Float = (far + near) / (far - near);

		var matrix:Matrix3D = new Matrix3D();
		var raw:Vector<Float> = matrix.rawData;

		// THE FOLLOWING INDICES ARE PROBABLY WRONG

//		if (orientation == Isgl3dOrientation0) {
		raw[0] = 2.0 / (right - left);
		raw[1] = 0;
		raw[2] = 0;
		raw[3] = 0;

		raw[4] = 0;
		raw[5] = 2.0 / (top - bottom);
		raw[6] = 0;
		raw[7] = 0;

		raw[8] = 0;
		raw[9] = 0;
		raw[10] = -2.0 / (far - near);
		raw[11] = 0;

		raw[12]  = -tx;
		raw[13]  = -ty;
		raw[14]  = -tz;
		raw[15]  = 1.0;

//		} else if (orientation == Isgl3dOrientation90Clockwise) {
//			matrix.sxx = 0;
//			matrix.sxy = -2 / (right - left);
//			matrix.sxz = 0;
//			matrix.tx  = tx;
//			matrix.syx = 2 / (top - bottom);
//			matrix.syy = 0;
//			matrix.syz = 0;
//			matrix.ty  = -ty;
//			matrix.szx = 0;
//			matrix.szy = 0;
//			matrix.szz = -2 / (far - near);
//			matrix.tz  = -tz;
//			matrix.swx = 0;
//			matrix.swy = 0;
//			matrix.swz = 0;
//			matrix.tw  = 1;
//
//		} else if (orientation == Isgl3dOrientation180) {
//			matrix.sxx = -2 / (right - left);
//			matrix.sxy = 0;
//			matrix.sxz = 0;
//			matrix.tx  = tx;
//			matrix.syx = 0;
//			matrix.syy = -2 / (top - bottom);
//			matrix.syz = 0;
//			matrix.ty  = ty;
//			matrix.szx = 0;
//			matrix.szy = 0;
//			matrix.szz = -2 / (far - near);
//			matrix.tz  = -tz;
//			matrix.swx = 0;
//			matrix.swy = 0;
//			matrix.swz = 0;
//			matrix.tw  = 1;
//
//		} else if (orientation == Isgl3dOrientation90CounterClockwise) {
//			matrix.sxx = 0;
//			matrix.sxy = 2 / (right - left);
//			matrix.sxz = 0;
//			matrix.tx  = -tx;
//			matrix.syx = -2 / (top - bottom);
//			matrix.syy = 0;
//			matrix.syz = 0;
//			matrix.ty  = ty;
//			matrix.szx = 0;
//			matrix.szy = 0;
//			matrix.szz = -2 / (far - near);
//			matrix.tz  = -tz;
//			matrix.swx = 0;
//			matrix.swy = 0;
//			matrix.swz = 0;
//			matrix.tw  = 1;
//		}
		return matrix;

	}

}
