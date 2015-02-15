package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.KFShaderInfo;
import kfsgl.renderer.shaders.KFUniformLib;

class KFShaderLib  {

	// Properties
	public var shaderConfigs(get_shaderConfigs, null):Map<String, KFShaderInfo>;

	// Members
	private static var _instance:KFShaderLib = null;
	private var _shaderConfigs:Map<String, KFShaderInfo> = new Map<String, KFShaderInfo>();

	private function new() {
	}
	
	public static function instance():KFShaderLib {
		if (_instance == null) {
			_instance = new KFShaderLib();
			_instance.init();
		}

		return _instance;
	}

	public function init():Void {
		var shaderConfigsJson = {
			test_color: {
				vertexShader: "test_vertex",
				fragmentShader: "test_fragment",
				vertexDefines: ["#define USE_COLOR"],
				commonUniforms: ["common"],
				uniforms: {
					color: { name: "u_color", type: "vec4", defaultValue: "[1, 1, 1, 1]" }
				}
			},
			test_nocolor: {
				vertexShader: "test_vertex",
				fragmentShader: "test_fragment",
				commonUniforms: ["common"],
				uniforms: {
					color: { name: "u_color", type: "vec4", defaultValue: "[1, 1, 1, 1]" }
				}
			}
		}

		// Put all shader files into a more optimised structure
		for (shaderName in Reflect.fields(shaderConfigsJson)) {
			var config = Reflect.getProperty(shaderConfigsJson, shaderName);
			var vertexShaderKey:String = Reflect.getProperty(config, 'vertexShader');
			var fragmentShaderKey:String = Reflect.getProperty(config, 'fragmentShader');
			var vertexDefines:Array<String> = Reflect.getProperty(config, 'vertexDefines');
			var fragmentDefines:Array<String> = Reflect.getProperty(config, 'fragmentDefines');
			var commonUniforms:Array<String> = Reflect.getProperty(config, 'commonUniforms');

			var uniformMap = new Map<String, KFUniformInfo>();
			var allUniformInfoJson = Reflect.getProperty(config, 'uniforms');

			for (uniformName in Reflect.fields(allUniformInfoJson)) {
				// Convert uniform json into type
				var uniformInfoJson = Reflect.getProperty(allUniformInfoJson, uniformName);
				var uniformInfo:KFUniformInfo = {
					name: uniformInfoJson.name,
					type: uniformInfoJson.type,
					defaultValue: uniformInfoJson.defaultValue
				};

				// Add uniform info to map
				uniformMap.set(uniformName, uniformInfo);

			}

			_shaderConfigs.set(shaderName, new KFShaderInfo(
				vertexShaderKey,
				fragmentShaderKey,
				vertexDefines,
				fragmentDefines,
				uniformMap,
				commonUniforms
			));
		}
	}

	public function get_shaderConfigs():Map<String, KFShaderInfo> {
		return _shaderConfigs;
	}


}