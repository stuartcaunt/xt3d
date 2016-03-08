package xt3d.view.filters;

import xt3d.utils.XT;
import xt3d.textures.TextureOptions;
import xt3d.gl.XTGL;
import xt3d.material.DepthMaterial;
import xt3d.material.DepthOfFieldMaterial;
import xt3d.core.RendererOverrider;
import xt3d.utils.geometry.Size;
import xt3d.textures.RenderTexture;
import xt3d.material.Material;

class DepthOfFieldFilter extends BasicViewFilter {

	// properties

	// members
	private static var DEPTH_TEXTURE_NAME:String = "DoF_depthTexture";

	// Material with depth of field shader
	private var _depthOfFieldMaterial:DepthOfFieldMaterial;

	// Material with depth shader
	private var _depthMaterial:Material;

	// Depth renderer overrider
	private var _depthRendererOverrider:RendererOverrider;

	private var _isHorizontal:Bool;


	public static function create(filteredView:View, scale:Float = 1.0):DepthOfFieldFilter {
		var horizontalDoF = DepthOfFieldFilter.createHorizontal(filteredView, scale);
		if (horizontalDoF != null) {
			return DepthOfFieldFilter.createVertical(horizontalDoF, scale);
		}

		return null;
	}

	public static function createHorizontal(filteredView:View, scale:Float = 1.0):DepthOfFieldFilter {
		var object = new DepthOfFieldFilter();

		if (object != null && !(object.init(filteredView, scale, true))) {
			object = null;
		}

		return object;
	}

	public static function createVertical(filteredView:View, scale:Float = 1.0):DepthOfFieldFilter {
		var object = new DepthOfFieldFilter();

		if (object != null && !(object.init(filteredView, scale, false))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, scale:Float = 1.0, isHorizontal:Bool):Bool {
		this._isHorizontal = isHorizontal;
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView, scale))) {

			// Create depth render material
			var depthMaterial = DepthMaterial.create();

			// Create renderer overrider with depth material
			this._depthRendererOverrider = RendererOverrider.createWithMaterial(depthMaterial);
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override public function onEnter():Void {
		super.onEnter();

		this.registerSharedRenderTarget(DEPTH_TEXTURE_NAME, this.renderDepthTexture);
	}

	override public function onExit():Void {
		super.onExit();

		this.unregisterSharedRenderTarget(DEPTH_TEXTURE_NAME);
	}


	override private function updateRenderTargets():Void {
		// Create standard render texture
		super.updateRenderTargets();

		var desiredWidth = Math.ceil(this._scale * this._viewportInPixels.width);
		var desiredHeight = Math.ceil(this._scale * this._viewportInPixels.height);
		var textureOptions = (this._scale != 1.0) ? TextureOptions.LINEAR_REPEAT_POT : null;

		// Update shared depth texture
		this.updateSharedRenderTarget(DEPTH_TEXTURE_NAME, Size.createIntSize(Std.int(desiredWidth), Std.int(desiredHeight)), textureOptions, XTGL.DepthStencilFormatDepth);
	}

	private function renderDepthTexture(depthTexture:RenderTexture):Void {
		// Render to render texture
		depthTexture.renderWithClear(this._filteredView, this._depthRendererOverrider);
	}

	override private function createRenderNodeMaterial():Material {
		// Create the depth of field material
		this._depthOfFieldMaterial = DepthOfFieldMaterial.create(this._isHorizontal);
		return this._depthOfFieldMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Set the texture in the material
		this._depthOfFieldMaterial.setRenderedTexture(this._renderTexture);

		// Set shared depth texture
		var depthTexture = this.getSharedRenderTexture(DEPTH_TEXTURE_NAME);
		this._depthOfFieldMaterial.setDepthTexture(depthTexture);

		this._depthOfFieldMaterial.setFocalDepth(0.6);
	}
}



