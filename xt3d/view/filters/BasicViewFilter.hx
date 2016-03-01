package xt3d.view.filters;

import xt3d.material.TextureMaterial;
import xt3d.material.Material;
import xt3d.core.Director;
import xt3d.utils.color.Color;
import xt3d.textures.RenderTexture;
import xt3d.utils.geometry.Size;

class BasicViewFilter extends ViewFilter {

	// properties

	// members
	private var _renderTexture:RenderTexture;

	public function initBasicViewFilter(filteredView:View):Bool {
		var ok;
		if ((ok = super.initViewFilter(filteredView))) {
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override private function updateRenderTargets():Void {
		// TODO : check for clear color changes
		// Create render texture if necessary
		if (this._renderTexture == null || this._renderTexture.contentSize.width != this._viewportInPixels.width || this._renderTexture.contentSize.height != this._viewportInPixels.height) {
			if (this._renderTexture != null) {
				this._renderTexture.dispose();
				this._renderTexture = null;
			}

			// Create render texture
			// TODO : texture options + depthStencilFormat using View clearColor
			this._renderTexture = RenderTexture.create(Size.createIntSize(Std.int(this._viewportInPixels.width), Std.int(this._viewportInPixels.height)));
			this._renderTexture.clearColor = Color.createWithRGBAHex(0x00000000);
		}
	}

	override private function renderToRenderTargets():Void {
		// Override in Basic Filter

		var renderer = Director.current.renderer;

		// clear render texture
		if (this._filteredView.isOpaque) {
			// Opaque fill
			this._renderTexture.beginWithClear(this._filteredView.backgroundColor);

		} else {
			// Transparent fill
			this._renderTexture.beginWithClear();
		}

		// Set the viewport to render to the texture
		renderer.setViewport(this._renderTextureViewport);

		// Render filtered view to render texture
		this._renderTexture.render(this._filteredView);

		// End render to texture
		this._renderTexture.end();
	}
}
