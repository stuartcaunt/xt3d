package kfsgl.renderer.shaders;


typedef KFUniformInfo = {
	var name: String;
	var type: String;
	var defaultValue: String;
}

class KFUniformLib {

	// Members
	private static var _instance:KFUniformLib = null;
	private var _uniformLib:Map<String, Map<String, KFUniformInfo> > = new Map<String, Map<String, KFUniformInfo> >();

	private function new() {
	}
	
	public static function getInstance():KFUniformLib {
		if (_instance == null) {
			_instance = new KFUniformLib();
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
				normalMatrix: { name: "u_normalMatrix", type: "mat3", defaultValue: "identity" },
			},
			color: {
				color: { name: "u_color", type: "vec4", defaultValue: "[1, 1, 1, 1]" }
			}
		};

		// Put all shader files into a more optimised structure
		for (groupName in Reflect.fields(uniformsJson)) {

			// Create new map for uniforms group			
			var uniformMap = new Map<String, KFUniformInfo>();
			_uniformLib.set(groupName, uniformMap);

			// Iterate over uniforms for the group
			var allUniformInfoJson = Reflect.getProperty(uniformsJson, groupName);
			for (uniformName in Reflect.fields(allUniformInfoJson)) {

				// Convert uniform json into type
				var uniformInfoJson = Reflect.getProperty(allUniformInfoJson, uniformName);
				var uniformInfo:KFUniformInfo = { 
					name: uniformInfoJson.name, 
					type: uniformInfoJson.type, 
					defaultValue: uniformInfoJson.defaultValue, 
				};

				// Add uniform info to map
				uniformMap.set(uniformName, uniformInfo);
			}
		}
	}


	public function uniformsFromGroups(groups:Array<String>):Map<String, KFUniformInfo> {
		var uniforms = new Map<String, KFUniformInfo>();

		// Iterate over groups
		for (group in groups) {

			// Get uniform group and verify that it exists
			var uniformMap = _uniformLib.get(group);
			if (uniformMap != null) {

				// Iterate over uniforms in the group
				var uniformNames = uniformMap.keys();
				while (uniformNames.hasNext()) {
					var uniformName = uniformNames.next();

					// Get the uniform info
					var uniformInfo = uniformMap.get(uniformName);

					// Add to all uniforms to return
					uniforms.set(uniformName, uniformInfo);
				}

			}
		}

		return uniforms;
	}
}
