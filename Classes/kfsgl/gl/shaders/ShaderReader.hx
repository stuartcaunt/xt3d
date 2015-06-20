package kfsgl.gl.shaders;

import openfl.Assets;

import kfsgl.utils.KF;
import kfsgl.utils.errors.KFException;

class ShaderReader  {

	private static var _instance:ShaderReader = null;

	private var _shaderPrograms:Map<String, String> = new Map<String, String>();

	private function new() {
	}
	
	public static function instance():ShaderReader {
		if (_instance == null) {
			_instance = new ShaderReader();
			_instance.init();
		}

		return _instance;
	}


	public function init():Void {
		var shaderFiles = [
			"prefix_vertex" => "prefix_vertex.glsl",
			"prefix_fragment" => "prefix_fragment.glsl",
			"generic_vertex" => "generic_vertex.glsl",
			"generic_fragment" => "generic_fragment.glsl"
		];

		for (key in shaderFiles.keys()) {
			var shaderFile = shaderFiles.get(key);

			// Read shader file
			//KF.Log("Reading shader file " + shaderFile);

			var fileContents = Assets.getText("assets/shaders/" + shaderFile);
			_shaderPrograms.set(key, fileContents);
		}
	}

	public function shaderWithKey(key):String {
		if (_shaderPrograms.exists(key)) {
			//KF.Log("Getting shader program for key " + key);
			return _shaderPrograms.get(key);
		}

		throw new KFException("ShaderFProgramKeyUnknown", "The shader program key \"" + key + "\" is unknown");
	}

}