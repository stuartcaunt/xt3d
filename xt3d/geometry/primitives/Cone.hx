package xt3d.geometry.primitives;

import xt3d.geometry.Geometry;

class Cone extends Geometry {

	// properties

	// members
	private var _height:Float;
	private var _topRadius:Float;
	private var _bottomRadius:Float;
	private var _ns:Int;
	private var _nt:Int;
	private var _openEnded:Bool;

	public static function create(height:Float, topRadius:Float = 1.0, bottomRadius:Float = 4.0, ns:Int = 8, nt:Int = 8, openEnded:Bool = true):Cone {
		var object = new Cone();

		if (object != null && !(object.initWithGeometry(height, topRadius, bottomRadius, ns, nt, openEnded))) {
			object = null;
		}

		return object;
	}

	public function initWithGeometry(height:Float, topRadius:Float = 1.0, bottomRadius:Float = 4.0, ns:Int = 8, nt:Int = 8, openEnded:Bool = true):Bool {
		var retval;
		if ((retval = super.initGeometry())) {
			this._height = height;
			this._topRadius = topRadius;
			this._bottomRadius = bottomRadius;
			this._ns = ns;
			this._nt = nt;
			this._openEnded = openEnded;

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
		if (!this._openEnded) {
			nVertices += 2 * (this._ns + 1);
			nIndices += 2 * this._ns * 6;
		}

		// Create vertex data
		var stride = 8;
		var vertexData = super.createInterleavedVertexData(stride, null, nVertices * stride);
		vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

		var indices = super.createIndexData(nIndices);

		var totalHeight:Float;
		if (this._openEnded) {
			totalHeight = this._height;
		} else {
			totalHeight = this._bottomRadius + this._height + this._topRadius;
		}

		var dR:Float = this._bottomRadius - this._topRadius;
		var length:Float = Math.sqrt(this._height * this._height + dR * dR);

		if (!this._openEnded) {
			// Create bottom
			for (s in 0 ... this._ns + 1) {

				vertexData.push(0.0);
				vertexData.push(-(this._height / 2.0));
				vertexData.push(0.0);

				vertexData.push(0.0);
				vertexData.push(-1.0);
				vertexData.push(0.0);

				vertexData.push(1.0 * s / this._ns);
				vertexData.push(1.0);
			}
		}

		var vOffset:Float;
		if (this._openEnded) {
			vOffset = 0;
		} else {
			vOffset = this._bottomRadius;
		}


		// Create middle
		for (t in 0 ... this._nt + 1) {
			var radius:Float = this._bottomRadius - (this._bottomRadius - this._topRadius) * t / this._nt;
			for (s in 0 ... this._ns + 1) {
				var theta:Float = s * 2 * Math.PI / this._ns;

				vertexData.push(radius * Math.sin(theta));
				vertexData.push(-(this._height / 2) + (t * this._height / _nt));
				vertexData.push(radius * Math.cos(theta));

				vertexData.push(Math.sin(theta) * this._height / length);
				vertexData.push(dR / length);
				vertexData.push(Math.cos(theta) * this._height / length);

				vertexData.push(1.0 * s / this._ns);
				vertexData.push(1.0 - (vOffset + t * this._height / this._nt) / totalHeight);
			}
		}

		// Create top
		if (!this._openEnded) {
			for (s in 0 ... this._ns + 1) {

				vertexData.push(0.0);
				vertexData.push((this._height / 2.0));
				vertexData.push(0.0);

				vertexData.push(0.0);
				vertexData.push(1.0);
				vertexData.push(0.0);

				vertexData.push(1.0 * s / this._ns);
				vertexData.push(1.0);
			}
		}


		var totalNT:Int;
		if (this._openEnded) {
			totalNT = this._nt;
		} else {
			totalNT = this._nt + 2;
		}


		// Calculate indices
		var first:Int;
		var second:Int;
		var third:Int;
		var fourth:Int;
		for (t in 0 ... totalNT) {
			for (s in 0 ... this._ns) {

				first = (t * (this._ns + 1)) + s;
				second = first + (this._ns + 1);
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
