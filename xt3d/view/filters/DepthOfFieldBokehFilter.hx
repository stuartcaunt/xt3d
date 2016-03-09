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
	public var focalDepth(get, set):Float;
	public var focalRange(get, set):Float;
	public var highlightThreshold(get, set):Float;
	public var highlightGain(get, set):Float;
	public var chromaticFringe(get, set):Float;
	public var edgeBias(get, set):Float;
	public var dither(get, set):Float;

	// members
	private var _depthTexture:RenderTexture;

	// Material with depth of field shader
	private var _depthOfFieldMaterial:DepthOfFieldBokehMaterial;

	// Material with depth shader
	private var _depthMaterial:Material;

	// Depth renderer overrider
	private var _depthRendererOverrider:RendererOverrider;

	private var _uniformsDirty:Bool = false;
	private var _focalDepth:Float = 0.5;
	private var _focalRange:Float = 0.2;
	private var _highlightThreshold:Float = 0.5; // highlight threshold;
	private var _highlightGain:Float = 5.0; // highlight gain;
	private var _chromaticFringe:Float = 0.5; // bokeh chromatic aberration/fringing
	private var _edgeBias:Float = 0.4; // bokeh edge bias
	private var _dither:Float = 0.0001; // dither amount

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


	inline function get_focalDepth():Float {
		return this._focalDepth;
	}

	inline function set_focalDepth(value:Float) {
		this._uniformsDirty = true;
		return this._focalDepth = value;
	}

	inline function get_focalRange():Float {
		return this._focalRange;
	}

	inline function set_focalRange(value:Float) {
		this._uniformsDirty = true;
		return this._focalRange = value;
	}

	inline function get_highlightThreshold():Float {
		return this._highlightThreshold;
	}

	inline function set_highlightThreshold(value:Float) {
		this._uniformsDirty = true;
		return this._highlightThreshold = value;
	}

	inline function get_highlightGain():Float {
		return this._highlightGain;
	}

	inline function set_highlightGain(value:Float) {
		this._uniformsDirty = true;
		return this._highlightGain = value;
	}

	inline function get_chromaticFringe():Float {
		return this._chromaticFringe;
	}

	inline function set_chromaticFringe(value:Float) {
		this._uniformsDirty = true;
		return this._chromaticFringe = value;
	}

	inline function get_edgeBias():Float {
		return this._edgeBias;
	}

	inline function set_edgeBias(value:Float) {
		this._uniformsDirty = true;
		return this._edgeBias = value;
	}

	inline function get_dither():Float {
		return this._dither;
	}

	inline function set_dither(value:Float) {
		this._uniformsDirty = true;
		return this._dither = value;
	}


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
			var textureOptions = (this._scale != 1.0) ? TextureOptions.LINEAR_REPEAT_POT : null;
			this._depthTexture = RenderTexture.create(Size.createIntSize(Std.int(desiredWidth), Std.int(desiredHeight)), textureOptions, XTGL.DepthStencilFormatDepth);
		}
	}

	override private function renderToRenderTargets():Void {
		// Render to standard render texture
		super.renderToRenderTargets();

		// Render to the depth texture

		// Render depth using the overrider
		this._depthTexture.renderWithClear(this._filteredView, this._depthRendererOverrider);
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
		this._depthOfFieldMaterial.renderedTexture = this._renderTexture;
		this._depthOfFieldMaterial.depthTexture = this._depthTexture;

		if (this._uniformsDirty) {
			this._depthOfFieldMaterial.focalDepth = this._focalDepth;
			this._depthOfFieldMaterial.focalRange = this._focalRange;
			this._depthOfFieldMaterial.highlightThreshold = this._highlightThreshold;
			this._depthOfFieldMaterial.highlightGain = this._highlightGain;
			this._depthOfFieldMaterial.chromaticFringe = this._chromaticFringe;
			this._depthOfFieldMaterial.edgeBias = this._edgeBias;
			this._depthOfFieldMaterial.dither = this._dither;

			this._uniformsDirty = false;
		}
	}
}



