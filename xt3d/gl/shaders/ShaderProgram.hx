package xt3d.gl.shaders;

import xt3d.utils.XTObject;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.Assets;

import xt3d.utils.XT;
import xt3d.gl.shaders.ShaderTypedefs;
import xt3d.gl.shaders.ShaderReader;
import xt3d.gl.shaders.Uniform;
import xt3d.gl.shaders.UniformLib;

typedef ProgramAttributeState = {
	var name:String;
	var location:Int;
	var used:Bool;
}


class ShaderProgram extends XTObject {

	// properties
	public var id(get, null):Int;
	public var name(get, null):String;
	public var attributes(get, null):Map<String, ProgramAttributeState>;

	// members
	private static var ID_COUNTER:Int = 0;
	private var _id:Int = ID_COUNTER++;
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
	private var _maxCombinedTextureSlots:Int;
	private var _maxFragmentTextures:Int;
	private var _maxVertexTextures:Int;
	private var _numberOfFragmentTextures:Int = 0;
	private var _numberOfVertexTextures:Int = 0;

	// These are as they appear in prefix_vertex.glsl
	public static var KFAttributes = XT.jsonToMap({
		position: "a_position",
		normal: "a_normal",
		tangent: "a_tangent",
		color: "a_color",
		uv: "a_uv"
	});

	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public function get_id():Int {
		return this._id;
	}

	public inline function get_name():String {
		return this._name;
	}

	public inline function get_attributes():Map<String, ProgramAttributeState> {
		return this._attributes;
	}


	/* --------- Implementation --------- */

	public static function create(shaderName:String, shaderInfo:ShaderInfo, precision:String, uniformLib:UniformLib, glInfo:GLInfo):ShaderProgram {
		var program = new ShaderProgram();
		
		if (program != null && !(program.init(shaderName, shaderInfo, precision, uniformLib, glInfo))) {
			program = null;
		}

		return program;
	}

	public function init(shaderName:String, shaderInfo:ShaderInfo, precision:String, uniformLib:UniformLib, glInfo:GLInfo):Bool {
		this._name = shaderName;

		this._maxCombinedTextureSlots = glInfo.maxCombinedTextureImageUnits;
		this._maxFragmentTextures = glInfo.maxTextureImageUnits;
		this._maxVertexTextures = glInfo.maxVertexTexturesImageUnits;

		for (i in 0 ... this._maxCombinedTextureSlots) {
			this._availableTextureSlots[i] = true;
		}

		// Get the source code for the shaders
		var vertexProgram = ShaderReader.instance().shaderWithKey(shaderInfo.vertexProgram);
		var fragmentProgram = ShaderReader.instance().shaderWithKey(shaderInfo.fragmentProgram);

		// Combine all includes
		var vertexProgramFragments = "";
		var fragmentProgramFragments = "";
		if (shaderInfo.vertexIncludes != null) {
			for (vertexInclude in shaderInfo.vertexIncludes) {
				vertexProgramFragments += "// " + vertexInclude + ":\n" + ShaderReader.instance().shaderWithKey(vertexInclude) + "\n";
			}
		}
		if (shaderInfo.fragmentIncludes != null) {
			for (fragmentInclude in shaderInfo.fragmentIncludes) {
				fragmentProgramFragments += "// " + fragmentInclude + ":\n" + ShaderReader.instance().shaderWithKey(fragmentInclude) + "\n";
			}
		}

		// precision
		var precisionText = (precision == null) ? "" : "\n\nprecision " + precision + " float;";

		var vertexDefines = shaderInfo.vertexDefines != null ? shaderInfo.vertexDefines.copy() : new Array<String>();
		var fragmentDefines = shaderInfo.fragmentDefines != null ? shaderInfo.fragmentDefines.copy() : new Array<String>();
		var dataTypes = new Map<String, Array<BaseTypeInfo>>();
		if (shaderInfo.types != null) {
			for (typeName in shaderInfo.types.keys()) {
				var clonedTypeDef = new Array<BaseTypeInfo>();
				dataTypes.set(typeName, clonedTypeDef);

				var typeDefinition = shaderInfo.types.get(typeName);
				for (baseType in typeDefinition) {
					clonedTypeDef.push(ShaderUtils.cloneBaseTypeInfo(baseType));
				}
			}
		}

		var uniforms = shaderInfo.uniforms;
		var commonUniformGroups = shaderInfo.commonUniformGroups;
		var attributes = shaderInfo.attributes;

		// Load prefixes
		if (_prefixVertex == null) {
			_prefixVertex = ShaderReader.instance().shaderWithKey("prefix_vertex");
		}
		if (_prefixFragment == null) {
			_prefixFragment = ShaderReader.instance().shaderWithKey("prefix_fragment");
		}

		// generate attribute declarations
		var vertexAttributes:String = "";
		if (attributes != null) {
			for (attributeName in attributes.keys()) {
				var attributeInfo = attributes.get(attributeName);
				vertexAttributes += "attribute " + attributeInfo.type + " " + attributeInfo.name + ";\n";
			}
		}

		// Convert common uniform groups into uniforms
		var commonUniformGroupInfo = uniformLib.uniformGroupInfoForGroups(commonUniformGroups);

		// Separate vertex from fragment uniforms
		var allVertexUniforms = new Map<String, UniformInfo>();
		var allFragmentUniforms = new Map<String, UniformInfo>();
		if (uniforms != null) {
			for (uniformName in uniforms.keys()) {
				var uniformInfo = uniforms.get(uniformName);
				if (uniformInfo.shader.indexOf("v") != -1) {
					allVertexUniforms.set(uniformName, uniformInfo);
				}
				if (uniformInfo.shader.indexOf("f") != -1) {
					allFragmentUniforms.set(uniformName, uniformInfo);
				}
			}
		}

		// Add information from common (and sometimes global) uniform infos into shader strucutre

		// Defines
		vertexDefines = vertexDefines.concat(commonUniformGroupInfo.vertexDefines);
		fragmentDefines = fragmentDefines.concat(commonUniformGroupInfo.fragmentDefines);

		// Types
		for (typeName in commonUniformGroupInfo.types.keys()) {
			var clonedTypeDef = new Array<BaseTypeInfo>();
			dataTypes.set(typeName, clonedTypeDef);

			var typeDefinition = commonUniformGroupInfo.types.get(typeName);

			for (baseType in typeDefinition) {
				clonedTypeDef.push(ShaderUtils.cloneBaseTypeInfo(baseType));
			}
		}

		// Uniforms: add uniform infos to vertex/fragment groups
		for (uniformName in commonUniformGroupInfo.uniforms.keys()) {
			var uniformInfo = commonUniformGroupInfo.uniforms.get(uniformName);

			if (uniformInfo.shader.indexOf("v") != -1 && !allVertexUniforms.exists(uniformName)) {
				allVertexUniforms.set(uniformName, uniformInfo);
			}
			if (uniformInfo.shader.indexOf("f") != -1 && !allFragmentUniforms.exists(uniformName)) {
				allFragmentUniforms.set(uniformName, uniformInfo);
			}
		}


		// build types map
		var formattedDataTypes:Map<String, String> = ShaderUtils.buildShaderTypesText(dataTypes);


		// Determine types that need to be inserted into vertex and fragment shaders
		var vertexTypes = new Map<String, String>();
		for (uniformInfo in allVertexUniforms) {
			var type = ShaderUtils.uniformType(uniformInfo);
			if (formattedDataTypes.exists(type) && !vertexTypes.exists(type)) {
				vertexTypes.set(type, formattedDataTypes.get(type));
			}
		}
		var vertexTypesString:String = "";
		for (typeDefinition in vertexTypes) {
			vertexTypesString += typeDefinition + "\n\n";
		}

		var fragmentTypes = new Map<String, String>();
		for (uniformInfo in allFragmentUniforms) {
			var type = ShaderUtils.uniformType(uniformInfo);
			if (formattedDataTypes.exists(type) && !fragmentTypes.exists(type)) {
				fragmentTypes.set(type, formattedDataTypes.get(type));
			}
		}
		var fragmentTypesString:String = "";
		for (typeDefinition in fragmentTypes) {
			fragmentTypesString += typeDefinition + "\n\n";
		}

		// generate uniform declarations
		var vertexUniformsString:String = "";
		var fragmentUniformsString:String = "";
		for (uniformName in allVertexUniforms.keys()) {
			var uniformInfo = allVertexUniforms.get(uniformName);
			vertexUniformsString += ShaderUtils.buildUniformDeclaration(uniformInfo);
		}
		for (uniformName in allFragmentUniforms.keys()) {
			var uniformInfo = allFragmentUniforms.get(uniformName);
			fragmentUniformsString += ShaderUtils.buildUniformDeclaration(uniformInfo);
		}

		var vertexDefinesString = vertexDefines.join("\n");
		var fragmentDefinesString = fragmentDefines.join("\n");

		// Add prefixes
		_vertexProgram = "// vertex shader: " + shaderName +
			precisionText +
			"\n\n// vertexDefines:\n" + vertexDefinesString +
			"\n\n// vertexTypes:\n" + vertexTypesString +
			_prefixVertex +
			"\n// extra vertex attributes:\n" + vertexAttributes +
			"\n// vertexUniforms:\n" + vertexUniformsString +
			vertexProgramFragments +
			"\n// VertexProgram:\n" + vertexProgram;
		_fragmentProgram = "// fragment shader: " + shaderName +
			precisionText +
			"\n\n// fragmentDefines:\n" + fragmentDefinesString +
			"\n\n// fragmentTypes:\n" + fragmentTypesString +
			_prefixFragment +
			"\n\n// fragmentUniforms:\n" + fragmentUniformsString +
			fragmentProgramFragments +
			"\n// fragmentProgram:\n" + fragmentProgram;

		// Create new program
		_program = GL.createProgram();

		if (_program == null) {
			XT.Log("Failed to create new GLProgram");
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
			XT.Log("ERROR: unable to link program:");
			XT.Log(GL.getProgramInfoLog(_program));
			XT.Log("VALIDATE_STATUS: " + GL.getProgramParameter(_program, GL.VALIDATE_STATUS));
			XT.Log("ERROR: " + GL.getError());

			return false;

		} else {
//			XT.Log("Compiled and linked successfully program \"" + this._name + "\"");
//			XT.Log("Vertex program:\n" + _vertexProgram);
//			XT.Log("Fragment program:\n" + _fragmentProgram);
		}

		// Get attribute locations from common attributes
		for (identifier in KFAttributes.keys()) {
			var location = GL.getAttribLocation(_program, KFAttributes.get(identifier));
			//XT.Log("attribute " + identifier + " : " + KFAttributes.get(identifier) + " = " + location);
			_attributes.set(identifier, { name:identifier, location:location, used:false });
		}

		// Get attribute locations from user-defined attributes
		if (attributes != null) {
			for (attributeIdentifier in attributes.keys()) {
				var attribute = attributes.get(attributeIdentifier);
				var location = GL.getAttribLocation(_program, attribute.name);
				_attributes.set(attributeIdentifier, { name:attributeIdentifier, location:location, used:false });
			}
		}

		// Handle uniforms
		if  (uniforms != null) {
			for (uniformName in uniforms.keys()) {
				var uniformInfo = uniforms.get(uniformName);

				// Create uniform
				var uniform = this.createUniform(uniformName, uniformInfo, dataTypes);
				if (uniform == null) {
					return false;
				}

				// Add to all uniforms
				_uniforms.set(uniformName, uniform);
			}
		}

		// Handle common uniforms
		for (uniformName in commonUniformGroupInfo.uniforms.keys()) {
			if (!_uniforms.exists(uniformName)) {
				var uniformInfo = commonUniformGroupInfo.uniforms.get(uniformName);

				// Create uniform
				var uniform = this.createUniform(uniformName, uniformInfo, dataTypes);

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
				//XT.Log("Ignoring common uniform " + uniformName + " : overridden by shader uniform");
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

	private function createShader(source:String, type:Int):GLShader {
		// Create new shader
		var shader = GL.createShader(type);
		if (shader == null) {
			XT.Log("ERROR: Failed to create new GLShader");
			return null;
		}

		// attach and compile shader
		GL.shaderSource(shader, source);
		GL.compileShader(shader);
		
		// Verify that shader comiled
		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0) {
			XT.Log("ERROR compiling " + (type == GL.VERTEX_SHADER ? "vertex" : "fragment") + " shader: " + GL.getShaderInfoLog(shader));
			if (type == GL.VERTEX_SHADER) {
				XT.Log("Vertex program:\n" + _vertexProgram);
			} else {

				XT.Log("Fragment program:\n" + _fragmentProgram);
			}
			return null;
		}
		
		return shader;
	}

	private function createUniform(uniformName:String, uniformInfo:UniformInfo, shaderTypes:Map<String, Array<BaseTypeInfo>>):Uniform {

		var isVertexShader = uniformInfo.shader.indexOf("v") != -1;
		var isFragmentShader = uniformInfo.shader.indexOf("f") != -1;

		var uniform:Uniform = null;
		var isArray = ShaderUtils.uniformIsArray(uniformInfo);
		if (isArray && uniformInfo.type == "texture") {
			// TODO handle array of textures

		} else {
			// Create a uniform object
			uniform = Uniform.createForProgram(uniformName, uniformInfo, this._program, shaderTypes);

			// Handle texture slots
			if (uniform.type == "texture") {
				var textureSlot = uniform.textureSlot;
				if (textureSlot >= 0) {
					if (!this._availableTextureSlots[textureSlot]) {
						XT.Error("ERROR: Uniform " + uniformName + " attempting to use unavailable texture slot " + textureSlot);
						return null;
					}
				} else {
					textureSlot = this.getNextAvailableTextureSlot();
					uniform.textureSlot = textureSlot;
				}

				this._numberOfFragmentTextures += isFragmentShader ? 1 : 0;
				this._numberOfVertexTextures += isVertexShader ? 1 : 0;

				if (this._numberOfFragmentTextures > this._maxFragmentTextures) {
					XT.Error("ERROR: Program " + this._name + " attempting to use too many textures in fragment shader (" + this._maxFragmentTextures + ")");
					return null;

				} else if (this._numberOfVertexTextures > this._maxVertexTextures) {
					XT.Error("ERROR: Program " + this._name + " attempting to use too many textures in vertex shader (" + this._maxVertexTextures + ")");
					return null;
				}

				// Set the default slot for the texture in case slot is overriden by user value
				uniform.setDefaultTextureSlot(textureSlot);

				if (textureSlot > this._maxCombinedTextureSlots) {
					XT.Error("ERROR: Maximum number of texture slots has been depassed for shader program " + this._name);
					return null;
				}

				// Mark slot as unavailable
				this._availableTextureSlots[textureSlot] = false;
			}
		}

		return uniform;
	}


	private function getNextAvailableTextureSlot():Int {

		for (i in 0 ... this._availableTextureSlots.length) {
			if (this._availableTextureSlots[i]) {
				return i;
			}
		}

		return this._availableTextureSlots.length;
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
	public function updateGlobalUniforms(uniformLib:UniformLib):Void {
		for (uniform in this._globalUniforms) {
			var globalUniform = uniformLib.uniform(uniform.name);

			// Copy value to program
			uniform.copyFrom(globalUniform);

			// Write to GPU
			uniform.use();
		}
	}

	/**
	 * Set/update a uniform value
	 */
	public function updateUniform(uniform:Uniform):Void {
		if (this._uniforms.exists(uniform.name)) {
			var uniformToUpdate = this._uniforms.get(uniform.name);

			// Copy value to program
			uniformToUpdate.copyFrom(uniform);

			// Write to GPU
			uniformToUpdate.use();

			// Prepare uniform for next render so we know if it has changed
			uniform.prepareForUse();

		} else {
			// Debugging... not really necessary
			XT.Log("Cannot update uniform " + uniform.name + " as it does not exist in the shader " + this._name);
		}
	}

	/**
	 * Set/update a common uniform value
	 */
	public function updateCommonUniform(uniform:Uniform):Void {
		if (this._commonUniforms.exists(uniform.name)) {
			var uniformToUpdate = this._commonUniforms.get(uniform.name);

			// Copy value to program
			uniformToUpdate.copyFrom(uniform);

			// Write to GPU
			uniformToUpdate.use();

			// Prepare uniform for next render so we know if it has changed
			uniform.prepareForUse();

		} else {
			// Debugging... not really necessary
			XT.Log("Cannot update common uniform " + uniform.name + " as it does not exist in the shader " + this._name);
		}
	}

}