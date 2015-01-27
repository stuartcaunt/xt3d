package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.KFGLProgram;
import kfsgl.renderer.shaders.KFShaderLib;
import kfsgl.errors.KFException;
import kfsgl.utils.KF;

class KFShaderManager {


	private var _programs:Map<String,  KFGLProgram>;

	public function new() {
		_programs = new Map<String, KFGLProgram>();

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
		var shaderConfigs = KFShaderLib.getInstance().shaderConfigs;

		// Iterate over all shaders
		var shaderNames = shaderConfigs.keys();
		while (shaderNames.hasNext()) {
			var shaderName = shaderNames.next();
			var shaderInfo = shaderConfigs.get(shaderName);

			// Create program for each shader
			var program = KFGLProgram.create(shaderName, shaderInfo);

			// Verify program
			if (program != null) {
				// Add program to map
				this.addProgramWithName(shaderName, program);

			} else {
				throw new KFException("UnableToCreateProgram", "The shader program \"" + shaderName + "\" did not compile");
			}
		}
	}
	
	public function addProgramWithName(name:String, program:KFGLProgram):Void {
		// Verify that a program doesn't already exist for the given name
		if (_programs.exists(name)) {
			throw new KFException("ProgramAlreadyExists", "A shader program with the name \"" + name + "\" already exists");
		}

		// Verify that program is not null
		if (program == null) {
			throw new KFException("ProgramIsNull", "The shader program with the name \"" + name + "\" is null when added");
		}

		// Add the program
		_programs.set(name, program);

		KF.Log("Added shader program \"" + name + "\"");
	}

	public function programWithName(name:String) {
		var program = _programs.get(name);
		if (program == null) {
			throw new KFException("NoProgramExistsForKey", "No shader program exists with the name \"" + name + "\"");
		}
		
	}
	

}