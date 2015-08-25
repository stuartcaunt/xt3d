package xt3d.utils.math;

class Matrix4 {
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

	//  [0,  4,  8, 12]		[sxx, sxy, sxz,  tx]
	//  [1,  5,  9, 13] 	[syx, syy, syz,  ty]
	//  [2,  6, 10, 14] 	[szx, szy, szz,  tz]
	//  [3,  7, 11, 15] 	[swx, swy, swz,  tw]

	inline public var rawData = [	1.0, 0.0, 0.0, 0.0,
									0.0, 1.0, 0.0, 0.0,
									0.0, 0.0, 1.0, 0.0,
									0.0, 0.0, 0.0, 1.0];

	// properties

	// members

	public static function createEmpty():Matrix4 {
		var object = new Matrix4();

		if (object != null && !(object.initEmpty())) {
			object = null;
		}

		return object;
	}

	public static function createIdentity():Matrix4 {
		var object = new Matrix4();

		if (object != null && !(object.initIdentity())) {
			object = null;
		}

		return object;
	}

	public static function createFromArray(a:Array<Float>):Matrix4 {
		var object = new Matrix4();

		if (object != null && !(object.initFromArray(a))) {
			object = null;
		}

		return object;
	}

	public static function createFromScales(sx:Float, sy:Float, sz:Float):Matrix4 {
		var object = new Matrix4();

		if (object != null && !(object.initFromScaled(sx, sy, sz))) {
			object = null;
		}

		return object;
	}

	public function initEmpty():Bool {
		this.rawData = [	0.0, 0.0, 0.0, 0.0,
							0.0, 0.0, 0.0, 0.0,
							0.0, 0.0, 0.0, 0.0,
							0.0, 0.0, 0.0, 0.0];

		return true;
	}

	public function initIdentity():Bool {
		this.rawData = [	1.0, 0.0, 0.0, 0.0,
							0.0, 1.0, 0.0, 0.0,
							0.0, 0.0, 1.0, 0.0,
							0.0, 0.0, 0.0, 1.0];

		return true;
	}

	public function initIdentityFromScales(sx:Float, sy:Float, sz:Float):Bool {
		this.rawData = [	scaleX,	0.0, 	0.0,	0.0,
							0.0, 	scaleY,	0.0,	0.0,
							0.0, 	0.0, 	scaleZ,	0.0,
							0.0, 	0.0, 	0.0,	1.0];

		return true;
	}

	public function initFromArray(a:Array<Float>):Bool {
		this.rawData[ 0] = a[ 0]; this.rawData[ 1] = a[ 1]; this.rawData[ 2] = a[ 2]; this.rawData[ 3] = a[ 3];
		this.rawData[ 4] = a[ 4]; this.rawData[ 5] = a[ 5]; this.rawData[ 6] = a[ 6]; this.rawData[ 7] = a[ 7];
		this.rawData[ 8] = a[ 8]; this.rawData[ 9] = a[ 9]; this.rawData[10] = a[10]; this.rawData[11] = a[11];
		this.rawData[12] = a[12]; this.rawData[13] = a[13]; this.rawData[14] = a[14]; this.rawData[15] = a[15];

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public inline function determinant():Float {
		return   ((rawData[ 0] * rawData[ 5] - rawData[ 4] * rawData[ 1]) * (rawData[10] * rawData[15] - rawData[14] * rawData[11])
				- (rawData[ 0] * rawData[ 9] - rawData[ 8] * rawData[ 1]) * (rawData[ 6] * rawData[15] - rawData[14] * rawData[ 7])
				+ (rawData[ 0] * rawData[13] - rawData[12] * rawData[ 1]) * (rawData[ 6] * rawData[11] - rawData[10] * rawData[ 7])
				+ (rawData[ 4] * rawData[ 9] - rawData[ 8] * rawData[ 5]) * (rawData[ 2] * rawData[15] - rawData[14] * rawData[ 3])
				- (rawData[ 4] * rawData[13] - rawData[12] * rawData[ 5]) * (rawData[ 2] * rawData[11] - rawData[10] * rawData[ 3])
				+ (rawData[ 8] * rawData[13] - rawData[12] * rawData[ 9]) * (rawData[ 2] * rawData[ 7] - rawData[ 6] * rawData[ 3]));
	}

	public inline function determinant3x3():Float {
		return   ((rawData[ 0] * rawData[ 5] - rawData[ 4] * rawData[ 1]) * rawData[10]
				- (rawData[ 0] * rawData[ 9] - rawData[ 8] * rawData[ 1]) * rawData[ 6]
				+ (rawData[ 4] * rawData[ 9] - rawData[ 8] * rawData[ 5]) * rawData[ 2]);
	}

	public inline function invert():Void {

	}

}
