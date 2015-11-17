package xt3d.primitives;

import xt3d.core.Geometry;

class Cube extends Geometry {

	// properties

	// members
	private var _width:Float;
	private var _height:Float;
	private var _depth:Float;
	private var _nx:Int;
	private var _ny:Int;
	private var _nz:Int;

	public static function create(width:Float, height:Float, depth:Float, nx:Int, ny:Int, nz:Int):Cube {
		var object = new Cube();

		if (object != null && !(object.initWithGeometry(width, height, depth, nx, ny, nz))) {
			object = null;
		}

		return object;
	}

	public function initWithGeometry(width:Float, height:Float, depth:Float, nx:Int, ny:Int, nz:Int):Bool {
		var retval;
		if ((retval = super.initGeometry())) {
			this._width = width;
			this._height = height;
			this._depth = depth;
			this._nx = nx;
			this._ny = ny;
			this._nz = nz;

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
		var nVertices = (this._nx * this._ny + this._ny * this._nz + this._nz * this._nx) * 2;
		var nIndices = ((this._nx - 1) * (this._ny - 1) +
						(this._ny - 1) * (this._nz - 1) +
						(this._nz - 1) * (this._nx - 1)) * 2 * 6;

		// Create vertex data
		var vertexData = super.createInterleavedVertexData(8, null, nVertices * 8);
		vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

		var indices = super.createIndexData(nIndices);

		var vertexOffset = 0;
		vertexOffset = createPlane(vertexOffset, this._nx, this._ny, this._width,  this._height,  0.0,  0.0,  -0.5 * this._depth,  0.0,  0.0, -1.0, true);
		vertexOffset = createPlane(vertexOffset, this._nx, this._ny, this._width,  this._height,  0.0,  0.0,   0.5 * this._depth,  0.0,  0.0,  1.0, false);
		vertexOffset = createPlane(vertexOffset, this._ny, this._nz, this._height, this._depth,  -0.5 * this._width, 0.0,    0.0, -1.0,  0.0,  0.0, true);
		vertexOffset = createPlane(vertexOffset, this._ny, this._nz, this._height, this._depth,   0.5 * this._width, 0.0,    0.0,  1.0,  0.0,  0.0, false);
		vertexOffset = createPlane(vertexOffset, this._nz, this._nx, this._depth,  this._width,   0.0, -0.5 * this._height,  0.0,  0.0, -1.0,  0.0, true);
		vertexOffset = createPlane(vertexOffset, this._nz, this._nx, this._depth,  this._width,   0.0,  0.5 * this._height,  0.0,  0.0,  1.0,  0.0, false);
	}

	private function createPlane(vertexOffset:Int, nx:Int, ny:Int, width:Float, height:Float, transX:Float, transY:Float, transZ:Float, normalX:Float, normalY:Float, normalZ:Float, clockwise:Bool):Int {
		var indices = this._indexData;
		var vertexData = this._interleavedVertexData;

		var planeX:Float;
		var planeY:Float;
		var x:Float;
		var y:Float;
		var z:Float;
		var u:Float;
		var v:Float;


		// Calculate vertex data attributes
		for (j in 0 ... ny) {
			planeY = -(height / 2.0) + j * (height / (ny - 1));
			v = 1.0 - 1.0 * j / (ny - 1);
			if (clockwise) {
				v = 1.0 - v;
			}

			for (i in 0 ... nx) {
				planeX = -(width / 2.0) + i * (width / (nx - 1));
				u = 1.0 * i / (nx - 1);

				if (normalZ != 0.0) {
					x = transX + planeX;
					y = transY + planeY;
					z = transZ;

				} else if (normalX != 0.0) {
					x = transX;
					y = transY + planeX;
					z = transZ + planeY;

				} else {
					x = transX + planeY;
					y = transY;
					z = transZ + planeX;
				}

				vertexData.push(x);
				vertexData.push(y);
				vertexData.push(z);

				vertexData.push(normalX);
				vertexData.push(normalY);
				vertexData.push(normalZ);

				vertexData.push(u);
				vertexData.push(v);
			}
		}

		// Calculate indices
		var first:Int;
		var second:Int;
		var third:Int;
		var fourth:Int;
		for (j in 0 ... ny - 1) {
			for (i in 0 ... nx - 1) {

				first = vertexOffset + j * nx + i;
				second = clockwise ? first + 1 : first + nx;
				third = clockwise ? first + nx : first + 1;
				fourth = clockwise ? third + 1 : second + 1;

				indices.push(first);
				indices.push(third);
				indices.push(second);

				indices.push(second);
				indices.push(third);
				indices.push(fourth);
			}
		}

		return vertexOffset + nx * ny;
	}

}
