package kfsgl.gl.shaders;

import openfl.gl.GLUniformLocation;
import kfsgl.utils.errors.KFException;

class UniformLib {

	// Members
	private static var _instance:UniformLib = null;
	private var _uniformGroups:Map<String, Map<String, Uniform> > = new Map<String, Map<String, Uniform> >();
	private var _allUniforms:Map<String, Uniform > = new Map<String, Uniform>();

	private function new() {
	}
	
	public static function instance():UniformLib {
		if (_instance == null) {
			_instance = new UniformLib();
			_instance.init();
		}

		return _instance;
	}

	public function init():Void {
		// Not no uniform should have the same name even if in different groups
		var uniformsJson = {
			matrixCommon: {
				modelViewProjectionMatrix: { name: "u_modelViewProjectionMatrix", type: "mat4", shader: "v", defaultValue: "identity" },
				modelViewMatrix: { name: "u_modelViewMatrix", type: "mat4", shader: "v", defaultValue: "identity" },
				modelMatrix: { name: "u_modelMatrix", type: "mat4", shader: "v", defaultValue: "identity" },
				viewMatrix: { name: "u_viewMatrix", type: "mat4", shader: "v", defaultValue: "identity", global: true },
				projectionMatrix: { name: "u_projectionMatrix", type: "mat4", shader: "v", defaultValue: "identity", global: true },
				normalMatrix: { name: "u_normalMatrix", type: "mat3", shader: "v", defaultValue: "identity" }
			},
			time: {
				time: { name: "u_time", type: "float", shader: "fv", defaultValue: "0.0", global: true}
			},
			texture: {
				texture: { name: "u_texture", type: "texture", shader: "f" },
				uvScaleOffset: { name: "u_uvScaleOffset", type: "vec4", shader: "v", defaultValue: "[1.0, 1.0, 0.0, 0.0]" }
			},
			opacity: {
				opacity: { name: "u_opacity", type: "float", shader: "f", defaultValue: "1.0" }
			}
		};

		// Put all shader files into a more optimised structure
		for (groupName in Reflect.fields(uniformsJson)) {

			// Create new map for uniforms values
			var uniformValuesMap = new Map<String, Uniform>();
			this._uniformGroups.set(groupName, uniformValuesMap);

			// Iterate over uniforms for the group
			var allUniformInfoJson = Reflect.getProperty(uniformsJson, groupName);
			for (uniformName in Reflect.fields(allUniformInfoJson)) {

				// Convert uniform json into type
				var uniformInfoJson = Reflect.getProperty(allUniformInfoJson, uniformName);
				var uniformInfo:UniformInfo = {
					name: uniformInfoJson.name, 
					type: uniformInfoJson.type, 
					shader: uniformInfoJson.shader,
					defaultValue: uniformInfoJson.defaultValue,
					global: uniformInfoJson.global == true ? true : false,
					slot: -1
				};

				if (Reflect.hasField(uniformInfoJson, "slot")) {
					uniformInfo.slot = uniformInfoJson.slot;
				}

				// Add uniform value to map
				uniformValuesMap.set(uniformName, Uniform.createEmpty(uniformName, uniformInfo));
			}
		}

		// Pack all uniforms in a single map
		for (uniformGroup in _uniformGroups) {
			for (uniform in uniformGroup) {
				if (!_allUniforms.exists(uniform.name)) {
					_allUniforms.set(uniform.name, uniform);

				} else {
					throw new KFException("DuplicateUniform", "The uniform with the name \"" + uniform.name + "\" is duplicated");
				}
			}
		}

	}

	/*
	 * Get all uniforms from a group
	 */
	public function uniformsFromGroups(groups:Array<String>):Map<String, Uniform> {
		var uniforms = new Map<String, Uniform>();

		// Iterate over groups
		for (group in groups) {

			// Get uniform group and verify that it exists
			var uniformMap = this._uniformGroups.get(group);
			if (uniformMap != null) {

				// Iterate over uniforms in the group
				var uniformNames = uniformMap.keys();
				while (uniformNames.hasNext()) {
					var uniformName = uniformNames.next();

					// Get the uniform
					var uniform = uniformMap.get(uniformName);

					// Add to all uniforms to return
					uniforms.set(uniformName, uniform);
				}

			}
		}

		return uniforms;
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
