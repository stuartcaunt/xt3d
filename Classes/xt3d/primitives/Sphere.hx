package xt3d.primitives;

import xt3d.core.Geometry;

class Sphere extends Geometry {

	// properties

	// members
	private var _radius:Float;
	private var _lons:Int;
	private var _lats:Int;

	public static function create(radius:Float = 1.0, lons:Int = 8, lats:Int = 8):Geometry {
		var object = new Sphere();

		if (object != null && !(object.initWithGeometry(radius, lons, lats))) {
			object = null;
		}

		return object;
	}

	public function initWithGeometry(radius:Float, lons:Int, lats:Int):Bool {
		var retval;
		if ((retval = super.init())) {
			this._radius = radius;
			this._lats = lats;
			this._lons = lons;

			this.createGeometry();

		}

		return retval;
	}

	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	private function createGeometry():Void {
		// Calculate number of vertices and indices (fixed)
		var nVertices = (this._lats + 1) * (this._lons + 1);
		var nIndices = this._lats * this._lons * 6;

		// Create vertex data
		var vertexData = super.createInterleavedVertexData(8, null, nVertices * 8);
		vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

//		var positions = super.createPositionData();
//		var normals = super.createNormalData();
//		var uvs = super.createUVData();
		var colors = super.createByteColorData(nVertices * 4);
		var indices = super.createIndexData(nIndices);

		var theta:Float;
		var phi:Float;
		var sinTheta:Float;
		var cosTheta:Float;
		var sinPhi:Float;
		var cosPhi:Float;
		var x:Float;
		var y:Float;
		var z:Float;
		var u:Float;
		var v:Float;
		var colorFrequency:Float = 2.0 * Math.PI;
		var colorWidth:Float = 95;
		var colorCenter:Float = 160;


		// Calculate vertex data attributes
		for (iLat in 0 ... this._lats + 1) {
			theta = iLat * Math.PI / this._lats;
			sinTheta = Math.sin(theta);
			cosTheta = Math.cos(theta);

			for (iLon in 0 ... this._lons + 1) {
				phi = iLon * 2 * Math.PI / this._lons;
				sinPhi = Math.sin(phi);
				cosPhi = Math.cos(phi);

				x = cosPhi * sinTheta;
				y = cosTheta;
				z = sinPhi * sinTheta;
				u = 1.0 - (1.0 * iLon / this._lons);
				v = 1.0 * iLat / this._lats;

				vertexData.push(this._radius * x);
				vertexData.push(this._radius * y);
				vertexData.push(this._radius * z);

				vertexData.push(x);
				vertexData.push(y);
				vertexData.push(z);

				vertexData.push(u);
				vertexData.push(v);

//				positions.push(this._radius * x);
//				positions.push(this._radius * y);
//				positions.push(this._radius * z);
//
//				normals.push(x);
//				normals.push(y);
//				normals.push(z);
//
//				uvs.push(u);
//				uvs.push(v);

				// Color as function of y
				// http://krazydad.com/tutorials/makecolors.php
				var f:Float = 0.5 * (y + 1);

				var red = Math.sin(colorFrequency * f + 0) * colorWidth + colorCenter;
				var green = Math.sin(colorFrequency * f + 2) * colorWidth + colorCenter;
				var blue = Math.sin(colorFrequency * f + 4) * colorWidth + colorCenter;

				colors.push(Std.int(red));
				colors.push(Std.int(green));
				colors.push(Std.int(blue));
				colors.push(255);
			}
		}

		// Calculate indices
		var first:Int;
		var second:Int;
		var third:Int;
		var fourth:Int;
		for (iLat in 0 ... this._lats) {
			for (iLon in 0 ... this._lons) {

				first = (iLat * (this._lons + 1)) + iLon;
				second = first + (this._lons + 1);
				third = first + 1;
				fourth = second + 1;

				indices.push(first);
				indices.push(third);
				indices.push(second);

				indices.push(second);
				indices.push(third);
				indices.push(fourth);
			}
		}

	}
}
