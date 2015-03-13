package kfsgl.material;

import kfsgl.errors.KFException;
import kfsgl.renderer.shaders.ShaderManager;
import kfsgl.renderer.shaders.Uniform;
import kfsgl.renderer.shaders.ShaderProgram;

class Material {

	public var programName(default, null):String;
	public var program(default, null):ShaderProgram;

	private var _uniforms:Map<String, Uniform> = new Map<String, Uniform>();
	private var _commonUniforms:Map<String, Uniform> = new Map<String, Uniform>();

	public function new(programName:String) {
		this.setProgramName(programName);
	}



	public function setProgramName(programName:String) {
		if (programName != this.programName) {
			// get program for shader manager
			var program = ShaderManager.instance().programWithName(programName);

			this.program = program;
		}

		return this.programName;
	}

	public function setProgram(program:ShaderProgram) {
		if (this.program != program) {
			// cleanup
			this.cleanup();

			this.program = program;
			this.programName = program.name;

			// Get common uniforms
			_commonUniforms = this.program.cloneCommonUniforms();

			// Get uniforms
			_uniforms = this.program.cloneUniforms();
		}

		return this.program;
	}



	public function cleanup() {
		this.program = null;
		this.programName = null;

		_uniforms = new Map<String, Uniform>();
		_commonUniforms = new Map<String, Uniform>();
	}

	public function uniform(uniformName:String):Uniform {
		// Get uniform from uniforms
		var uniform = _uniforms.get(uniformName);

		if (uniform == null) {
			// Get from common uniforms
			uniform = _commonUniforms.get(uniformName);

			if (uniform == null) {
				throw new KFException("NoUniformExistsForUniformName", "No uniform exists with the name \"" + uniformName + "\"");
			}
		}

		return uniform;
	}

}
