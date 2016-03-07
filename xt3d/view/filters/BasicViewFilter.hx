package xt3d.view.filters;

import xt3d.textures.TextureOptions;
import lime.graphics.opengl.GL;
import xt3d.gl.XTGL;
import xt3d.utils.color.Color;
import xt3d.textures.RenderTexture;
import xt3d.utils.geometry.Size;

class BasicViewFilter extends ViewFilter {

	// properties

	// members
	private var _renderTexture:RenderTexture;
	private var _scale:Float = 1.0;

	public function initBasicViewFilter(filteredView:View, scale:Float = 1.0):Bool {
		var ok;
		if ((ok = super.initViewFilter(filteredView))) {
			this._scale = scale;
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override private function updateRenderTargets():Void {
		// TODO : check for clear color changes
		// Create render texture if necessary
		var desiredWidth = Math.ceil(this._scale * this._viewportInPixels.width);
		var desiredHeight = Math.ceil(this._scale * this._viewportInPixels.height);
		if (this._renderTexture == null || this._renderTexture.contentSize.width != desiredWidth || this._renderTexture.contentSize.height != desiredHeight) {
			if (this._renderTexture != null) {
				this._renderTexture.dispose();
				this._renderTexture = null;
			}

			// Create render texture, calculate if we need depth or stencil buffers
			var depthStencilFormat = XTGL.DepthStencilFormatNone;
			var filteredViewClearFlags = this._filteredView.clearFlags;
			if ((filteredViewClearFlags & GL.DEPTH_BUFFER_BIT) != 0 && (filteredViewClearFlags & GL.STENCIL_BUFFER_BIT) != 0) {
				depthStencilFormat = XTGL.DepthStencilFormatDepthAndStencil;

			} else if (filteredViewClearFlags & GL.DEPTH_BUFFER_BIT != 0) {
				depthStencilFormat = XTGL.DepthStencilFormatDepth;

			} else if (filteredViewClearFlags & GL.STENCIL_BUFFER_BIT != 0) {
				depthStencilFormat = XTGL.DepthStencilFormatStencil;
			}

			// If scaling then use linear interp with texture
			var textureOptions = (this._scale != 1.0) ? TextureOptions.LINEAR_REPEAT_POT : null;
			this._renderTexture = RenderTexture.create(Size.createIntSize(Std.int(desiredWidth), Std.int(desiredHeight)), textureOptions, depthStencilFormat);

			// TODO set stencilEnabled here ?
		}
	}

	override private function renderToRenderTargets():Void {
		// clear render texture
		if (this._filteredView.isOpaque) {
			// Opaque fill
			this._renderTexture.beginWithClear(this._filteredView.backgroundColor);

		} else {
			// Transparent fill
			this._renderTexture.beginWithClear();
		}

		// Render filtered view to render texture
		this._renderTexture.render(this._filteredView);

		// End render to texture
		this._renderTexture.end();
	}
}
