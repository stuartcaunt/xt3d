package xt3d.gl.shaders;

import xt3d.gl.XTGL;
import lime.graphics.opengl.GLShaderPrecisionFormat;
import xt3d.gl.shaders.ShaderProgram;
import xt3d.gl.shaders.ShaderLib;
import xt3d.utils.errors.XTException;
import xt3d.utils.XT;
import xt3d.core.Director;

class ShaderManager {


	private var _programs:Map<String,  ShaderProgram>;

	private var _precision:String;
	private var _highPrecisionAvailable:Bool = true;
	private var _mediumPrecisionAvailable:Bool = true;
	private var _precisionAvailable:Bool = true;
	private var _uniformLib:UniformLib;
	private var _glInfo:GLInfo;

	public static function create(uniformLib:UniformLib, glInfo:GLInfo):ShaderManager {
		var object = new ShaderManager();

		if (object != null && !(object.init(uniformLib, glInfo))) {
			object = null;
		}

		return object;
	}

	private function init(uniformLib:UniformLib, glInfo:GLInfo):Bool {
		this._uniformLib = uniformLib;
		this._glInfo = glInfo;

		_programs = new Map<String, ShaderProgram>();

		// Get available precisions
		var vertexShaderPrecisionHighpFloat:GLShaderPrecisionFormat = glInfo.vertexShaderPrecisionHighpFloat;
		var vertexShaderPrecisionMediumpFloat:GLShaderPrecisionFormat = glInfo.vertexShaderPrecisionMediumpFloat;
		var fragmentShaderPrecisionHighpFloat:GLShaderPrecisionFormat = glInfo.fragmentShaderPrecisionHighpFloat;
		var fragmentShaderPrecisionMediumpFloat:GLShaderPrecisionFormat = glInfo.fragmentShaderPrecisionMediumpFloat;

		if (vertexShaderPrecisionHighpFloat != null) {
			this._highPrecisionAvailable = (vertexShaderPrecisionHighpFloat.precision > 0 && fragmentShaderPrecisionHighpFloat.precision > 0);
			this._mediumPrecisionAvailable = (vertexShaderPrecisionMediumpFloat.precision > 0 && fragmentShaderPrecisionMediumpFloat.precision > 0);

		} else {
			this._precisionAvailable = false;
		}

		// Set max precision (compared to desired precision) in shader lib
		var desiredPrecision = Director.current.configuration.get(XT.SHADER_PRECISION);
		this.setShaderPrecision(desiredPrecision);

		return true;
	}


	private function new() {
	}

	public function setShaderPrecision(precision:String):Void {
		if (this._precisionAvailable) {
			this._precision = precision;
			if (precision == XTGL.HIGH_PRECISION && !this._highPrecisionAvailable) {
				if (this._mediumPrecisionAvailable) {
					this._precision = XTGL.MEDIUM_PRECISION;
					XT.Warn("high precision not supported, reverting to medium precision");

				} else {
					this._precision = XTGL.LOW_PRECISION;
					XT.Warn("high precision not supported, reverting to low precision");
				}
			} else if (precision == XTGL.MEDIUM_PRECISION && !this._mediumPrecisionAvailable) {
				this._precision = XTGL.LOW_PRECISION;
				XT.Warn("medium precision not supported, reverting to low precision");
			}
		} else {
			this._precision = null;
		}
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

		var defaultShaders = [
			"generic",
			"generic+vertexColors",
			"generic+texture",
			"generic+texture+gouraud",
			"generic+texture+gouraud+material",
			"generic+texture+vertexColors"
		];

		for (defaultShader in defaultShaders) {
			this.createShaderProgram(defaultShader);
		}
	}

	public function createShaderProgram(shaderName:String):ShaderProgram {
		var shaderInfo = ShaderLib.instance().getShaderInfo(shaderName);

		if (shaderInfo != null) {
			// Create program for each shader
			var program = ShaderProgram.create(shaderName, shaderInfo, this._precision, this._uniformLib, this._glInfo);

			// Verify program
			if (program != null) {
				// Add program to map
				this.addProgramWithName(shaderName, program);

				return program;

			} else {
				throw new XTException("UnableToCreateProgram", "The shader program \"" + shaderName + "\" did not compile");
			}

		} else {
			throw new XTException("NoShaderProgramConfig", "The shader program \"" + shaderName + "\" does not exist in library configs");
		}
	}

	public function addProgramWithName(name:String, program:ShaderProgram):Void {
		// Verify that a program doesn't already exist for the given name
		if (_programs.exists(name)) {
			throw new XTException("ProgramAlreadyExists", "A shader program with the name \"" + name + "\" already exists");
		}

		// Verify that program is not null
		if (program == null) {
			throw new XTException("ProgramIsNull", "The shader program with the name \"" + name + "\" is null when added");
		}

		// Add the program
		_programs.set(name, program);

		//XT.Log("Added shader program \"" + name + "\"");
	}

	public function programWithName(name:String):ShaderProgram {
		var program = _programs.get(name);
		if (program == null) {

			// If it doesn't exist create the shader (if possible)
			program = this.createShaderProgram(name);
		}

		return program;
	}
	

}