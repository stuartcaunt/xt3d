package xt3d.primitives;

import xt3d.core.Geometry;

class Plane extends Geometry {

	// properties

	// members
	private var _width:Float;
	private var _height:Float;
	private var _nx:Int;
	private var _ny:Int;

	public static function create(width:Float, height:Float, nx:Int, ny:Int):Plane {
		var object = new Plane();

		if (object != null && !(object.initWithGeometry(width, height, nx, ny))) {
			object = null;
		}

		return object;
	}

	public function initWithGeometry(width:Float, height:Float, nx:Int, ny:Int):Bool {
		var retval;
		if ((retval = super.initGeometry())) {
			this._width = width;
			this._height = height;
			this._nx = nx;
			this._ny = ny;

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
		var nVertices = (this._nx + 1) * (this._ny + 1) * 8;
		var nIndices = this._nx * this._ny * 6;

		// Create vertex data
		var vertexData = super.createInterleavedVertexData(8, null, nVertices);
		vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

		var indices = super.createIndexData(nIndices);

		var x:Float;
		var y:Float;
		var u:Float;
		var v:Float;


		// Calculate vertex data attributes
		for (j in 0 ... this._ny + 1) {
			y = -(this._height / 2.0) + j * (this._height / this._ny);
			v = 1.0 - 1.0 * j / this._ny;

			for (i in 0 ... this._nx + 1) {
				x = -(this._width / 2.0) + i * (this._width / this._nx);
				u = 1.0 * i / this._nx;

				vertexData.push(x);
				vertexData.push(y);
				vertexData.push(0.0);

				vertexData.push(0.0);
				vertexData.push(0.0);
				vertexData.push(1.0);

				vertexData.push(u);
				vertexData.push(v);
			}
		}

		// Calculate indices
		var first:Int;
		var second:Int;
		var third:Int;
		var fourth:Int;
		for (j in 0 ... this._ny) {
			for (i in 0 ... this._nx) {

				first = j * (this._nx + 1) + i;
				second = first + (this._nx + 1);
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
