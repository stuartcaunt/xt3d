package kfsgl.material;

import kfsgl.errors.KFException;
import kfsgl.renderer.shaders.KFShaderManager;
import kfsgl.renderer.shaders.KFUniform;
import kfsgl.renderer.shaders.KFGLProgram;

class KFMaterial {

	public var programName(default, null):String;
	public var program(default, null):KFGLProgram;

	private var _uniforms:Map<String, KFUniform> = new Map<String, KFUniform>();
	private var _commonUniforms:Map<String, KFUniform> = new Map<String, KFUniform>();

	public function new(programName:String) {
		this.setProgramName(programName);
	}



	public function setProgramName(programName:String) {
		if (programName != this.programName) {
			// get program for shader manager
			var program = KFShaderManager.instance().programWithName(programName);

			this.program = program;
		}

		return this.programName;
	}

	public function setProgram(program:KFGLProgram) {
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

		_uniforms = new Map<String, KFUniform>();
		_commonUniforms = new Map<String, KFUniform>();
	}

	public function uniform(uniformName:String):KFUniform {
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
