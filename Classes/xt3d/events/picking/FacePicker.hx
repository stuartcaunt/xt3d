package xt3d.events.picking;

import xt3d.node.Scene;
import xt3d.node.Camera;
import xt3d.core.Director;
import lime.math.Vector2;
import xt3d.core.RendererOverrider;
import xt3d.core.Geometry;

enum FacePickerGeometryType {
	FacePickerGeometryTypeTriangle;
	FacePickerGeometryTypeQuad;
	FacePickerGeometryTypeCustom;
}

class FacePicker {

	// properties

	// members
	private var _facePickerGeometry:Geometry = null;
	private var _rendererOverrider:RendererOverrider = null;

	public static function create(geometryType:FacePickerGeometryType = null):FacePicker {
		var object = new FacePicker();

		if (object != null && !(object.init(geometryType))) {
			object = null;
		}

		return object;
	}

	public function init(geometryType:FacePickerGeometryType = null):Bool {

		if (geometryType == null) {
			geometryType = FacePickerGeometryType.FacePickerGeometryTypeTriangle;
		}

		// Create face picking geometry
		if (geometryType == FacePickerGeometryType.FacePickerGeometryTypeTriangle) {
			this._facePickerGeometry = TriangleFacePickerGeometry.create();

		} else if (geometryType == FacePickerGeometryType.FacePickerGeometryTypeQuad) {
			this._facePickerGeometry = QuadFacePickerGeometry.create();
		}

		// Create a renderer overrider
		this._rendererOverrider = RendererOverrider.createWithGeometry(this._facePickerGeometry);
		this._rendererOverrider.geometryBlend = GeometryBlendType.GeometryBlendTypeMix;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function findPicked(scene:Scene, camera:Camera, location:Vector2):Void {
		// Set up render texture

		// Render scene with overrider
		Director.current.renderer.render(scene, camera, this._rendererOverrider);

		// Determine picked object and face

		// Return picking result
	}

}
