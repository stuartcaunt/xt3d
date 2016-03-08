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
	public var focalDepth(get, set):Float;
	public var focalRange(get, set):Float;


	// members
	private static var DEPTH_TEXTURE_NAME:String = "DoF_depthTexture";

	// Material with depth of field shader
	private var _depthOfFieldMaterial:DepthOfFieldMaterial;

	// Material with depth shader
	private var _depthMaterial:Material;

	// Depth renderer overrider
	private var _depthRendererOverrider:RendererOverrider;

	private var _isHorizontal:Bool;
	private var _firstPass:DepthOfFieldFilter;
	private var _focalDepth:Float = 0.5;
	private var _focalRange:Float = 0.2;
	private var _focalsDirty:Bool = true;


	public static function create(filteredView:View, scale:Float = 1.0):DepthOfFieldFilter {
		var horizontalDoF = DepthOfFieldFilter.createHorizontal(filteredView, scale);
		if (horizontalDoF != null) {
			return DepthOfFieldFilter.createVertical(horizontalDoF, scale, horizontalDoF);
		}

		return null;
	}

	public static function createHorizontal(filteredView:View, scale:Float = 1.0, firstPass:DepthOfFieldFilter = null):DepthOfFieldFilter {
		var object = new DepthOfFieldFilter();

		if (object != null && !(object.init(filteredView, scale, true, firstPass))) {
			object = null;
		}

		return object;
	}

	public static function createVertical(filteredView:View, scale:Float = 1.0, firstPass:DepthOfFieldFilter = null):DepthOfFieldFilter {
		var object = new DepthOfFieldFilter();

		if (object != null && !(object.init(filteredView, scale, false, firstPass))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, scale:Float = 1.0, isHorizontal:Bool, firstPass:DepthOfFieldFilter = null):Bool {
		this._isHorizontal = isHorizontal;
		this._firstPass = firstPass;
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


	inline function get_focalDepth():Float {
		return this._focalDepth;
	}

	inline function set_focalDepth(value:Float) {
		if (this._firstPass != null) {
			this._firstPass.focalDepth = value;
		}

		this._focalsDirty = true;

		return this._focalDepth = value;
	}

	inline function get_focalRange():Float {
		return this._focalRange;
	}

	inline function set_focalRange(value:Float) {
		if (this._firstPass != null) {
			this._firstPass.focalRange = value;
		}

		this._focalsDirty = true;

		return this._focalRange = value;
	}


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
		this._depthOfFieldMaterial.renderedTexture = this._renderTexture;

		// Set shared depth texture
		var depthTexture = this.getSharedRenderTexture(DEPTH_TEXTURE_NAME);
		this._depthOfFieldMaterial.depthTexture = depthTexture;

		if (this._focalsDirty) {
			this._depthOfFieldMaterial.focalDepth = this._focalDepth;
			this._depthOfFieldMaterial.focalRange = this._focalRange;

			this._focalsDirty = false;
		}
	}
}



