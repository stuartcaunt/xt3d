package kfsgl.renderer.shaders;

import kfsgl.errors.KFException;


typedef KFUniformInfo = {
	var name: String;
	var type: String;
	var defaultValue: String;
}

class UniformLib {

	// Members
	private static var _instance:UniformLib = null;
	private var _uniforms:Map<String, Map<String, Uniform> > = new Map<String, Map<String, Uniform> >();

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
		var uniformsJson = {
			common: {
				modelViewProjectionMatrix: { name: "u_modelViewProjectionMatrix", type: "mat4", defaultValue: "identity" },
				modelViewMatrix: { name: "u_modelViewMatrix", type: "mat4", defaultValue: "identity" },
				modelMatrix: { name: "u_modelMatrix", type: "mat4", defaultValue: "identity" },
				viewMatrix: { name: "u_viewMatrix", type: "mat4", defaultValue: "identity" },
				normalMatrix: { name: "u_normalMatrix", type: "mat3", efaultValue: "identity" }
			}
		};

		// Put all shader files into a more optimised structure
		for (groupName in Reflect.fields(uniformsJson)) {

			// Create new map for uniforms values
			var uniformValuesMap = new Map<String, Uniform>();
			_uniforms.set(groupName, uniformValuesMap);

			// Iterate over uniforms for the group
			var allUniformInfoJson = Reflect.getProperty(uniformsJson, groupName);
			for (uniformName in Reflect.fields(allUniformInfoJson)) {

				// Convert uniform json into type
				var uniformInfoJson = Reflect.getProperty(allUniformInfoJson, uniformName);
				var uniformInfo:KFUniformInfo = { 
					name: uniformInfoJson.name, 
					type: uniformInfoJson.type, 
					defaultValue: uniformInfoJson.defaultValue
				};

				// Add uniform value to map
				uniformValuesMap.set(uniformName, new Uniform(uniformName, uniformInfo, -99));
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
			var uniformMap = _uniforms.get(group);
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
	 * Get specific uniform from a group (normally to set it's global value)
	 */
	public function uniform(groupName:String, uniformName:String):Uniform {
		// Get uniform group and verify that it exists
		var uniformMap = _uniforms.get(groupName);
		if (uniformMap != null) {
			// Get the uniform
			var uniform = uniformMap.get(uniformName);
			if (uniform != null) {
				return uniform;

			} else {
				throw new KFException("UniformDoesNotExist", "The uniform with the name \"" + uniformName + "\" from the group \"" + groupName + "\" does not exist");

			}
		} else {
			throw new KFException("UniformGroupDoesNotExist", "The uniform group with the name \"" + groupName + "\" does not exist");

		}

		return null;

	}

}
