package xt3d.events.picking;

import xt3d.gl.shaders.UniformLib;
import xt3d.node.RenderObject;
import lime.graphics.opengl.GL;
import lime.utils.UInt8Array;
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

typedef FacePickingResult = {
	var renderObject:RenderObject;
	var faceId:Int;
};

enum FacePickerGeometryType {
	FacePickerGeometryTypeTriangle;
	FacePickerGeometryTypeQuad;
	FacePickerGeometryTypeCustom;
}

class FacePicker implements RendererOverriderDelegate {

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
		this._rendererOverrider.delegate = this;
		this._rendererOverrider.geometryBlend = GeometryBlendType.GeometryBlendTypeMix;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function findPicked(scene:Scene, camera:Camera, location:Vector2):FacePickingResult {
		// Set up render texture
		var displaySize = Director.current.displaySize;
		if (this._renderTexture == null || this._renderTexture.contentSize.width != displaySize.width || this._renderTexture.contentSize.height != displaySize.height) {
			this._renderTexture = RenderTexture.create(displaySize);
			XT.Log("Created render texture with size " + displaySize);
		}

		// Render scene with overrider
		Director.current.renderer.setRenderTarget(this._renderTexture);
		Director.current.renderer.clear(Color.createWithRGBAHex(0xffffffff), this._renderTexture.clearFlags);
		Director.current.renderer.render(scene, camera, this._rendererOverrider);

		// TODO use view to do render with render target
		// TODO view.renderToTexture(this._renderTexture, this._rendererOverrider);

		// Get pixel color
		var pixels = new UInt8Array(4);
		GL.readPixels(Std.int(location.x), Std.int(this._renderTexture.contentSize.height - location.y), 1, 1, GL.RGBA, GL.UNSIGNED_BYTE, pixels);

//		XT.Log(pixels[0] + ", " + pixels[1] + ", " + pixels[2] + ", " + pixels[3]);

		// Determine picked object and face
		var renderObjectId = pixels[0] * 256 + pixels[1];
		var faceId = pixels[2] * 256 + pixels[3];

		var renderObject = null;

		// Return picking result
		if (renderObjectId != 0xffff && faceId != 0xffff) {
			renderObject = scene.getRenderObjectWithRenderId(renderObjectId);
		}

		return { renderObject: renderObject, faceId: faceId };
	}


	// Delegate functions

	public function prepareRenderer():Void {
		// Nothing to do
	}

	public function prepareRenderObject(renderObject:RenderObject, material:Material):Void {
		// Set render object id in material uniforms
		var renderIdHigh = Std.int(renderObject.renderId / 256);
		var renderIdLow = renderObject.renderId % 256;
		this._facePickerMaterial.uniform("objectId").floatArrayValue = [renderIdHigh / 256, renderIdLow / 256];

		// Set picking material sided-ness to match original material
		this._facePickerMaterial.side = renderObject.material.side;
	}


}
