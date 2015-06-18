package kfsgl.gl.shaders;

import kfsgl.utils.KF;
import kfsgl.gl.shaders.ShaderTypedefs;

class ShaderLib  {

	// Properties
	public var shaderConfigs(get, null):Map<String, ShaderInfo>;

	// Members
	private static var _instance:ShaderLib = null;
	private var _shaderConfigs:Map<String, ShaderInfo>;

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
		this._shaderConfigs = [
			"test_color" => {
				vertexProgram: "test_vertex",
				fragmentProgram: "test_fragment",
				vertexDefines: ["#define USE_COLOR"],
				commonUniformGroups: ["matrixCommon", "time", "opacity"],
				uniforms: [
					"color" => { name: "u_color", type: "vec4", shader: "v", defaultValue: "[1, 1, 1, 1]" }
				]
			},
			"test_nocolor" => {
				vertexProgram: "test_vertex",
				fragmentProgram: "test_fragment",
				commonUniformGroups: ["matrixCommon", "time", "opacity"],
				uniforms: [
					"color" => { name: "u_color", type: "vec4", shader: "v", defaultValue: "[1, 1, 1, 1]" }
				]
			},
			"test_texture" => {
				vertexProgram: "test_vertex",
				fragmentProgram: "test_fragment",
				vertexDefines: ["#define USE_TEXTURE"],
				fragmentDefines: ["#define USE_TEXTURE"],
				commonUniformGroups: ["matrixCommon", "time", "texture", "opacity"],
				uniforms: [
					"color" => { name: "u_color", type: "vec4", shader: "v", defaultValue: "[1, 1, 1, 1]" },
					// Example of overriding common uniform
					"texture" => { name: "u_texture", type: "texture", shader: "f", slot: "5" }
				]
			}
		];
	}


}