package kfsgl.primitives;

import kfsgl.utils.gl.IndexData;
import kfsgl.utils.gl.FloatVertexData;
import kfsgl.core.Geometry;

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
		var positions = FloatVertexData.create();
		var normals = FloatVertexData.create();
		var uvs = FloatVertexData.create();
		var indices = IndexData.create();

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

				positions.push(this._radius * x);
				positions.push(this._radius * y);
				positions.push(this._radius * z);

				normals.push(x);
				normals.push(y);
				normals.push(z);

				uvs.push(u);
				uvs.push(v);
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

		super.positions = positions;
		super.normals = normals;
		super.uvs = uvs;
		super.indices = indices;
	}


}
