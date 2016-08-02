package xt3d.events.picking;

import xt3d.gl.XTGL;
import xt3d.node.Camera;
import xt3d.node.Scene;
import xt3d.events.picking.FacePicker.FacePickingResult;
import lime.utils.UInt8Array;
import xt3d.core.Director;
import lime.math.Vector2;
import lime.graphics.opengl.GL;
import xt3d.view.View;
import xt3d.material.Material;
import xt3d.core.RendererOverrider;
import xt3d.textures.RenderTexture;
import xt3d.utils.color.Color;
import xt3d.node.RenderObject;

typedef ObjectPickingResult = {
	var renderObject:RenderObject;
};


class ObjectPicker implements RendererOverriderMaterialDelegate {

	// properties

	// members
	private var _objectPickerMaterial:Material = null;
	private var _rendererOverrider:RendererOverrider = null;
	private var _renderTexture:RenderTexture;
	private var _clearColor:Color = Color.createWithRGBAHex(0xffffffff);

	public static function create():ObjectPicker {
		var object = new ObjectPicker();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		// Create the material we want to use for the object picking
		this._objectPickerMaterial = Material.createMaterial("picking");
		this._objectPickerMaterial.blending = XTGL.NoBlending;

		// Create a renderer overrider
		this._rendererOverrider = RendererOverrider.create(this);

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


	public function findPickedObject(view:View, location:Vector2):ObjectPickingResult {
		return this.findPickedObjects(view, [location])[0];
	}

	public function findPickedObjects(view:View, locations:Array<Vector2>):Array<ObjectPickingResult> {
		// Set up render texture
		var displaySize = Director.current.displaySize;
		if (this._renderTexture == null || this._renderTexture.contentSize.width != displaySize.width || this._renderTexture.contentSize.height != displaySize.height) {
			this._renderTexture = RenderTexture.create(displaySize);
		}

		// Clear the render texture
		this._renderTexture.beginWithClear(this._clearColor);

		// Render view (using overrider) to render texture
		this._renderTexture.render(view, this._rendererOverrider);

		// Get picking results at all the locations
		var results:Array<ObjectPickingResult> = new Array<ObjectPickingResult>();
		for (location in locations) {
			results.push(this.getPickingResultAtLocation(location, view.scene));
		}

		this._renderTexture.end();

		return results;
	}


	/* --------- Delegate functions --------- */

	public function getMaterialOverride(renderObject:RenderObject, originalMaterial:Material):Material {
		// Set render object id in material uniforms
		var renderIdHigh = Std.int(renderObject.renderId / 256);
		var renderIdLow = renderObject.renderId % 256;
		this._objectPickerMaterial.uniform("objectId").floatArrayValue = [renderIdHigh / 256, renderIdLow / 256];

		// Set picking material sided-ness to match original material
		this._objectPickerMaterial.side = originalMaterial.side;

		return this._objectPickerMaterial;
	}


	/* --------- Private functions --------- */

	private function getPickingResultAtLocation(location:Vector2, scene:Scene):ObjectPickingResult {
		// Get pixel color
		var pixels = new UInt8Array(4);
		GL.readPixels(Std.int(location.x), Std.int(location.y), 1, 1, GL.RGBA, GL.UNSIGNED_BYTE, pixels);

		// Convert pixel colors to renderedObjectId
		var renderObjectId = pixels[0] * 256 + pixels[1];

		// Return picking result corresponding to object/face ids
		var renderObject = null;
		if (renderObjectId != 0xffff) {
			renderObject = scene.getRenderObjectWithRenderId(renderObjectId);
		}

		return { renderObject: renderObject };
	}

}
