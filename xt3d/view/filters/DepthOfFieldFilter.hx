package xt3d.view.filters;

import xt3d.gl.shaders.ShaderLib;
import xt3d.textures.Texture2D;
import xt3d.gl.XTGL;
import xt3d.material.DepthMaterial;
import xt3d.material.DepthDebugMaterial;
import xt3d.core.RendererOverrider;
import xt3d.utils.color.Color;
import xt3d.utils.geometry.Size;
import xt3d.textures.RenderTexture;
import xt3d.material.Material;
import xt3d.gl.shaders.ShaderTypedefs;

class DepthOfFieldFilter extends BasicViewFilter {

	// properties

	// members
	private var _depthTexture:RenderTexture;

	// Material with depth of field shader
	private var _depthOfFieldMaterial:DepthOfFieldMaterial;

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
			this._depthTexture = RenderTexture.create(Size.createIntSize(Std.int(this._viewportInPixels.width), Std.int(this._viewportInPixels.height)), null, XTGL.DepthStencilFormatDepth);
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
		this._depthOfFieldMaterial = DepthOfFieldMaterial.create();

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



class DepthOfFieldMaterial extends Material {

	private static var _shaderLibInitialised:Bool = false;

	private var _renderedTexture:Texture2D;
	private var _depthTexture:Texture2D;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();
	private var _focalDepth:Float;

	private static function initialiseShaderLib():Void {
		if (!_shaderLibInitialised) {

			var blurFactor = 15;

			var shaderConfig:Map<String, ShaderInfo> = [
				"depthOfField" => {
					vertexProgram: "depthOfField_vertex",
					fragmentProgram: "depthOfField_fragment",
					commonUniformGroups: ["matrixCommon", "texture"],
					uniforms: [
						"depthTexture" => { name: "u_depthTexture", type: "texture", shader: "f" },
						"focalDepth" => { name: "u_focalDepth", type: "float", shader: "f", defaultValue: "0.5" },
						"textureWidth" => { name: "u_textureWidth", type: "float", shader: "f", defaultValue: "1" },
						"textureHeight" => { name: "u_textureHeight", type: "float", shader: "f", defaultValue: "1" }
					]
				}
			];

			ShaderLib.instance().addShaderConfigs(shaderConfig);

			_shaderLibInitialised = true;
		}
	}

	public static function create():DepthOfFieldMaterial {
		var object = new DepthOfFieldMaterial();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		initialiseShaderLib();

		var isOk;
		if ((isOk = super.initMaterial("depthOfField"))) {
		}

		return isOk;
	}

	public function setRenderedTexture(value:Texture2D):Void {
		if (this._renderedTexture != null) {
			this._renderedTexture.release();
		}

		if (value != null) {
			this._renderedTexture = value;
			this._renderedTexture.retain();

			this.uniform("texture").texture = this._renderedTexture;

			var textureUvScaleOffset = this._renderedTexture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

			this.uniform("textureWidth").floatValue = this._renderedTexture.pixelsWidth;
			this.uniform("textureHeight").floatValue = this._renderedTexture.pixelsHeight;

		} else {
			this.uniform("texture").texture = null;
		}
	}

	public function setDepthTexture(value:Texture2D):Void {
		if (this._depthTexture != null) {
			this._depthTexture.release();
		}

		if (value != null) {
			this._depthTexture = value;
			this._depthTexture.retain();

			this.uniform("depthTexture").texture = this._depthTexture;

		} else {
			this.uniform("texture").texture = null;
		}
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

