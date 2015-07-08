package kfsgl.gl.shaders;

import kfsgl.utils.errors.KFException;
import kfsgl.gl.shaders.ShaderTypedefs;
import kfsgl.gl.shaders.ShaderUtils;

class UniformLib {

	// Members
	private var _uniformGroups:Map<String, UniformGroupInfo >;
	private var _allUniforms:Map<String, Uniform > = new Map<String, Uniform>();

	public static function create():UniformLib {
		var object = new UniformLib();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}


	public function init():Bool {
		// Note no uniform should have the same name even if in different groups
		this._uniformGroups = [
			"matrixCommon" => {
				uniforms: 			[
					"modelViewProjectionMatrix" => { name: "u_modelViewProjectionMatrix", type: "mat4", shader: "v", defaultValue: "identity" },
					"modelViewMatrix" => { name: "u_modelViewMatrix", type: "mat4", shader: "v", defaultValue: "identity" },
					"modelMatrix" => { name: "u_modelMatrix", type: "mat4", shader: "v", defaultValue: "identity" },
					"viewMatrix" => { name: "u_viewMatrix", type: "mat4", shader: "v", defaultValue: "identity", global: true },
					"projectionMatrix" => { name: "u_projectionMatrix", type: "mat4", shader: "v", defaultValue: "identity", global: true },
					"normalMatrix" => { name: "u_normalMatrix", type: "mat3", shader: "v", defaultValue: "identity" }
				]
			},
			"time" => {
				uniforms: [
					"time" => { name: "u_time", type: "float", shader: "fv", defaultValue: "0.0", global: true}
				]
			},
			"texture" => {
				uniforms: [
					"texture" => { name: "u_texture", type: "texture", shader: "f" },
					"uvScaleOffset" => { name: "u_uvScaleOffset", type: "vec4", shader: "v", defaultValue: "[1.0, 1.0, 0.0, 0.0]" }
				]
			},
			"opacity" => {
				uniforms: [
					"opacity" => { name: "u_opacity", type: "float", shader: "f", defaultValue: "1.0" }
				]
			},
			"lighting" => {
				types: [
					"Light" => [
						{ type: "vec4", name: "position"},
						{ type: "vec4", name: "ambientColor"},
						{ type: "vec4", name: "diffuseColor"},
						{ type: "vec4", name: "specularColor"},
						{ type: "vec3", name: "attenuation"},
						{ type: "float", name: "spotCutoffAngle"},
						{ type: "vec3", name: "spotDirection"},
						{ type: "float", name: "spotFalloffExponent"}
					]
				],
				variables: [
					{ name: "MAX_LIGHTS", value: "4" } // TODO Specify max from director config
				],
				vertexDefines: ["#define MAX_LIGHTS $MAX_LIGHTS"],
				uniforms: [
					"sceneAmbientColor" => { name: "u_sceneAmbientColor", type: "vec3", shader: "v", defaultValue: "[0.3, 0.3, 0.3]", global: true},
					"lights" => { name: "u_lights", type: "Light[$MAX_LIGHTS]", shader: "v", global: true },
					"lightEnabled" => { name: "u_lightEnabled", type: "bool[$MAX_LIGHTS]", shader: "v", global: true },
					"lightingEnabled" => { name: "u_lightingEnabled", type: "bool", shader: "v", defaultValue: "true", global: true }
				]
			}
		];

		// Pre-process all variables in uniform infos
		for (uniformGroupInfo in this._uniformGroups) {

			if (uniformGroupInfo.variables != null) {
				// Pre-process uniform group info for variables
				for (variable in uniformGroupInfo.variables) {
					ShaderUtils.processVariableForUniformGroupInfo(uniformGroupInfo, variable);
				}
			}
		}

		// Pack all uniforms in a single map
		for (uniformGroupInfo in this._uniformGroups) {

			// Get data types
			var dataTypes = uniformGroupInfo.types;

			// Create real uniforms from uniformInfos

			for (uniformName in uniformGroupInfo.uniforms.keys()) {

				if (!_allUniforms.exists(uniformName)) {
					var uniformInfo = uniformGroupInfo.uniforms.get(uniformName);

					// Create empty uniform object
					var uniform = Uniform.createEmpty(uniformName, uniformInfo, dataTypes);

					_allUniforms.set(uniform.name, uniform);

				} else {
					throw new KFException("DuplicateUniform", "The uniform with the name \"" + uniformName + "\" is duplicated");
				}
			}
		}

		return true;
	}

	private function new() {
	}


	/*
	 * Combine the info from all specified groups into a single uniform group info
	 */
	public function uniformGroupInfoForGroups(groups:Array<String>):UniformGroupInfo {
		var combinedUniformGroupInfo:UniformGroupInfo = {
			variables: (new Array<ShaderVariable>()),
			types: (new Map<String, Array<BaseTypeInfo>>()),
			vertexDefines: (new Array<String>()),
			fragmentDefines: (new Array<String>()),
			uniforms: (new Map<String, UniformInfo>())
		};

		// Iterate over groups
		for (group in groups) {

			// Get uniform group and verify that it exists
			if (this._uniformGroups.exists(group)) {
				var uniformGroupInfo = this._uniformGroups.get(group);

				// types
				if (uniformGroupInfo.types != null) {
					for (typeName in uniformGroupInfo.types.keys()) {
						var clonedTypeDef = new Array<BaseTypeInfo>();
						combinedUniformGroupInfo.types.set(typeName, clonedTypeDef);

						var typeDefinition = uniformGroupInfo.types.get(typeName);
						for (baseType in typeDefinition) {
							clonedTypeDef.push(ShaderUtils.cloneBaseTypeInfo(baseType));
						}
					}
				}

				// variables
				if (uniformGroupInfo.variables != null) {
					for (shaderVariable in uniformGroupInfo.variables) {
						combinedUniformGroupInfo.variables.push(ShaderUtils.cloneShaderVariable(shaderVariable));
					}
				}

				// Vertex defines
				if (uniformGroupInfo.vertexDefines != null) {
					for (vertexDefine in uniformGroupInfo.vertexDefines) {
						combinedUniformGroupInfo.vertexDefines.push(vertexDefine);
					}
				}

				// fragment defines
				if (uniformGroupInfo.fragmentDefines != null) {
					for (fragmentDefine in uniformGroupInfo.fragmentDefines) {
						combinedUniformGroupInfo.fragmentDefines.push(fragmentDefine);
					}
				}


				// Iterate over uniforms in the group
				var uniformNames = uniformGroupInfo.uniforms.keys();
				while (uniformNames.hasNext()) {
					var uniformName = uniformNames.next();

					// Get the uniform
					var uniform = uniformGroupInfo.uniforms.get(uniformName);

					// Add to all uniforms to return
					combinedUniformGroupInfo.uniforms.set(uniformName, uniform);
				}

			}
		}

		return combinedUniformGroupInfo;
	}

	/*
	 * Get specific uniform (normally to set it's global value)
	 */
	public function uniform(uniformName:String):Uniform {
		// Get uniform group and verify that it exists
		if (_allUniforms.exists(uniformName)) {
			var uniform = _allUniforms.get(uniformName);
			return uniform;

		} else {
			throw new KFException("UniformDoesNotExist", "The uniform with the name \"" + uniformName + "\" does not exist");
		}

		return null;
	}

	public function prepareUniforms():Void {
		for (uniform in this._allUniforms) {
			uniform.prepareForUse();
		}
	}

}
