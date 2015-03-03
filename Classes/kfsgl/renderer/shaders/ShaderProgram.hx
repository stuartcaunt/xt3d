package kfsgl.renderer.shaders;

import openfl.gl.GL;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.Assets;

import kfsgl.utils.KF;
import kfsgl.renderer.shaders.ShaderInfo;
import kfsgl.renderer.shaders.ShaderReader;
import kfsgl.renderer.shaders.Uniform;
import kfsgl.renderer.shaders.UniformLib;

class ShaderProgram {

	// properties
	public var name(get, null):String;

	// members
	private var _name:String;
	private var _vertexProgram:String;
	private var _fragmentProgram:String;
	private var _program:GLProgram;
	private static var _prefixVertex:String = null;
	private static var _prefixFragment:String = null;

	private var _attributes:Map<String, Int> = new Map<String, Int>();
	private var _uniforms:Map<String, Uniform> = new Map<String, Uniform>();
	private var _commonUniforms:Map<String, Uniform> = new Map<String, Uniform>();

	public static var KFAttributes = KF.jsonToMap({
		position: "a_position",
		normal: "a_normal",
		color: "a_color",
		texCoord: "a_texCoord"
	});

	public function new() {

	}


	/* ----------- Properties ----------- */

	public function get_name():String {
		return _name;
	}


	/* --------- Implementation --------- */

	public static function create(shaderName:String, shaderInfo:ShaderInfo):ShaderProgram {
		var program = new ShaderProgram();
		
		if (program != null && !(program.init(shaderName, shaderInfo))) {
			program = null;
		}

		return program;
	}

	public function init(shaderName:String, shaderInfo:ShaderInfo):Bool {
		this._name = shaderName;

		var vertexProgram = shaderInfo.vertexProgram;
		var fragmentProgram = shaderInfo.fragmentProgram;
		var vertexDefines= shaderInfo.vertexDefines != null ? shaderInfo.vertexDefines.join('\n') : "";
		var fragmentDefines= shaderInfo.fragmentDefines != null ? shaderInfo.fragmentDefines.join('\n') : "";
		var uniforms = shaderInfo.uniforms;
		var commonUniforms = shaderInfo.commonUniforms;

		// Load prefixes
		if (_prefixVertex == null) {
			_prefixVertex = ShaderReader.instance().shaderWithKey("prefix_vertex");
			//_prefixVertex = Assets.getText("assets/shaders/prefix_vertex.glsl");
		}
		if (_prefixFragment == null) {
			_prefixFragment = ShaderReader.instance().shaderWithKey("prefix_fragment");
			//_prefixFragment = Assets.getText("assets/shaders/prefix_fragment.glsl");
		}


		// generate uniform declarations
		var vertexUniforms:String = "";
		for (uniformName in commonUniforms.keys()) {
			var uniformInfo = commonUniforms.get(uniformName).uniformInfo();
			vertexUniforms += "uniform " + uniformInfo.type + " " + uniformInfo.name + ";\n";
		}
		for (uniformName in uniforms.keys()) {
			var uniformInfo = uniforms.get(uniformName);
			vertexUniforms += "uniform " + uniformInfo.type + " " + uniformInfo.name + ";\n";
		}


		// Add prefixes
		_vertexProgram = "// vertexDefines:\n" + vertexDefines + "\n// prefixVertex:\n" + _prefixVertex + "\n// vertexUniforms:\n" + vertexUniforms + "\n// VertexProgram:\n" + vertexProgram;
		_fragmentProgram = "// fragmentDefines:\n" + fragmentDefines + "\n// prefixFragment:\n" + _prefixFragment + "\n// fragmentProgram:\n" + fragmentProgram;

		// Create new program
		_program = GL.createProgram();

		if (_program == null) {
			KF.Log("Failed to create new GLProgram");
			return false;
		}

		// Create shaders
		var vertexShader = createShader(_vertexProgram, GL.VERTEX_SHADER);
		var fragmentShader = createShader(_fragmentProgram, GL.FRAGMENT_SHADER);
		
		// Verify that both vertex and fragment shaders were created successfully
		if (vertexShader == null || fragmentShader == null) {
			return false;
		}

		// Attach shaders
		GL.attachShader(_program, vertexShader);
		GL.attachShader(_program, fragmentShader);

		// Link program		
		GL.linkProgram(_program);
		
		// Delete shaders
		GL.deleteShader(vertexShader);
		GL.deleteShader(fragmentShader);
		
		// Check for errors
		if (GL.getProgramParameter(_program, GL.LINK_STATUS) == 0) {
			KF.Log("ERROR: unable to link program:");
			KF.Log(GL.getProgramInfoLog(_program));
			KF.Log("VALIDATE_STATUS: " + GL.getProgramParameter(_program, GL.VALIDATE_STATUS));
			KF.Log("ERROR: " + GL.getError());
			
			return false;

		} else {
			KF.Log("Compiled and linked successfully program \"" + this._name + "\"");
			//KF.Log("Vertex program:\n" + _vertexProgram);
			//KF.Log("Fragment program:\n" + _fragmentProgram);
		}

		// Get attribute locations
		for (identifier in KFAttributes.keys()) {
			var attribute = GL.getAttribLocation(_program, KFAttributes.get(identifier));
			//KF.Log("attribute " + identifier + " : " + KFAttributes.get(identifier) + " = " + attribute);
			_attributes.set(identifier, attribute);
		}

		// Handle common uniforms
		for (uniformName in commonUniforms.keys()) {
			var uniformInfo = commonUniforms.get(uniformName).uniformInfo();
			var uniformLocation = GL.getUniformLocation(_program, uniformInfo.name);

			// Create a uniform object
			var uniform:Uniform = new Uniform(uniformName, uniformInfo, uniformLocation);

			// Add to all uniforms
			_commonUniforms.set(uniformName, uniform);
		}

		// Handle uniforms
		for (uniformName in uniforms.keys()) {
			var uniformInfo = uniforms.get(uniformName);
			var uniformLocation = GL.getUniformLocation(_program, uniformInfo.name);

			// Create a uniform object
			var uniform:Uniform = new Uniform(uniformName, uniformInfo, uniformLocation);

			// Add to all uniforms
			_uniforms.set(uniformName, uniform);
		}

		return true;
	}


	public function dispose():Void {
		if (_program != null) {
			GL.deleteProgram(_program);
			_program = null;
		}
	}

	private function createShader(source:String, type:Int):GLShader {
		// Create new shader
		var shader = GL.createShader(type);
		if (shader == null) {
			KF.Log("ERROR: Failed to create new GLShader");
			return null;
		}

		// attach and compile shader
		GL.shaderSource(shader, source);
		GL.compileShader(shader);
		
		// Verify that shader comiled
		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0) {
			KF.Log("ERROR compiling " + (type == GL.VERTEX_SHADER ? "vertex" : "fragment") + " shader: " + GL.getShaderInfoLog(shader));
			if (type == GL.VERTEX_SHADER) {
				KF.Log("Vertex program:\n" + _vertexProgram);
			} else {

				KF.Log("Fragment program:\n" + _fragmentProgram);
			}
			return null;
		}
		
		return shader;
	}

	public function cloneUniforms():Map<String, Uniform> {
		var cloned:Map<String, Uniform> = new Map<String, Uniform>();
		for (uniform in _uniforms) {
			cloned.set(uniform.name(), uniform.clone());
		}

		return cloned;
	}

	public function cloneCommonUniforms():Map<String, Uniform> {
		var cloned:Map<String, Uniform> = new Map<String, Uniform>();
		for (uniform in _commonUniforms) {
			cloned.set(uniform.name(), uniform.clone());
		}

		return cloned;
	}

}