package xt3d.geometry.primitives;

import xt3d.geometry.Geometry;

class Arrow extends Geometry {

	// properties

	// members
	private var _height:Float;
	private var _radius:Float;
	private var _headHeight:Float;
	private var _headRadius:Float;
	private var _ns:Int;
	private var _nt:Int;

	public static function create(height:Float = 10.0, radius:Float = 1.0, headHeight:Float = 4.0, headRadius:Float = 2.0, ns:Int = 8, nt:Int = 8):Arrow {
		var object = new Arrow();

		if (object != null && !(object.initWithGeometry(height, radius, headHeight, headRadius, ns, nt))) {
			object = null;
		}

		return object;
	}

	public function initWithGeometry(height:Float = 10.0, radius:Float = 1.0, headHeight:Float = 4.0, headRadius:Float = 2.0, ns:Int = 8, nt:Int = 8):Bool {
		var retval;
		if ((retval = super.initGeometry())) {
			this._height = height;
			this._radius = radius;
			this._headHeight = headHeight;
			this._headRadius = headRadius;
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
		var nVertices = (this._ns + 1) * (this._nt + 4);
		var nIndices = this._ns * (this._nt +3) * 6;

		// Create vertex data
		var stride = 8;
		var vertexData = super.createInterleavedVertexData(stride, null, nVertices * stride);
		vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

		var indices = super.createIndexData(nIndices);

		var totalHeight:Float = this._radius + this._height + (this._headRadius - this._radius);

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


		var vOffset:Float = this._radius;
		var headStart:Float = this._height - this._headHeight;

		var theta:Float;
		// Create middle
		for (t in 0 ... this._nt + 1) {
			for (s in 0 ... this._ns + 1) {
				theta = s * 2 * Math.PI / this._ns;

				vertexData.push(this._radius * Math.sin(theta));
				vertexData.push(-(this._height / 2) + (t * headStart / this._nt));
				vertexData.push(this._radius * Math.cos(theta));

				vertexData.push(Math.sin(theta));
				vertexData.push(0.0);
				vertexData.push(Math.cos(theta));

				vertexData.push(1.0 * s / this._ns);
				vertexData.push(1.0 - (vOffset + t * headStart / this._nt) / totalHeight);
			}
		}

		// Create head
		for (s in 0 ... this._ns + 1) {
			theta = s * 2 * Math.PI / this._ns;

			vertexData.push(this._headRadius * Math.sin(theta));
			vertexData.push((this._height / 2) - this._headHeight);
			vertexData.push(this._headRadius * Math.cos(theta));

			vertexData.push(Math.sin(theta));
			vertexData.push(0.0);
			vertexData.push(Math.cos(theta));

			vertexData.push(1.0 * s / this._ns);
			vertexData.push(1.0 - (headStart + this._headRadius) / totalHeight);
		}

		// Create top
		for (s in 0 ... this._ns + 1) {
			vertexData.push(0.0);
			vertexData.push(this._height / 2);
			vertexData.push(0.0);

			vertexData.push(0.0);
			vertexData.push(1.0);
			vertexData.push(0.0);

			vertexData.push(1.0 * s / this._ns);
			vertexData.push(0.0);
		}

		var totalNT = this._nt + 3;


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
