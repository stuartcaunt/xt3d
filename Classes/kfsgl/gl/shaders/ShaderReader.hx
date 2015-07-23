package kfsgl.gl.shaders;

import kfsgl.utils.StringFunctions;
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
		var shaderFiles = new Map<String, String>();

		// Get list of all available glsl files
		var textAssets = Assets.list(AssetType.TEXT);
		var glslAssests = new Array<String>();
		for (textAsset in textAssets) {
			var suffix = "glsl";
			if (StringFunctions.hasSuffix(textAsset, suffix)) {
				var shaderName = StringFunctions.fileWithoutPathAndSuffix(textAsset);
				shaderFiles.set(shaderName, textAsset);
			}
		}

		for (key in shaderFiles.keys()) {
			var shaderFile = shaderFiles.get(key);

			// Read shader file
			//KF.Log("Reading shader file " + shaderFile);

			var fileContents = Assets.getText(shaderFile);
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

	public function shaderWithFilename(filename):String {
		var fileContents = Assets.getText(filename);
		if (fileContents != null) {
			// Add to available shaders
			var shaderName = StringFunctions.fileWithoutPathAndSuffix(filename);
			if (!this._shaderPrograms.exists(shaderName)) {
				_shaderPrograms.set(shaderName, fileContents);
			}
		}

		return fileContents;

	}

}