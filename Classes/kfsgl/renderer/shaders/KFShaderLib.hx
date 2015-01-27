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
	
	public static function getInstance():KFShaderLib {
		if (_instance == null) {
			_instance = new KFShaderLib();
			_instance.init();
		}

		return _instance;
	}

	public function init():Void {
		var shaderConfigsJson = {
			'test': {
				vertexShader: "test_vertex",
				fragmentShader: "test_fragment",
				uniforms: ["common", "color"],
			}
		}

		// Put all shader files into a more optimised structure
		for (shaderName in Reflect.fields(shaderConfigsJson)) {
			var config = Reflect.getProperty(shaderConfigsJson, shaderName);
			var vertexShaderKey:String = Reflect.getProperty(config, 'vertexShader');
			var fragmentShaderKey:String = Reflect.getProperty(config, 'fragmentShader');
			var uniformGroups:Array<String> = Reflect.getProperty(config, 'uniforms');

			_shaderConfigs.set(shaderName, new KFShaderInfo(vertexShaderKey, fragmentShaderKey, uniformGroups));
		}
	}

	public function get_shaderConfigs():Map<String, KFShaderInfo> {
		return _shaderConfigs;
	}


}