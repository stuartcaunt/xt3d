package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.KFShaderReader;
import kfsgl.renderer.shaders.KFShaderInfo;
import kfsgl.renderer.shaders.KFUniformInfo;

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
				vertexShader: KFShaderReader.getInstance().shaderWithKey("test_vertex"),
				fragmentShader: KFShaderReader.getInstance().shaderWithKey("test_fragment"),
				uniforms: [],
			}
		}

		// Put all shader files into a more optimised structure
		for (shaderName in Reflect.fields(shaderConfigsJson)) {
			var config = Reflect.getProperty(shaderConfigsJson, shaderName);
			var vertexShader:String = Reflect.getProperty(config, 'vertexShader');
			var fragmentShader:String = Reflect.getProperty(config, 'fragmentShader');
			var uniforms:Array<KFUniformInfo> = Reflect.getProperty(config, 'uniforms');

			_shaderConfigs.set(shaderName, new KFShaderInfo(vertexShader, fragmentShader, uniforms));
		}
	}

	public function get_shaderConfigs():Map<String, KFShaderInfo> {
		return _shaderConfigs;
	}


}