package xt3d.view.filters;

import xt3d.textures.TextureOptions;
import xt3d.gl.XTGL;
import xt3d.material.DepthMaterial;
import xt3d.material.DepthOfFieldBokehMaterial;
import xt3d.core.RendererOverrider;
import xt3d.utils.color.Color;
import xt3d.utils.geometry.Size;
import xt3d.textures.RenderTexture;
import xt3d.material.Material;
import xt3d.gl.shaders.ShaderTypedefs;

class DepthOfFieldBokehFilter extends BasicViewFilter {

	// properties

	// members
	private var _depthTexture:RenderTexture;

	// Material with depth of field shader
	private var _depthOfFieldMaterial:DepthOfFieldBokehMaterial;

	// Material with depth shader
	private var _depthMaterial:Material;

	// Depth renderer overrider
	private var _depthRendererOverrider:RendererOverrider;

	public static function create(filteredView:View, scale:Float = 1.0):DepthOfFieldBokehFilter {
		var object = new DepthOfFieldBokehFilter();

		if (object != null && !(object.init(filteredView, scale))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, scale:Float = 1.0):Bool {
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

	override private function updateRenderTargets():Void {
		// Create standard render texture
		super.updateRenderTargets();

		// Create depth render texture
		var desiredWidth = Math.ceil(this._scale * this._viewportInPixels.width);
		var desiredHeight = Math.ceil(this._scale * this._viewportInPixels.height);
		if (this._depthTexture == null || this._depthTexture.contentSize.width != desiredWidth || this._depthTexture.contentSize.height != desiredHeight) {
			if (this._depthTexture != null) {
				this._depthTexture.dispose();
				this._depthTexture = null;
			}

			// Create render texture with only color render buffer
			var textureOptions = (this._scale != 1.0) ? TextureOptions.NEAREST_REPEAT_POT : null;
			this._depthTexture = RenderTexture.create(Size.createIntSize(Std.int(desiredWidth), Std.int(desiredHeight)), null, XTGL.DepthStencilFormatDepth);
			this._depthTexture.clearColor = Color.createWithRGBAHex(0x00000000);
		}
	}

	override private function renderToRenderTargets():Void {
		// Render to standard render texture
		super.renderToRenderTargets();

		// Render to the depth texture

		// Transparent fill
		this._depthTexture.beginWithClear();

		// Render depth using the overrider
		this._depthTexture.render(this._filteredView, this._depthRendererOverrider);

		// End render to texture
		this._depthTexture.end();
	}

	override private function createRenderNodeMaterial():Material {
		// Create the depth of field material
		this._depthOfFieldMaterial = DepthOfFieldBokehMaterial.create();

		// Create debug depth material
//		var depthDebugMaterial = DepthDebugMaterial.create();
//		this._depthOfFieldMaterial = depthDebugMaterial;

		return this._depthOfFieldMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Set the texture in the material
		this._depthOfFieldMaterial.setRenderedTexture(this._renderTexture);
		this._depthOfFieldMaterial.setDepthTexture(this._depthTexture);
	}
}



