package kfsgl.math;

import openfl.Vector;
import flash.geom.Matrix3D;

import kfsgl.math.Quaternion;

class MatrixHelper {

	public function new() {
	}

	public static function setRotationFromEuler(m:Matrix3D, rotationX:Float, rotationY:Float, rotationZ:Float):Void {
		var q:Quaternion = Quaternion.createFromEuler(rotationX, rotationY, rotationZ);

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

	}

}
