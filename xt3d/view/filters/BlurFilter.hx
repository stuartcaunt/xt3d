package xt3d.view.filters;

import xt3d.textures.Texture2D;
import xt3d.gl.shaders.ShaderLib;
import xt3d.gl.shaders.ShaderTypedefs;
import xt3d.material.TextureMaterial;
import xt3d.material.Material;

class BlurFilter extends BasicViewFilter {

	// properties

	// members
	private var _blurMaterial:BlurMaterial;
	private var _isHorizontal:Bool;

	public static function create(filteredView:View):BlurFilter {
		var horizontalBlur = BlurFilter.createHorizontal(filteredView);
		if (horizontalBlur != null) {
			return BlurFilter.createVertical(horizontalBlur);
		}

		return null;
	}

	public static function createHorizontal(filteredView:View):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, true))) {
			object = null;
		}

		return object;
	}

	public static function createVertical(filteredView:View):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, false))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, isHorizontal:Bool):Bool {
		this._isHorizontal = isHorizontal;
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView))) {
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override private function createRenderNodeMaterial():Material {
		// Create the blur material
		this._blurMaterial = BlurMaterial.create(this._isHorizontal);

		return this._blurMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Set the texture in the material
		this._blurMaterial.setTexture(this._renderTexture);
	}

}


class BlurMaterial extends Material {

	private static var _shaderLibInitialised:Bool = false;

	private var _isHorizontal:Bool;
	private var _texture:Texture2D;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();

	private static function initialiseShaderLib():Void {
		if (!_shaderLibInitialised) {

			var shaderConfig:Map<String, ShaderInfo> = [
				"blurX" => {
					vertexProgram: "blur_vertex",
					fragmentProgram: "blur_fragment",
					commonUniformGroups: ["matrixCommon"],
					uniforms: [
						"texture" => { name: "u_texture", type: "texture", shader: "f" },
						"uvScaleOffset" => { name: "u_uvScaleOffset", type: "vec4", shader: "v", defaultValue: "[1.0, 1.0, 0.0, 0.0]" }
					],
					vertexDefines: ["#define BLUR_X"]
				},
				"blurY" => {
					vertexProgram: "blur_vertex",
					fragmentProgram: "blur_fragment",
					commonUniformGroups: ["matrixCommon"],
					uniforms: [
						"texture" => { name: "u_texture", type: "texture", shader: "f" },
						"uvScaleOffset" => { name: "u_uvScaleOffset", type: "vec4", shader: "v", defaultValue: "[1.0, 1.0, 0.0, 0.0]" }
					],
					vertexDefines: ["#define BLUR_Y"]
				}
			];

			ShaderLib.instance().addShaderConfigs(shaderConfig);

			_shaderLibInitialised = true;
		}
	}

	public static function create(isHorizontal:Bool):BlurMaterial {
		var object = new BlurMaterial();

		if (object != null && !(object.init(isHorizontal))) {
			object = null;
		}

		return object;
	}

	public function init(isHorizontal:Bool):Bool {
		initialiseShaderLib();

		this._isHorizontal = isHorizontal;

		var materialName;
		if (this._isHorizontal) {
			materialName = "blurX";

		} else {
			materialName = "blurY";
		}

		var isOk;
		if ((isOk = super.initMaterial(materialName))) {
		}

		return isOk;
	}

	public function setTexture(value:Texture2D):Void {
		if (this._texture != null) {
			this._texture.release();
		}

		if (value != null) {
			this._texture = value;
			this._texture.retain();

			this.uniform("texture").texture = this._texture;

			var textureUvScaleOffset = this._texture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

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

}
