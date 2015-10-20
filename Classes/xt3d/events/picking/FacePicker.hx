package xt3d.events.picking;

import xt3d.utils.XT;
import xt3d.utils.geometry.Size;
import xt3d.textures.RenderTexture;
import xt3d.utils.color.Color;
import xt3d.core.Material;
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
	private var _facePickerMaterial:Material = null;
	private var _rendererOverrider:RendererOverrider = null;
	private var _renderTexture:RenderTexture;

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

		// Create the material we want to use for the face picking
		this._facePickerMaterial = Material.create("picking+facePicking");

		// Create a renderer overrider
		this._rendererOverrider = RendererOverrider.createWithMaterialAndGeometry(this._facePickerMaterial, this._facePickerGeometry);
		this._rendererOverrider.geometryBlend = GeometryBlendType.GeometryBlendTypeMix;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function findPicked(scene:Scene, camera:Camera, location:Vector2):Void {
		// Set up render texture
		var displaySize = Director.current.displaySize;
		if (this._renderTexture == null || this._renderTexture.contentSize.width != displaySize.width || this._renderTexture.contentSize.height != displaySize.height) {
			this._renderTexture = RenderTexture.create(displaySize);
			XT.Log("Created render texture with size " + displaySize);
		}

		// Render scene with overrider
		Director.current.renderer.setRenderTarget(this._renderTexture);
		Director.current.renderer.clear(Color.createWithRGBHex(0x000000), this._renderTexture.clearFlags);
		Director.current.renderer.render(scene, camera, this._rendererOverrider);

		// TODO use view to do render with render target
		// TODO view.renderToTexture(this._renderTexture, this._rendererOverrider);

		// Determine picked object and face

		// Return picking result
	}

}
