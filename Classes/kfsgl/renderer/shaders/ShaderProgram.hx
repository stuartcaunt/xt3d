package kfsgl.renderer.shaders;

import kfsgl.utils.gl.GLTextureManager;
import openfl.gl.GL;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.Assets;

import kfsgl.utils.KF;
import kfsgl.renderer.shaders.ShaderInfo;
import kfsgl.renderer.shaders.ShaderReader;
import kfsgl.renderer.shaders.Uniform;
import kfsgl.renderer.shaders.UniformLib;

typedef ProgramAttributeState = {
	var name:String;
	var location:Int;
	var used:Bool;
}


class ShaderProgram {

	// properties
	public var name(get, null):String;
	public var attributes(get, null):Map<String, ProgramAttributeState>;

	// members
	private static var ID_COUNTER = 0;
	private var _id:Int = ID_COUNTER++;
	private var _retainCount = 0;
	private var _name:String;
	private var _vertexProgram:String;
	private var _fragmentProgram:String;
	private var _program:GLProgram;
	private static var _prefixVertex:String = null;
	private static var _prefixFragment:String = null;

	private var _attributes:Map<String, ProgramAttributeState> = new Map<String, ProgramAttributeState>();
	private var _uniforms:Map<String, Uniform> = new Map<String, Uniform>();
	private var _commonUniforms:Map<String, Uniform> = new Map<String, Uniform>();
	private var _globalUniforms:Map<String, Uniform> = new Map<String, Uniform>();
	private var _updateGlobalUniforms:Bool = true;
	private var _availableTextureSlots:Array<Bool> = new Array<Bool>();
	private var _maxTextureSlots:Int;

	// These are as they appear in prefix_vertex.glsl
	public static var KFAttributes = KF.jsonToMap({
		position: "a_position",
		normal: "a_normal",
		color: "a_color",
		uv: "a_uv"
	});

	public function new() {

	}


	/* ----------- Properties ----------- */

	public inline function get_name():String {
		return this._name;
	}

	public inline function get_attributes():Map<String, ProgramAttributeState> {
		return this._attributes;
	}


/* --------- Implementation --------- */

	public static function create(shaderName:String, shaderInfo:ShaderInfo, precision:String, maxTextureSlots:Int):ShaderProgram {
		var program = new ShaderProgram();
		
		if (program != null && !(program.init(shaderName, shaderInfo, precision, maxTextureSlots))) {
			program = null;
		}

		return program;
	}

	public function init(shaderName:String, shaderInfo:ShaderInfo, precision:String, maxTextureSlots:Int):Bool {
		this._name = shaderName;

		this._maxTextureSlots = maxTextureSlots;
		for (i in 0 ... maxTextureSlots) {
			this._availableTextureSlots[i] = true;
		}

		var vertexProgram = shaderInfo.vertexProgram;
		var fragmentProgram = shaderInfo.fragmentProgram;
		var vertexDefines= shaderInfo.vertexDefines != null ? shaderInfo.vertexDefines.join('\n') : "";
		var fragmentDefines= shaderInfo.fragmentDefines != null ? shaderInfo.fragmentDefines.join('\n') : "";
		var uniforms = shaderInfo.uniforms;
		var commonUniforms = shaderInfo.commonUniforms;
		var attributes = shaderInfo.attributes;

		// Load prefixes
		if (_prefixVertex == null) {
			_prefixVertex = ShaderReader.instance().shaderWithKey("prefix_vertex");
		}
		if (_prefixFragment == null) {
			_prefixFragment = ShaderReader.instance().shaderWithKey("prefix_fragment");
		}

		// precision
		var precisionText = (precision == null) ? "" : "\n\nprecision " + precision + " float;";

		// generate attribute declarations
		var vertexAttributes:String = "";
		for (attributeName in attributes.keys()) {
			var attributeInfo = attributes.get(attributeName);
			vertexAttributes += "attribute " + attributeInfo.type + " " + attributeInfo.name + ";\n";
		}

		// Regroup common and program-specific uniforms
		var allVertexUniforms = new Map<String, UniformInfo>();
		var allFragmentUniforms = new Map<String, UniformInfo>();
		for (uniformName in uniforms.keys()) {
			var uniformInfo = uniforms.get(uniformName);
			if (uniformInfo.shader.indexOf("v") != -1) {
				allVertexUniforms.set(uniformName, uniformInfo);
			} else if (uniformInfo.shader.indexOf("v") != -1) {
				allFragmentUniforms.set(uniformName, uniformInfo);
			}
		}
		for (uniformName in commonUniforms.keys()) {
			var uniformInfo = commonUniforms.get(uniformName).uniformInfo();
			if (uniformInfo.shader.indexOf("v") != -1 && !allVertexUniforms.exists(uniformName)) {
				allVertexUniforms.set(uniformName, uniformInfo);
			} else if (uniformInfo.shader.indexOf("v") != -1 && !allFragmentUniforms.exists(uniformName)) {
				allFragmentUniforms.set(uniformName, uniformInfo);
			}
		}


		// generate uniform declarations
		var vertexUniforms:String = "";
		var fragmentUniforms:String = "";
		for (uniformName in allVertexUniforms.keys()) {
			var uniformInfo = allVertexUniforms.get(uniformName);
			vertexUniforms += "uniform " + Uniform.codeType(uniformInfo.type) + " " + uniformInfo.name + ";\n";
		}
		for (uniformName in allFragmentUniforms.keys()) {
			var uniformInfo = allFragmentUniforms.get(uniformName);
			fragmentUniforms += "uniform " + Uniform.codeType(uniformInfo.type) + " " + uniformInfo.name + ";\n";
		}

		// Add prefixes
		_vertexProgram = "// vertex shader: " + shaderName + precisionText + "\n\n// vertexDefines:\n" + vertexDefines + "\n" + _prefixVertex + "\n// extra vertex attributes:\n" + vertexAttributes + "\n// vertexUniforms:\n" + vertexUniforms + "\n// VertexProgram:\n" + vertexProgram;
		_fragmentProgram = "// fragment shader: " + shaderName + precisionText + "\n\n// fragmentDefines:\n" + fragmentDefines + "\n" + _prefixFragment + "\n// fragmentUniforms:\n" + fragmentUniforms + "\n// fragmentProgram:\n" + fragmentProgram;

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
			//KF.Log("Compiled and linked successfully program \"" + this._name + "\"");
			//KF.Log("Vertex program:\n" + _vertexProgram);
			//KF.Log("Fragment program:\n" + _fragmentProgram);
		}

		// Get attribute locations from common attributes
		for (identifier in KFAttributes.keys()) {
			var location = GL.getAttribLocation(_program, KFAttributes.get(identifier));
			//KF.Log("attribute " + identifier + " : " + KFAttributes.get(identifier) + " = " + location);
			_attributes.set(identifier, { name:identifier, location:location, used:false });
		}

		// Get attribute locations from user-defined attributes
		for (attributeIdentifier in attributes.keys()) {
			var attribute = attributes.get(attributeIdentifier);
			var location = GL.getAttribLocation(_program, attribute.name);
			_attributes.set(attributeIdentifier, { name:attributeIdentifier, location:location, used:false });
		}

		// Handle uniforms
		for (uniformName in uniforms.keys()) {
			var uniformInfo = uniforms.get(uniformName);
			var uniformLocation = GL.getUniformLocation(_program, uniformInfo.name);

			// Create uniform
			var uniform = this.createUniform(uniformName, uniformInfo);
			if (uniform == null) {
				return false;
			}

			// Add to all uniforms
			_uniforms.set(uniformName, uniform);
		}

		// Handle common uniforms
		for (uniformName in commonUniforms.keys()) {
			if (!_uniforms.exists(uniformName)) {
				var uniformInfo = commonUniforms.get(uniformName).uniformInfo();

				// Create uniform
				var uniform = this.createUniform(uniformName, uniformInfo);

				// Add to all uniforms
				_commonUniforms.set(uniformName, uniform);
				if (uniform == null) {
					return false;
				}

				// Add to global uniforms
				if (uniform.isGlobal) {
					_globalUniforms.set(uniformName, uniform);
				}
			} else {
				//KF.Log("Ignoring common uniform " + uniformName + " : overridden by shader uniform");
			}


		}

		return true;
	}


	public function dispose():Void {
		if (_program != null) {
			GL.deleteProgram(_program);
			_program = null;
		}
	}

	public function retain():Void {
		this._retainCount++;
	}

	public function release():Void {
		this._retainCount--;
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

	private function createUniform(uniformName:String, uniformInfo:UniformInfo):Uniform {
		var uniformLocation = GL.getUniformLocation(this._program, uniformInfo.name);

		// Create a uniform object
		var uniform:Uniform = Uniform.create(uniformName, uniformInfo, uniformLocation);

		// Handle texture slots
		if (uniform.type == "texture") {
			var textureSlot = uniform.textureSlot;
			if (textureSlot > 0) {
				if (!this._availableTextureSlots[textureSlot]) {
					KF.Error("ERROR: Uniform " + uniformName + " attempting to use unavailable texture slot " + textureSlot);
					return null;
				}
			} else {
				textureSlot = this.getNextAvailableTextureSlot();
				uniform.textureSlot = textureSlot;
			}

			if (textureSlot > this._maxTextureSlots) {
				KF.Error("ERROR: Maximum number of texture slots has been depassed for shader program " + this._name);
				return null;
			}

			// Mark slot as unavailable
			this._availableTextureSlots[textureSlot] = false;
		}

		return uniform;
	}


	private function getNextAvailableTextureSlot():Int {

		var nextSlot = 0;
		for (i in 0 ... this._availableTextureSlots.length) {
			if (this._availableTextureSlots[i]) {
				nextSlot = nextSlot < i ? nextSlot : i;
			}
		}

		return nextSlot;
	}

	public function use():Void {
		GL.useProgram(_program);
	}

	public function cloneUniforms():Map<String, Uniform> {
		var cloned:Map<String, Uniform> = new Map<String, Uniform>();
		for (uniform in _uniforms) {
			cloned.set(uniform.name, uniform.clone());
		}

		return cloned;
	}

	public function cloneCommonUniforms(cloneGlobals:Bool = false):Map<String, Uniform> {
		var cloned:Map<String, Uniform> = new Map<String, Uniform>();
		for (uniform in _commonUniforms) {
			// Clone non-global and global if forced
			if (!uniform.isGlobal || (uniform.isGlobal && cloneGlobals)) {
				cloned.set(uniform.name, uniform.clone());
			}
		}

		return cloned;
	}


	/**
	 * Update global uniforms from UniformLib
	 */
	public function updateGlobalUniforms(textureManager:GLTextureManager):Void {
		for (uniform in this._globalUniforms) {
			var globalUniform = UniformLib.instance().uniform(uniform.name);

			// Copy value to program
			uniform.copyFrom(globalUniform);

			// Write to GPU
			uniform.use(textureManager);
		}
	}

	/**
	 * Set/update a uniform value
	 */
	public function updateUniform(uniform:Uniform, textureManager:GLTextureManager):Void {
		if (this._uniforms.exists(uniform.name)) {
			var uniformToUpdate = this._uniforms.get(uniform.name);

			// Copy value to program
			uniformToUpdate.copyFrom(uniform);

			// Write to GPU
			uniformToUpdate.use(textureManager);

			// Prepare uniform for next render so we know if it has changed
			uniform.prepareForUse();

		} else {
			// Debugging... not really necessary
			KF.Log("Cannot update uniform " + uniform.name + " as it does not exist in the shader " + this._name);
		}
	}

	/**
	 * Set/update a common uniform value
	 */
	public function updateCommonUniform(uniform:Uniform, textureManager:GLTextureManager):Void {
		if (this._commonUniforms.exists(uniform.name)) {
			var uniformToUpdate = this._commonUniforms.get(uniform.name);

			// Copy value to program
			uniformToUpdate.copyFrom(uniform);

			// Write to GPU
			uniformToUpdate.use(textureManager);

			// Prepare uniform for next render so we know if it has changed
			uniform.prepareForUse();

		} else {
			// Debugging... not really necessary
			KF.Log("Cannot update common uniform " + uniform.name + " as it does not exist in the shader " + this._name);
		}
	}

}