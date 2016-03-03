package xt3d.gl.shaders;

import xt3d.utils.XT;
import xt3d.gl.shaders.ShaderTypedefs;
import xt3d.gl.shaders.ShaderUtils;

class ShaderLib  {

	public static var EXTENSION_SEPARATOR:String = "+";

	// Properties

	// Members
	private static var _instance:ShaderLib = null;
	private var _shaderConfigs:Map<String, ShaderInfo> = new Map<String, ShaderInfo>();
	private var _baseShaderConfigs:Map<String, ShaderInfo>;
	private var _shaderExtensions:Map<String, ShaderExtensionInfo>;


	private function new() {
	}


	/* ----------- Properties ----------- */


	public inline function get_shaderConfigs():Map<String, ShaderInfo> {
		return _shaderConfigs;
	}


	/* --------- Implementation --------- */


	public static function instance():ShaderLib {
		if (_instance == null) {
			_instance = new ShaderLib();
			_instance.init();
		}

		return _instance;
	}

	public function init():Void {
		this._baseShaderConfigs = [
			"generic" => {
				vertexProgram: "generic_vertex",
				fragmentProgram: "generic_fragment",
				commonUniformGroups: ["matrixCommon", "time", "opacity"],
				uniforms: [
					"color" => { name: "u_color", type: "vec4", shader: "vf", defaultValue: "[1, 1, 1, 1]" }
				]
			},
			"picking" => {
				vertexProgram: "picking_vertex",
				fragmentProgram: "picking_fragment",
				commonUniformGroups: ["matrixCommon"],
				uniforms: [
					"objectId" => { name: "u_objectId", type: "vec2", shader: "f", defaultValue: "[0.0, 0.0]" }
				]
			},
			"depth" => {
				vertexProgram: "depth_vertex",
				fragmentProgram: "depth_fragment",
				commonUniformGroups: ["matrixCommon", "depth"]
			},
			"depth_debug" => {
				vertexProgram: "depth_debug_vertex",
				fragmentProgram: "depth_debug_fragment",
				commonUniformGroups: ["matrixCommon", "texture"]
			},
			"blurX9" => {
				vertexProgram: "blur9_vertex",
				fragmentProgram: "blur9_fragment",
				commonUniformGroups: ["matrixCommon", "texture"],
				vertexDefines: ["#define BLUR_X"],
				uniforms: [
					"textureWidth" => { name: "u_textureWidth", type: "float", shader: "v", defaultValue: "1" }
				]
			},
			"blurY9" => {
				vertexProgram: "blur9_vertex",
				fragmentProgram: "blur9_fragment",
				commonUniformGroups: ["matrixCommon", "texture"],
				vertexDefines: ["#define BLUR_Y"],
				uniforms: [
					"textureHeight" => { name: "u_textureHeight", type: "float", shader: "v", defaultValue: "1" }
				]
			},
			"blurX15" => {
				vertexProgram: "blur15_vertex",
				fragmentProgram: "blur15_fragment",
				commonUniformGroups: ["matrixCommon", "texture"],
				vertexDefines: ["#define BLUR_X"],
				uniforms: [
					"textureWidth" => { name: "u_textureWidth", type: "float", shader: "v", defaultValue: "1" }
				]
			},
			"blurY15" => {
				vertexProgram: "blur15_vertex",
				fragmentProgram: "blur15_fragment",
				commonUniformGroups: ["matrixCommon", "texture"],
				vertexDefines: ["#define BLUR_Y"],
				uniforms: [
					"textureHeight" => { name: "u_textureHeight", type: "float", shader: "v", defaultValue: "1" }
				]
			},
			"depthOfFieldBokeh" => {
				vertexProgram: "depthOfFieldBokeh_vertex",
				fragmentProgram: "depthOfFieldBokeh_fragment",
				commonUniformGroups: ["matrixCommon", "texture"],
				uniforms: [
					"depthTexture" => { name: "u_depthTexture", type: "texture", shader: "f" },
					"focalDepth" => { name: "u_focalDepth", type: "float", shader: "f", defaultValue: "0.5" },
					"textureWidth" => { name: "u_textureWidth", type: "float", shader: "f", defaultValue: "1" },
					"textureHeight" => { name: "u_textureHeight", type: "float", shader: "f", defaultValue: "1" }
				]
			}
		];

		this._shaderExtensions = [
			"vertexColors" => {
				vertexDefines: ["#define USE_VERTEX_COLOR"]
			},

			"texture" => {
				vertexDefines: ["#define USE_TEXTURE"],
				fragmentDefines: ["#define USE_TEXTURE"],
				commonUniformGroups: ["texture"]
			},

			"gouraud" => {
				vertexDefines: ["#define GOURAUD_LIGHTING"],
				fragmentDefines: ["#define GOURAUD_LIGHTING"],
				vertexIncludes: ["gouraud_vertex_part"],
				commonUniformGroups: ["lighting"]
			},

			"phong" => {
				vertexDefines: ["#define PHONG_LIGHTING"],
				fragmentDefines: ["#define PHONG_LIGHTING"],
				fragmentIncludes: ["phong_fragment_part"],
				commonUniformGroups: ["lighting"]
			},

			"material" => {
				vertexDefines: ["#define USE_MATERIAL_COLOR"],
				fragmentDefines: ["#define USE_MATERIAL_COLOR"],
				commonUniformGroups: ["material"]
			},

			"facePicking" => {
				vertexDefines: ["#define FACE_PICKING"],
				fragmentDefines: ["#define FACE_PICKING"],
				attributes: [
					"faceId" => { name: "a_faceId", type: "vec2" }
				]
			},

			"alphaCulling" => {
				vertexDefines: ["#define ALPHA_CULLING"],
				fragmentDefines: ["#define ALPHA_CULLING"],
				uniforms: [
					"alphaCullingValue" => { name: "u_alphaCullingValue", type: "float", shader: "f", slot: "0.0" }
				]
			}
		];
	}

	public function addShaderConfigs(shaderConfigs:Map<String, ShaderInfo>) {
		for (shaderName in shaderConfigs.keys()) {
			var shaderInfo = shaderConfigs.get(shaderName);

			this._baseShaderConfigs.set(shaderName, shaderInfo);
		}
	}

	public function getShaderInfo(shaderName:String):ShaderInfo {
		var shaderConfig:ShaderInfo = null;
		if (this._shaderConfigs.exists(shaderName)) {
			shaderConfig = this._shaderConfigs.get(shaderName);

		} else {
			if (shaderName.indexOf(EXTENSION_SEPARATOR) == -1) {
				// Simple shader without extensions
				if (this._baseShaderConfigs.exists(shaderName)) {
					shaderConfig = ShaderUtils.cloneShaderInfo(this._baseShaderConfigs.get(shaderName));

					// Preprocess variables
					this.preprocessShaderConfig(shaderConfig);

					// Store configuration
					this._shaderConfigs.set(shaderName, shaderConfig);
				}

			} else {
				// Convert name into base and extensions
				var shaderComponents = shaderName.split(EXTENSION_SEPARATOR);
				if (shaderComponents.length > 0) {

					// Get base shader config
					var baseName = shaderComponents.shift();
					var baseShaderConfig = null;
					if (this._baseShaderConfigs.exists(baseName)) {
						baseShaderConfig = this._baseShaderConfigs.get(baseName);
					}

					// Verify and get all extensions
					var allExtensionsExist = true;
					var extensionsConfigs = new Array<ShaderExtensionInfo>();
					for (extensionName in shaderComponents) {
						if (!this._shaderExtensions.exists(extensionName)) {
							allExtensionsExist = false;
						}
					}


					// Continue to create full config if all ok
					if (baseShaderConfig != null && allExtensionsExist) {
						shaderConfig = ShaderUtils.cloneShaderInfo(baseShaderConfig);

						// Add extension configurations to base configuration
						for (extensionName in shaderComponents) {
							var extensionConfig = this._shaderExtensions.get(extensionName);
							ShaderUtils.extendShaderInfo(shaderConfig, extensionConfig, shaderName, extensionName);
						}

						// Preprocess variables
						this.preprocessShaderConfig(shaderConfig);

						// Store new configuration
						this._shaderConfigs.set(shaderName, shaderConfig);
					}
				}
			}
		}

		return shaderConfig;
	}


	private function preprocessShaderConfig(shaderConfig:ShaderInfo):Void {
		if (shaderConfig.variables != null) {
			for (variable in shaderConfig.variables) {
				ShaderUtils.processVariableForShaderConfig(shaderConfig, variable);
			}
		}
	}

}