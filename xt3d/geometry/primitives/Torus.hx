package xt3d.geometry.primitives;

import xt3d.geometry.Geometry;
import xt3d.geometry.GeometryUtils;

class Torus extends Geometry {

	// properties

	// members
	private var _radius:Float;
	private var _tubeRadius:Float;
	private var _ns:Int;
	private var _nt:Int;

	public static function create(radius:Float = 1.0, tubeRadius:Float = 4.0, ns:Int = 8, nt:Int = 8):Torus {
		var object = new Torus();

		if (object != null && !(object.initWithGeometry(radius, tubeRadius, ns, nt))) {
			object = null;
		}

		return object;
	}

	public function initWithGeometry(radius:Float = 1.0, tubeRadius:Float = 4.0, ns:Int = 8, nt:Int = 8):Bool {
		var retval;
		if ((retval = super.initGeometry())) {
			this._radius = radius;
			this._tubeRadius = tubeRadius;
			this._ns = ns;
			this._nt = nt;

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
		var nVertices = (this._ns + 1) * (this._nt + 1);
		var nIndices = this._ns * this._nt * 6;

		// Create vertex data
		var stride = 8;
		var vertexData = super.createInterleavedVertexData(stride, null, nVertices * stride);
		vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

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
		var nx:Float;
		var ny:Float;
		var nz:Float;
		var u:Float;
		var v:Float;
		var index = 0;


		// Calculate vertex data attributes
		for (s in 0 ... this._ns + 1) {
			theta = s * 2.0 * Math.PI / this._ns;
			sinTheta = Math.sin(theta);
			cosTheta = Math.cos(theta);

			for (t in 0 ... this._nt + 1) {
				phi = t * 2 * Math.PI / this._nt;
				sinPhi = Math.sin(phi);
				cosPhi = Math.cos(phi);

				x = sinTheta * (this._radius + this._tubeRadius * sinPhi);
				y =                          - this._tubeRadius * cosPhi;
				z = cosTheta * (this._radius + this._tubeRadius * sinPhi);

				nx = sinTheta * sinPhi;
				ny = -cosPhi;
				nz = cosTheta * sinPhi;

				u = 1.0 * s / this._ns;
				v = 1.0 - (1.0 * t / this._nt);

				index = ((s * (this._nt + 1)) + t) * stride;

				vertexData.set(index + 0, x);
				vertexData.set(index + 1, y);
				vertexData.set(index + 2, z);

				vertexData.set(index + 3, nx);
				vertexData.set(index + 4, ny);
				vertexData.set(index + 5, nz);

				vertexData.set(index + 6, u);
				vertexData.set(index + 7, v);
			}
		}

		// Calculate indices
		var first:Int;
		var second:Int;
		var third:Int;
		var fourth:Int;
		for (s in 0 ... this._ns) {
			for (t in 0 ... this._nt) {

				first = (s * (this._nt + 1)) + t;
				second = first + (this._nt + 1);
				third = first + 1;
				fourth = second + 1;

				indices.push(first);
				indices.push(second);
				indices.push(third);

				indices.push(second);
				indices.push(fourth);
				indices.push(third);
			}
		}
	}
}
