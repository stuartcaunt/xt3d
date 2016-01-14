package xt3d.math;

import lime.utils.Float32Array;

import xt3d.utils.Types;
import xt3d.math.Vector4;
import xt3d.math.Matrix4;
import xt3d.math.Quaternion;

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


	static public var RAW_DATA_CONTAINER(get, null):Matrix4;
	static private function get_RAW_DATA_CONTAINER():Matrix4 {
		return new Matrix4(new Float32Array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]));
	}


	private static function matrixWithColumnMajorValues(
		v0, v1, v2, v3,
		v4, v5, v6, v7,
		v8, v9, v10, v11,
		v12, v13, v14, v15):Matrix4 {

		var raw:Matrix4 = MatrixHelper.RAW_DATA_CONTAINER;

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

	static private function matrixWithRowMajorValues(
		v0, v1, v2, v3,
		v4, v5, v6, v7,
		v8, v9, v10, v11,
		v12, v13, v14, v15):Matrix4 {

		var raw:Matrix4 = MatrixHelper.RAW_DATA_CONTAINER;

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

	public static inline function matrixWithRowMajorArray9(a:Array<Float>):Matrix4 {
		var raw:Matrix4 = MatrixHelper.RAW_DATA_CONTAINER;
		raw[0]  = a[0]; raw[1]  = a[3]; raw[2]  = a[6]; raw[3]  = 0.0;
		raw[4]  = a[1]; raw[5]  = a[4]; raw[6]  = a[7]; raw[7]  = 0.0;
		raw[8]  = a[2]; raw[9]  = a[5]; raw[10] = a[8]; raw[11] = 0.0;
		raw[12] =  0.0; raw[13] =  0.0; raw[14] =  0.0; raw[15] = 1.0;

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
	public static function setRotation(m:Matrix4, axis:Vector4, angle:Float):Void {
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
	public static function setRotationFromEuler(m:Matrix4, rotationX:Float, rotationY:Float, rotationZ:Float):Void {
		var q:Quaternion = Quaternion.createFromEuler(rotationX, rotationY, rotationZ);

		setRotationFromQuaternion(m, q);
	}

	/**
	 * Sets the rotational component of the matrix from a quaternion
	 * @param m The matrix.
	 * @param a The quaternion.
	 **/
	public static function setRotationFromQuaternion(m:Matrix4, q:Quaternion) {
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

		m[0] = 1 - 2 * (zz + ww);
		m[1] =     2 * (yz + xw);
		m[2] =     2 * (yw - xz);

		m[4] =     2 * (yz - xw);
		m[5] = 1 - 2 * (yy + ww);
		m[6] =     2 * (xy + zw);

		m[8] =     2 * (xz + yw);
		m[9] =     2 * (zw - xy);
		m[10] = 1 - 2 * (yy + zz);
	}

	/**
	 * Returns the equivalent Euler angles of the rotational components of a matrix.
	 * @param m The matrix.
	 * @result Vector containing the rotations about x, y and z (in degrees)
	 */
	public static function getEulerRotationFromMatrix(m:Matrix4):Vector4 {

		// Get rotation about X
		var rotX:Float = -Math.atan2(m[6], m[10]);

		// Create rotation matrix around X
		var matrix = new Matrix4();
		MatrixHelper.setRotation(matrix, new Vector4(1, 0, 0), rotX * 180.0 / Math.PI);

		// left-multipy rotation matrix with self to remove X rotation from transformation
		matrix.append(m);

		// Get rotation about Y
		var cosRotY:Float = Math.sqrt(matrix[0] * matrix[0] + matrix[1] * matrix[1]);
		var rotY:Float = Math.atan2(-matrix[2], cosRotY);

		// get rotation about Z
		var rotZ:Float = Math.atan2(-matrix[4], matrix[5]);


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

		return new Vector4(-rotX * 180.0 / Math.PI, rotY * 180.0 / Math.PI, rotZ * 180.0 / Math.PI);

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
	public static function lookAt(eye:Vector4, center:Vector4, up:Vector4) {

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
		var lookat = new Matrix4();
		var sMatrix:Matrix4 = matrixWithRowMajorValues(xx, xy, xz, 0.0, yx, yy, yz, 0.0, zx, zy, zz, 0.0, 0.0, 0.0, 0.0, 1.0);
		lookat.copyFrom(sMatrix);

		// create translation matrix
		var translation = new Matrix4();
		var sMatrix:Matrix4 = matrixWithRowMajorValues(1, 0, 0, -eye.x, 0, 1, 0, -eye.y, 0, 0, 1, -eye.z, 0, 0, 0, 1);
		translation.copyFrom(sMatrix);

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
	public static function perspectiveMatrix(fovy:Float, aspect:Float, near:Float, far:Float, zoom:Float, orientation:XTOrientation):Matrix4 {
		if (orientation == XTOrientation.Orientation90Clockwise || orientation == XTOrientation.Orientation90CounterClockwise) {
			aspect = 1.0 / aspect;
		}

		var top:Float = Math.tan(fovy * Math.PI / 360.0) * near / zoom;
		var bottom:Float = -top;
		var left:Float = aspect * bottom;
		var right:Float = aspect * top;

		var m:Matrix4 = new Matrix4();

		m[0] = (2 * near) / (right - left);
		m[1] = 0;
		m[2] = 0;
		m[3] = 0;

		m[4] = 0;
		m[5] = 2 * near / (top - bottom);
		m[6] = 0;
		m[7] = 0;

		m[8] = (right + left) / (right - left);
		m[9] = (top + bottom) / (top - bottom);
		m[10] = -(far + near) / (far - near);
		m[11] = -1;

		m[12] = 0;
		m[13] = 0;
		m[14] = -(2.0 * far * near) / (far - near);
		m[15] = 0;

		if (orientation == XTOrientation.Orientation90Clockwise) {
			var orientationMatrix = MatrixHelper.matrixWithRowMajorArray9([0, 1, 0, -1, 0, 0, 0, 0, 1]);
			append3x3(m, orientationMatrix);

		} else if (orientation == XTOrientation.Orientation180) {
			var orientationMatrix = MatrixHelper.matrixWithRowMajorArray9([-1, 0, 0, 0, -1, 0, 0, 0, 1]);
			append3x3(m, orientationMatrix);

		} else if (orientation == XTOrientation.Orientation90CounterClockwise) {
			var orientationMatrix = MatrixHelper.matrixWithRowMajorArray9([0, -1, 0, 1, 0, 0, 0, 0, 1]);
			append3x3(m, orientationMatrix);
		}

		return m;
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
	public static function orthoMatrix(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float, zoom:Float, orientation:XTOrientation):Matrix4 {
		var tx:Float = (left + right) / ((right - left) * zoom);
		var ty:Float = (top + bottom) / ((top - bottom) * zoom);
		var tz:Float = (far + near) / (far - near);

		var m:Matrix4 = new Matrix4();

		// THE FOLLOWING INDICES ARE PROBABLY WRONG

		if (orientation == XTOrientation.Orientation0) {
			m[0] = 2.0 / (right - left);
			m[1] = 0;
			m[2] = 0;
			m[3] = 0;

			m[4] = 0;
			m[5] = 2.0 / (top - bottom);
			m[6] = 0;
			m[7] = 0;

			m[8] = 0;
			m[9] = 0;
			m[10] = -2.0 / (far - near);
			m[11] = 0;

			m[12]  = -tx;
			m[13]  = -ty;
			m[14]  = -tz;
			m[15]  = 1.0;

		} else if (orientation == XTOrientation.Orientation90Clockwise) {
			m[0] = 0;
			m[1] = 2 / (top - bottom);
			m[2] = 0;
			m[3] = 0;

			m[4] = -2 / (right - left);
			m[5] = 0;
			m[6] = 0;
			m[7] = 0;

			m[8] = 0;
			m[9] = 0;
			m[10] = -2 / (far - near);
			m[11] = 0;

			m[12]  = tx;
			m[13]  = -ty;
			m[14]  = -tz;
			m[15]  = 1;

		} else if (orientation == XTOrientation.Orientation180) {
			m[0] = -2 / (right - left);
			m[1] = 0;
			m[2] = 0;
			m[3] = 0;

			m[4] = 0;
			m[5] = -2 / (top - bottom);
			m[6] = 0;
			m[7] = 0;

			m[8] = 0;
			m[9] = 0;
			m[10] = -2 / (far - near);
			m[11] = 0;

			m[12]  = tx;
			m[13]  = ty;
			m[14]  = -tz;
			m[15]  = 1;

		} else if (orientation == XTOrientation.Orientation90CounterClockwise) {
			m[0] = 0;
			m[1] = -2 / (top - bottom);
			m[2] = 0;
			m[3] = 0;

			m[4] = 2 / (right - left);
			m[5] = 0;
			m[6] = 0;
			m[7] = 0;

			m[8] = 0;
			m[9] = 0;
			m[10] = -2 / (far - near);
			m[11] = 0;

			m[12]  = -tx;
			m[13]  = ty;
			m[14]  = -tz;
			m[15]  = 1;
		}
		return m;

	}

	static public inline function copy3x3ToArray(m:Matrix4, a:Array<Float>):Void {
		a[0] = m[0];
		a[1] = m[1];
		a[2] = m[2];
		a[3] = m[4];
		a[4] = m[5];
		a[5] = m[6];
		a[6] = m[8];
		a[7] = m[9];
		a[8] = m[10];
	}

	public static inline function transform4x4VectorToArray(m:Matrix4, v:Vector4, a:Array<Float>):Void {

		var x:Float = v.x, y:Float = v.y, z:Float = v.z, w:Float = v.w;

		a[0] = x * m[0] + y * m[4] + z * m[8] + w * m[12];
		a[1] = x * m[1] + y * m[5] + z * m[9] + w * m[13];
		a[2] = x * m[2] + y * m[6] + z * m[10] + w * m[14];
		a[3] = x * m[3] + y * m[7] + z * m[11] + w * m[15];
	}

	public static inline function transform3x3VectorToArray(m:Matrix4, v:Vector4, a:Array<Float>):Void {

		var x:Float = v.x, y:Float = v.y, z:Float = v.z;

		a[0] = x * m[0] + y * m[4] + z * m[8];
		a[1] = x * m[1] + y * m[5] + z * m[9];
		a[2] = x * m[2] + y * m[6] + z * m[10];
	}

	public static inline function append3x3(a:Matrix4, b:Matrix4):Void {
		var m111:Float = a[0];
		var m121:Float = a[4];
		var m131:Float = a[8];
		var m112:Float = a[1];
		var m122:Float = a[5];
		var m132:Float = a[9];
		var m113:Float = a[2];
		var m123:Float = a[6];
		var m133:Float = a[10];

		var m211:Float = b[0];
		var m221:Float = b[4];
		var m231:Float = b[8];
		var m212:Float = b[1];
		var m222:Float = b[5];
		var m232:Float = b[9];
		var m213:Float = b[2];
		var m223:Float = b[6];
		var m233:Float = b[10];

		a[0]  = m111 * m211 + m112 * m221 + m113 * m231;
		a[1]  = m111 * m212 + m112 * m222 + m113 * m232;
		a[2]  = m111 * m213 + m112 * m223 + m113 * m233;
		a[4]  = m121 * m211 + m122 * m221 + m123 * m231;
		a[5]  = m121 * m212 + m122 * m222 + m123 * m232;
		a[6]  = m121 * m213 + m122 * m223 + m123 * m233;
		a[8]  = m131 * m211 + m132 * m221 + m133 * m231;
		a[9]  = m131 * m212 + m132 * m222 + m133 * m232;
		a[10] = m131 * m213 + m132 * m223 + m133 * m233;
	}

}
