package xt3d.gl.shaders;

import xt3d.utils.XT;
import xt3d.utils.errors.XTException;
import xt3d.gl.shaders.ShaderTypedefs;
import xt3d.gl.shaders.ShaderUtils;
import xt3d.core.Director;

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
					"viewProjectionMatrix" => { name: "u_viewProjectionMatrix", type: "mat4", shader: "v", defaultValue: "identity", global: true },
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
						{ type: "bool", name: "enabled", defaultValue: "false" },
						{ type: "vec4", name: "ambientColor", defaultValue: "[0.0, 0.0, 0.0, 1.0]" },
						{ type: "vec4", name: "diffuseColor", defaultValue: "[1.0, 1.0, 1.0, 1.0]" },
						{ type: "vec4", name: "specularColor", defaultValue: "[1.0, 1.0, 1.0, 1.0]" },
						{ type: "vec3", name: "attenuation", defaultValue: "[1.0, 0.0, 0.0]" },
						{ type: "float", name: "spotCutoffAngle", defaultValue: "45.0" },
						{ type: "vec3", name: "spotDirection", defaultValue: "[0.0, 0.0, -1.0]" },
						{ type: "float", name: "spotFalloffExponent", defaultValue: "1.0" }
					]
				],
				variables: [
					{ name: "MAX_LIGHTS", value: Director.current.configuration.get(XT.MAX_LIGHTS) }
				],
				vertexDefines: ["#define MAX_LIGHTS $MAX_LIGHTS"],
				fragmentDefines: ["#define MAX_LIGHTS $MAX_LIGHTS"],
				uniforms: [
					"sceneAmbientColor" => { name: "u_sceneAmbientColor", type: "vec4", shader: "fv", defaultValue: "[0.3, 0.3, 0.3, 1.0]", global: true},
					"lights" => { name: "u_lights", type: "Light[$MAX_LIGHTS]", shader: "fv", global: true },
					"lightingEnabled" => { name: "u_lightingEnabled", type: "bool", shader: "fv", defaultValue: "true", global: true },
					"defaultShininess" => { name: "u_defaultShininess", type: "float", shader: "fv", defaultValue: "1.0" }
				]
			},
			"material" => {
				types: [
					"Material" => [
						{ type: "vec4", name: "ambientColor", defaultValue: "[1.0, 1.0, 1.0, 1.0]" },
						{ type: "vec4", name: "diffuseColor", defaultValue: "[1.0, 1.0, 1.0, 1.0]" },
						{ type: "vec4", name: "specularColor", defaultValue: "[1.0, 1.0, 1.0, 1.0]" },
						{ type: "float", name: "shininess", defaultValue: "1.0" }
					]
				],
				uniforms: [
					"material" => { name: "u_material", type: "Material", shader: "fv" }
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
					throw new XTException("DuplicateUniform", "The uniform with the name \"" + uniformName + "\" is duplicated");
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
			throw new XTException("UniformDoesNotExist", "The uniform with the name \"" + uniformName + "\" does not exist");
		}

		return null;
	}

	public function prepareUniforms():Void {
		for (uniform in this._allUniforms) {
			uniform.prepareForUse();
		}
	}

}
