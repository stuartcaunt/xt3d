package xt3d.view.filters;

import xt3d.utils.XT;
import xt3d.utils.geometry.Size;
import xt3d.textures.TextureOptions;
import xt3d.gl.XTGL;
import xt3d.textures.RenderTexture;

typedef SharedRenderTarget = {
	name: String,
	texture: RenderTexture,
	referenceCount: Int,
	renderFunc: RenderTexture -> Void,
}


class RenderTargetStore {

	// properties

	// members
	private var _sharedRenderTargets:Map<String, SharedRenderTarget> = new Map<String, SharedRenderTarget>();

	public static function create():RenderTargetStore {
		var object = new RenderTargetStore();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	/**
	 * register a render target: create one if needed
	 **/
	public function registerRenderTarget(targetName:String, targetRenderer:RenderTexture -> Void):Void {
		var sharedRenderTarget:SharedRenderTarget = null;
		if (!this._sharedRenderTargets.exists(targetName)) {
			// Create target
			sharedRenderTarget = {name: targetName, texture: null, referenceCount: 1, renderFunc: targetRenderer};
			this._sharedRenderTargets.set(targetName, sharedRenderTarget);

		} else {
			// Increate reference count
			sharedRenderTarget = this._sharedRenderTargets.get(targetName);
			sharedRenderTarget.referenceCount++;
		}
	}

	/**
	 * unregister a render target: delete it if it is not needed
	 **/
	public function unregisterRenderTarget(targetName:String):Void {
		if (this._sharedRenderTargets.exists(targetName)) {
			var sharedRenderTarget:SharedRenderTarget = this._sharedRenderTargets.get(targetName);
			// Reduce reference count
			sharedRenderTarget.referenceCount--;

			// Dispose of texture if no longer referenced
			if (sharedRenderTarget.referenceCount <= 0) {
				if (sharedRenderTarget.texture != null) {
					sharedRenderTarget.texture.dispose();
				}

				this._sharedRenderTargets.remove(targetName);
			}
		}

	}

	/**
	 * Get the shared render texture
	 **/
	public function getRenderTexture(targetName:String):RenderTexture {
		return this._sharedRenderTargets.get(targetName).texture;
	}

	/**
	 * update the size of the render texture if needed
	 **/
	public function updateRenderTarget(targetName:String, size:Size<Int>, textureOptions:TextureOptions = null, depthStencilFormat:Int = XTGL.DepthStencilFormatDepth):Void {
		if (this._sharedRenderTargets.exists(targetName)) {
			var sharedRenderTarget:SharedRenderTarget = this._sharedRenderTargets.get(targetName);
			var renderTexture = sharedRenderTarget.texture;

			if (renderTexture == null || renderTexture.contentSize.width != size.width || renderTexture.contentSize.height != size.height) {
				if (renderTexture != null) {
					renderTexture.dispose();
					sharedRenderTarget.texture = null;
				}

				sharedRenderTarget.texture = RenderTexture.create(size, textureOptions, depthStencilFormat);
			}
		}
	}

	/**
	 * call the render funcs of all render targets
	 */
	public function renderToRenderTargets():Void {
		var targetNames = this._sharedRenderTargets.keys();
		while (targetNames.hasNext()) {
			var targetName = targetNames.next();
			var sharedRenderTarget:SharedRenderTarget = this._sharedRenderTargets.get(targetName);

			// Get the texture
			var renderTexture = sharedRenderTarget.texture;

			// Call the render func if texture is not null
			if (renderTexture != null) {
				var renderFunc = sharedRenderTarget.renderFunc;

				// Render
				renderFunc(renderTexture);
			}
		}
	}

	/**
	 * Dispose of all render targets/textures
	 */
	public function dispose():Void {
		var targetNames = this._sharedRenderTargets.keys();
		while (targetNames.hasNext()) {
			var targetName = targetNames.next();
			var sharedRenderTarget:SharedRenderTarget = this._sharedRenderTargets.get(targetName);

			// destroy texture
			if (sharedRenderTarget.texture != null) {
				sharedRenderTarget.texture.dispose();
			}

			this._sharedRenderTargets.remove(targetName);
		}
	}

}
