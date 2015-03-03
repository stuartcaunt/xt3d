package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.ShaderProgram;
import kfsgl.renderer.shaders.ShaderLib;
import kfsgl.errors.Exception;
import kfsgl.utils.KF;

class ShaderManager {


	private var _programs:Map<String,  ShaderProgram>;

	private static var _instance:ShaderManager = null;

	public static function instance():ShaderManager {
		if (_instance == null) {
			_instance = new ShaderManager();
		}

		return _instance;
	}

	private function new() {
		_programs = new Map<String, ShaderProgram>();

	}

	public function purgeShaders():Void {
		var keys = _programs.keys();
		while (keys.hasNext()) {
			var key = keys.next();
			var program = _programs.get(key);

			// destroy program
			program.dispose();

			// Remove program for map
			_programs.remove(key);

		}
	}

	public function loadDefaultShaders():Void {
		// Get all shader configs
		var shaderConfigs = ShaderLib.instance().shaderConfigs;

		// Iterate over all shaders
		var shaderNames = shaderConfigs.keys();
		while (shaderNames.hasNext()) {
			var shaderName = shaderNames.next();
			var shaderInfo = shaderConfigs.get(shaderName);

			// Create program for each shader
			var program = ShaderProgram.create(shaderName, shaderInfo);

			// Verify program
			if (program != null) {
				// Add program to map
				this.addProgramWithName(shaderName, program);

			} else {
				throw new Exception("UnableToCreateProgram", "The shader program \"" + shaderName + "\" did not compile");
			}
		}
	}
	
	public function addProgramWithName(name:String, program:ShaderProgram):Void {
		// Verify that a program doesn't already exist for the given name
		if (_programs.exists(name)) {
			throw new Exception("ProgramAlreadyExists", "A shader program with the name \"" + name + "\" already exists");
		}

		// Verify that program is not null
		if (program == null) {
			throw new Exception("ProgramIsNull", "The shader program with the name \"" + name + "\" is null when added");
		}

		// Add the program
		_programs.set(name, program);

		KF.Log("Added shader program \"" + name + "\"");
	}

	public function programWithName(name:String):ShaderProgram {
		var program = _programs.get(name);
		if (program == null) {
			throw new Exception("NoProgramExistsForKey", "No shader program exists with the name \"" + name + "\"");
		}

		return program;
	}
	

}