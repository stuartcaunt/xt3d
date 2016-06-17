package xt3d.geometry.primitives;

import xt3d.gl.XTGL;
import xt3d.utils.color.Color;
import xt3d.math.Vector4;
import xt3d.geometry.Geometry;
import xt3d.geometry.GeometryUtils;

typedef Polygon = {
	points:Array<Vector4>,
	?isClosed:Bool,
	?color:Color,
};

class Lines extends Geometry {

	// properties

	// members
	private var _polygons:Array<Polygon>;

	public static function createWithPolygon(polygon:Polygon):Lines {
		var object = new Lines();

		if (object != null && !(object.initWithPolygon(polygon))) {
			object = null;
		}

		return object;
	}

	public static function createWithPolygonArray(polygonArray:Array<Polygon>):Lines {
		var object = new Lines();

		if (object != null && !(object.initWithPolygonArray(polygonArray))) {
			object = null;
		}

		return object;
	}

	public function initWithPolygon(polygon:Polygon):Bool {
		var retval;
		if ((retval = super.initGeometry(XTGL.GL_LINES))) {
			this._polygons = [ polygon ];

			this.createGeometry();

		}

		return retval;
	}

	public function initWithPolygonArray(polygonArray:Array<Polygon>):Bool {
		var retval;
		if ((retval = super.initGeometry(XTGL.GL_LINES))) {
			this._polygons = polygonArray;

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
		var nVertices = 0;
		var nIndices = 0;

		// Calculate number of vertices for all the polygons
		for (polygon in this._polygons) {
			nVertices += polygon.points.length;
			nIndices += 2 * (polygon.points.length - 1);

			if (polygon.isClosed) {
				nIndices += 2;
			}
		}

		var positions = super.createPositionData(nVertices * 3);
		var colors = super.createByteColorData(nVertices * 4);
		var indices = super.createIndexData(nIndices);

		var index = 0;
		var positionOffset = 0;
		var colorOffset = 0;
		for (polygon in this._polygons) {
			var color = polygon.color != null ? polygon.color : Color.white;
			var colorArray = color.rgbaByteArray;
			for (point in polygon.points) {
				positionOffset = index * 3;
				colorOffset = index * 4;

				positions.set(positionOffset + 0, point.x);
				positions.set(positionOffset + 1, point.y);
				positions.set(positionOffset + 2, point.z);

				colors.set(colorOffset + 0, colorArray[0]);
				colors.set(colorOffset + 1, colorArray[1]);
				colors.set(colorOffset + 2, colorArray[2]);
				colors.set(colorOffset + 3, colorArray[3]);

				index++;
			}
		}


		// Calculate indices
		var vertexIndex = 0;
		var index = 0;
		for (polygon in this._polygons) {
			for (i in 0 ... polygon.points.length - 1) {
				indices.set(index + 0, vertexIndex);
				indices.set(index + 1, vertexIndex + 1);

				index += 2;
				vertexIndex++;
			}

			if (polygon.isClosed) {
				indices.set(index + 0, vertexIndex);
				indices.set(index + 1, vertexIndex - polygon.points.length + 1);
				index += 2;
			}

			vertexIndex++;
		}

	}
}
