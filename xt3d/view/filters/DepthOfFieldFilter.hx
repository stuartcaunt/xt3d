package xt3d.view.filters;

import xt3d.gl.XTGL;
import xt3d.material.DepthMaterial;
import xt3d.material.DepthDebugMaterial;
import xt3d.core.RendererOverrider;
import xt3d.utils.color.Color;
import xt3d.utils.geometry.Size;
import xt3d.textures.RenderTexture;
import xt3d.material.Material;

class DepthOfFieldFilter extends BasicViewFilter {

	// properties

	// members
	private var _depthTexture:RenderTexture;

	// Material with depth of field shader
	private var _depthOfFieldMaterial:DepthDebugMaterial;

	// Material with depth shader
	private var _depthMaterial:Material;

	// Depth renderer overrider
	private var _depthRendererOverrider:RendererOverrider;

	public static function create(filteredView:View):DepthOfFieldFilter {
		var object = new DepthOfFieldFilter();

		if (object != null && !(object.init(filteredView))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View):Bool {
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView))) {

			// Create depth render material
			var depthMaterial = DepthMaterial.create();

			// Create renderer overrider with depth material
			this._depthRendererOverrider = RendererOverrider.createWithMaterial(depthMaterial);
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override private function updateRenderTargets():Void {
		// Create standard render texture
		super.updateRenderTargets();

		// Create depth render texture
		if (this._depthTexture == null || this._depthTexture.contentSize.width != this._viewportInPixels.width || this._depthTexture.contentSize.height != this._viewportInPixels.height) {
			if (this._depthTexture != null) {
				this._depthTexture.dispose();
				this._depthTexture = null;
			}

			// Create render texture with only color render buffer
			this._depthTexture = RenderTexture.create(Size.createIntSize(Std.int(this._viewportInPixels.width), Std.int(this._viewportInPixels.height)), null, XTGL.DepthStencilFormatNone);
			this._depthTexture.clearColor = Color.createWithRGBAHex(0x00000000);
		}
	}

	override private function renderToRenderTargets():Void {
		// Render to standard render texture
		super.renderToRenderTargets();

		// Transparent fill
		this._renderTexture.beginWithClear();

		// Render filtered view to render texture
		this._renderTexture.render(this._filteredView, this._depthRendererOverrider);

		// End render to texture
		this._renderTexture.end();
	}

	override private function createRenderNodeMaterial():Material {
		// Create the depth of field material

		//return this._depthOfFieldMaterial;

		// Create debug depth material
		var depthDebugMaterial = DepthDebugMaterial.create();

		this._depthOfFieldMaterial = depthDebugMaterial;

		return this._depthOfFieldMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Set the texture in the material
		this._depthOfFieldMaterial.setTexture(this._renderTexture);
		//this._depthOfFieldMaterial.setDepthTexture(this._depthTexture);
	}



}


