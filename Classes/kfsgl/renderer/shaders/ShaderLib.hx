package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.ShaderInfo;
import kfsgl.renderer.shaders.UniformLib;

class ShaderLib  {

	// Properties
	public var shaderConfigs(get, null):Map<String, ShaderInfo>;

	// Members
	private static var _instance:ShaderLib = null;
	private var _shaderConfigs:Map<String, ShaderInfo> = new Map<String, ShaderInfo>();

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

			this._shaderConfigs.set(shaderName, new ShaderInfo(
				vertexShaderKey,
				fragmentShaderKey,
				vertexDefines,
				fragmentDefines,
				uniformMap,
				commonUniforms
			));
		}
	}


}