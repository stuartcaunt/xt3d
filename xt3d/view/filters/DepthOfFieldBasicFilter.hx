package xt3d.view.filters;

import xt3d.material.DepthMaterial;
import xt3d.core.RendererOverrider;
import xt3d.gl.XTGL;
import xt3d.utils.geometry.Size;
import xt3d.textures.TextureOptions;
import xt3d.textures.RenderTexture;
import xt3d.gl.shaders.ShaderLib;
import xt3d.textures.Texture2D;
import xt3d.material.Material;
import xt3d.gl.shaders.ShaderTypedefs;

class DepthOfFieldBasicFilter extends BasicViewFilter {

	// properties

	// members
	private var _dofMaterial:DepthOfFieldBasicMaterial;
	private var _isHorizontal:Bool;
	private var _blurFilter:BlurFilter;
	private var _blurredTexture:RenderTexture;
	private var _depthTexture:RenderTexture;
	private var _depthRendererOverrider:RendererOverrider;

	public static function create(filteredView:View, scale:Float = 1.0):DepthOfFieldBasicFilter {
		var object = new DepthOfFieldBasicFilter();

		if (object != null && !(object.init(filteredView, scale))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, scale:Float = 1.0):Bool {
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView, scale))) {
			this._blurFilter = BlurFilter.create(filteredView, scale * 0.5);

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
		// Create main render target
		super.updateRenderTargets();

		// If scaling then use linear interp with texture
		var textureOptions = (this._scale != 1.0) ? TextureOptions.LINEAR_REPEAT_POT : null;

		// Create render target for blur filter
		var desiredWidth = Math.ceil(this._scale * this._viewportInPixels.width);
		var desiredHeight = Math.ceil(this._scale * this._viewportInPixels.height);
		if (this._blurredTexture == null || this._blurredTexture.contentSize.width != desiredWidth || this._blurredTexture.contentSize.height != desiredHeight) {
			if (this._blurredTexture != null) {
				this._blurredTexture.dispose();
				this._blurredTexture = null;
			}

			// Create render target for blur filter
			this._blurredTexture = RenderTexture.create(Size.createIntSize(Std.int(desiredWidth), Std.int(desiredHeight)), textureOptions, XTGL.DepthStencilFormatNone);
		}

		// Create render target for the depth
		if (this._depthTexture == null || this._depthTexture.contentSize.width != desiredWidth || this._depthTexture.contentSize.height != desiredHeight) {
			if (this._depthTexture != null) {
				this._depthTexture.dispose();
				this._depthTexture = null;
			}

			// Create render texture with only color render buffer
			this._depthTexture = RenderTexture.create(Size.createIntSize(Std.int(desiredWidth), Std.int(desiredHeight)), null, XTGL.DepthStencilFormatDepth);
		}
	}

	override private function renderToRenderTargets():Void {
		// Render to principal render texture
		super.renderToRenderTargets();

		// Update blur filter
		this._blurFilter.updateView();

		// Render to blur render target


		// clear render texture
		this._blurredTexture.beginWithClear();

		// Render filtered view to render texture
		this._blurredTexture.render(this._blurFilter);

		// End render to texture
		this._blurredTexture.end();

		// Render to the depth texture

		// Transparent fill
		this._depthTexture.beginWithClear();

		// Render depth using the overrider
		this._depthTexture.render(this._filteredView, this._depthRendererOverrider);

		// End render to texture
		this._depthTexture.end();
	}

	override private function createRenderNodeMaterial():Material {
		// Create the blur material
		this._dofMaterial = DepthOfFieldBasicMaterial.create(this._isHorizontal);

		return this._dofMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Set the texture in the material
		this._dofMaterial.setFocusedTexture(this._renderTexture);
		this._dofMaterial.setBlurredTexture(this._blurredTexture);
		this._dofMaterial.setDepthTexture(this._depthTexture);
		this._dofMaterial.setFocalDepth(0.5);
	}

}


class DepthOfFieldBasicMaterial extends Material {

	private static var _shaderLibInitialised:Bool = false;

	private var _focusedTexture:Texture2D;
	private var _blurredTexture:Texture2D;
	private var _depthTexture:Texture2D;
	private var _focalDepth:Float = 10;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();

	private static function initialiseShaderLib():Void {
		if (!_shaderLibInitialised) {

			var shaderConfig:Map<String, ShaderInfo> = [
				"depthOfFieldBasic" => {
					vertexProgram: "depthOfFieldBasic_vertex",
					fragmentProgram: "depthOfFieldBasic_fragment",
					commonUniformGroups: ["matrixCommon", "texture"],
					uniforms: [
						"blurredTexture" => { name: "u_blurredTexture", type: "texture", shader: "f" },
						"depthTexture" => { name: "u_depthTexture", type: "texture", shader: "f" },
						"focalDepth" => { name: "u_focalDepth", type: "float", shader: "f", defaultValue: "0.5" }
					]
				}
			];

			ShaderLib.instance().addShaderConfigs(shaderConfig);

			_shaderLibInitialised = true;
		}
	}

	public static function create(isHorizontal:Bool):DepthOfFieldBasicMaterial {
		var object = new DepthOfFieldBasicMaterial();

		if (object != null && !(object.init(isHorizontal))) {
			object = null;
		}

		return object;
	}

	public function init(isHorizontal:Bool):Bool {
		initialiseShaderLib();
		var isOk;
		if ((isOk = super.initMaterial("depthOfFieldBasic"))) {
		}

		return isOk;
	}

	public function setFocusedTexture(value:Texture2D):Void {
		if (this._focusedTexture != null) {
			this._focusedTexture.release();
			this._focusedTexture = null;
		}

		if (value != null) {
			this._focusedTexture = value;
			this._focusedTexture.retain();

			this.uniform("texture").texture = this._focusedTexture;

			var textureUvScaleOffset = this._focusedTexture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

		} else {
			this.uniform("texture").texture = null;
		}
	}

	public function setBlurredTexture(value:Texture2D):Void {
		if (this._blurredTexture != null) {
			this._blurredTexture.release();
			this._blurredTexture = null;
		}

		if (value != null) {
			this._blurredTexture = value;
			this._blurredTexture.retain();
		}

		this.uniform("blurredTexture").texture = this._blurredTexture;
	}

	public function setDepthTexture(value:Texture2D):Void {
		if (this._depthTexture != null) {
			this._depthTexture.release();
			this._depthTexture = null;
		}

		if (value != null) {
			this._depthTexture = value;
			this._depthTexture.retain();
		}

		this.uniform("depthTexture").texture = this._depthTexture;
	}

	public function setUvScaleOffset(uvScaleX:Float, uvScaleY:Float, uvOffsetX:Float, uvOffsetY:Float):Void {
		this._uvScaleOffset[0] = uvScaleX;
		this._uvScaleOffset[1] = uvScaleY;
		this._uvScaleOffset[2] = uvOffsetX;
		this._uvScaleOffset[3] = uvOffsetY;

		this.uniform("uvScaleOffset").floatArrayValue = this._uvScaleOffset;
	}

	public function setFocalDepth(focalDepth:Float):Void {
		this._focalDepth = focalDepth;

		this.uniform("focalDepth").floatValue = this._focalDepth;
	}

}
