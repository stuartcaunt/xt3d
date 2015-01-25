package kfsgl.renderer.shaders;

import openfl.gl.GL;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.Assets;

import kfsgl.utils.KF;

class KFGLProgram {

	private var _name:String;
	private var _program:GLProgram;
	private static var _prefixVertex:String = null;
	private static var _prefixFragment:String = null;

	private var _attributes:Map<String, Int> = new Map<String, UInt>();
	private var _uniforms:Map<String, Int> = new Map<String, UInt>();

	public static var KFAttributes = KF.jsonToMap({
		position: "a_position",
		normal: "a_normal",
		color: "a_color",
		texCoord: "a_texCoord"
	});

	public static var KFUniforms = KF.jsonToMap({
		modelViewProjectionMatrix: "u_MVPMatrix",
		modelViewMatrix: "u_MVMatrix",
		modelMatrix: "u_modelMatrix",
		viewMatrix: "u_viewMatrix",
		normalMatrix: "u_normalMatrix"
	});

	public function new() {

	}
	
	public static function create(shaderName:String, vertexProgram:String, fragmentProgram:String):KFGLProgram {
		var program = new KFGLProgram();
		
		if (program != null && !(program.init(shaderName, vertexProgram, fragmentProgram))) {
			program = null;
		}

		return program;
	}

	public function init(shaderName:String, vertexProgram:String, fragmentProgram:String):Bool {
		_name = shaderName;

		// Load prefixes
		if (_prefixVertex == null) {
			_prefixVertex = Assets.getText("assets/shaders/prefix_vertex.glsl");
		}
		if (_prefixFragment == null) {
			_prefixFragment = Assets.getText("assets/shaders/prefix_fragment.glsl");
		}

		// TODO : take from materials
		var vertexDefines:String = "#define USE_COLOR\n";
		var fragmentDefines:String = "";

		// Add prefixes
		vertexProgram = vertexDefines + _prefixVertex + vertexProgram;
		fragmentProgram = fragmentDefines + _prefixFragment + fragmentProgram;

		// Create new program
		_program = GL.createProgram();

		if (_program == null) {
			KF.Log("Failed to create new GLProgram");
			return false;
		}

		// Create shaders
		var vertexShader = createShader(vertexProgram, GL.VERTEX_SHADER);
		var fragmentShader = createShader(fragmentProgram, GL.FRAGMENT_SHADER);
		
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
			KF.Log("Compiled and linked successfully program \"" + _name + "\"");
		}

		// Get attribute locations
		for (identifier in KFAttributes.keys()) {
			var attribute = GL.getAttribLocation(_program, KFAttributes.get(identifier));
			KF.Log("attribute " + identifier + " : " + KFAttributes.get(identifier) + " " + attribute);
			_attributes.set(identifier, attribute);
		}

		// Get uniform locations
		for (identifier in KFUniforms.keys()) {
			var uniform = GL.getUniformLocation(_program, KFUniforms.get(identifier));
			KF.Log("uniform " + identifier + " : " + KFUniforms.get(identifier) + " " + uniform);
			_uniforms.set(identifier, uniform);
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
			return null;
		}
		
		return shader;
	}

}