package xt3d.gl.shaders;

import xt3d.math.MatrixHelper;
import xt3d.gl.GLTextureManager;
import xt3d.textures.Texture2D;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GL;
import haxe.Json;
import xt3d.math.Matrix4;
import xt3d.core.Director;

import xt3d.utils.XT;
import xt3d.utils.errors.XTException;
import xt3d.gl.shaders.ShaderTypedefs;

class Uniform  {

	// properties
	public var name(get, null):String;
	public var type(get, null):String;
	public var boolValue(get, set):Bool;
	public var floatValue(get, set):Float;
	public var intValue(get, set):Int;
	public var floatArrayValue(get, set):Array<Float>;
	public var intArrayValue(get, set):Array<Int>;
	public var matrixValue(get, set):Matrix4;
	public var texture(get, set):Texture2D;
	public var textureSlot(get, set):Int;
	public var isGlobal(get, null):Bool;
	public var hasBeenSet(get, null):Bool;
	public var uniformInfo(get, null):UniformInfo;

	// members
	private var _name:String;
	private var _type:String;
	private var _uniformInfo:UniformInfo;
	private var _location:GLUniformLocation;
	private var _isGlobal:Bool = false;
	private var _size:Int;

	private var _boolValue:Bool = false;
	private var _floatValue:Float = 0.0;
	private var _intValue:Int = 0;
	private var _floatArrayValue:Array<Float> = new Array<Float>();
	private var _intArrayValue:Array<Int> = new Array<Int>();
	private var _float32ArrayValue:Float32Array;
	private var _int32ArrayValue:Int32Array;
	private var _matrixValue:Matrix4 = new Matrix4();
	private var _texture:Texture2D = null;
	private var _textureSlot:Int = -1;

	private var _defaultBoolValue:Bool = false;
	private var _defaultFloatValue:Float = 0.0;
	private var _defaultIntValue:Int = 0;
	private var _defaultFloatArrayValue:Array<Float> = null;
	private var _defaultIntArrayValue:Array<Int> = null;
	private var _defaultMatrixValue:Matrix4 = new Matrix4();
	private var _defaultTexture:Texture2D = null;
	private var _defaultTextureSlot:Int = -1;

	private var _hasBeenSet:Bool = false;
	private var _isDirty:Bool = true;

	private var _uniformArray:Array<Uniform> = null;
	private var _uniformStruct:Map<String, Uniform> = null;
	private var _dataTypes:Map<String, Array<BaseTypeInfo>> = null;

	public static function createWithLocation(name:String, uniformInfo:UniformInfo, location:GLUniformLocation):Uniform {
		var object = new Uniform();

		if (object != null && !(object.initWithLocation(name, uniformInfo, location))) {
			object = null;
		}

		return object;
	}

	public static function createForProgram(name:String, uniformInfo:UniformInfo, program:GLProgram, dataTypes:Map<String, Array<BaseTypeInfo>>):Uniform {
		var object = new Uniform();

		if (object != null && !(object.initForProgram(name, uniformInfo, program, dataTypes))) {
			object = null;
		}

		return object;
	}


	public static function createEmpty(name:String, uniformInfo:UniformInfo, dataTypes:Map<String, Array<BaseTypeInfo>>):Uniform {
		var object = new Uniform();

		if (object != null && !(object.initEmpty(name, uniformInfo, dataTypes))) {
			object = null;
		}

		return object;

	}

	public function initWithLocation(name:String, uniformInfo:UniformInfo, location:GLUniformLocation):Bool {
		this._name = name;
		this._type = uniformInfo.type;
		this._uniformInfo = uniformInfo;
		this._location = location;
		this._isGlobal = uniformInfo.global;

		handleDefaultValue();

		return true;
	}

	public function initForProgram(name:String, uniformInfo:UniformInfo, program:GLProgram, dataTypes:Map<String, Array<BaseTypeInfo>>):Bool {
		this._name = name;
		this._type = uniformInfo.type;
		this._uniformInfo = uniformInfo;
		this._isGlobal = uniformInfo.global;
		this._dataTypes = dataTypes;

		if (ShaderUtils.uniformIsArray(uniformInfo)) {
			// Uniform array
			this._uniformArray = new Array<Uniform>();

			// Create uniform for each array element
			var uniformArraySize = ShaderUtils.uniformArraySize(uniformInfo);
			for (i in 0 ... uniformArraySize) {
				// New uniform info for each element
				var arrayElementUniformInfo = ShaderUtils.uniformInfoForArrayIndex(uniformInfo, i);
				var arrayElementUniformName = ShaderUtils.uniformNameForArrayIndex(this._name, i);

				var uniform = Uniform.createForProgram(arrayElementUniformName, arrayElementUniformInfo, program, dataTypes);
				this._uniformArray.push(uniform);
			}

		} else if (ShaderUtils.uniformIsCustomType(uniformInfo)) {
			var uniformType = ShaderUtils.uniformType(uniformInfo);
			if (dataTypes.exists(uniformType)) {
				// Uniform struct
				this._uniformStruct = new Map<String, Uniform>();

				// Create uniform for each struct member
				var typeDefinition = dataTypes.get(uniformType);
				for (member in typeDefinition) {
					// New uniform info for each member
					var structUniformInfo = ShaderUtils.uniformInfoForTypeMember(uniformInfo, member);
					var structUniformName = ShaderUtils.uniformNameForTypeMember(this._name, member);

					var uniform = Uniform.createForProgram(structUniformName, structUniformInfo, program, dataTypes);
					this._uniformStruct.set(member.name, uniform);
				}

			} else {
				XT.Warn("Unknown data type \"" + uniformType + "\" for uniform \"" + this._name + "\"");
				return false;
			}
		} else {
			// Standard uniform
			this._location = GL.getUniformLocation(program, uniformInfo.name);

			handleDefaultValue();
		}


		return true;
	}


	public function initEmpty(name:String, uniformInfo:UniformInfo, dataTypes:Map<String, Array<BaseTypeInfo>>):Bool {
		this._name = name;
		this._type = uniformInfo.type;
		this._uniformInfo = uniformInfo;
		this._isGlobal = uniformInfo.global;
		this._dataTypes = dataTypes;


		var uniformType = ShaderUtils.uniformType(uniformInfo);
		if (ShaderUtils.uniformIsArray(uniformInfo)) {
			// Uniform array
			this._uniformArray = new Array<Uniform>();

			// Create uniform for each array element
			var uniformArraySize = ShaderUtils.uniformArraySize(uniformInfo);
			for (i in 0 ... uniformArraySize) {
				// New uniform info for each element
				var arrayElementUniformInfo = ShaderUtils.uniformInfoForArrayIndex(uniformInfo, i);
				var arrayElementUniformName = ShaderUtils.uniformNameForArrayIndex(this._name, i);

				var uniform = Uniform.createEmpty(arrayElementUniformName, arrayElementUniformInfo, dataTypes);
				this._uniformArray.push(uniform);
			}

		} else if (ShaderUtils.uniformIsCustomType(uniformInfo)) {
			if (dataTypes.exists(uniformType)) {
				// Uniform struct
				this._uniformStruct = new Map<String, Uniform>();

				// Create uniform for each struct member
				var typeDefinition = dataTypes.get(uniformType);
				for (member in typeDefinition) {
					// New uniform info for each member
					var structUniformInfo = ShaderUtils.uniformInfoForTypeMember(uniformInfo, member);
					var structUniformName = ShaderUtils.uniformNameForTypeMember(this._name, member);

					var uniform = Uniform.createEmpty(structUniformName, structUniformInfo, dataTypes);
					this._uniformStruct.set(member.name, uniform);
				}

			} else {
				XT.Warn("Unknown data type \"" + uniformType + "\" for uniform \"" + this._name + "\"");
				return false;
			}

		} else {
			handleDefaultValue();
		}

		return true;
	}

	public function new() {
	}

	/* ----------- Properties ----------- */


	public inline function get_name():String {
		return this._name;
	}

	public inline function get_type():String {
		return this._type;
	}

	public inline function get_boolValue():Bool {
		return this._boolValue;
	}

	public function set_boolValue(value:Bool) {
		this.setBoolValue(value);
		return this._boolValue;
	}

	public inline function get_floatValue():Float {
		return this._floatValue;
	}

	public function set_floatValue(value:Float) {
		this.setFloatValue(value);
		return this._floatValue;
	}

	public inline function get_intValue():Int {
		return this._intValue;
	}

	public function set_intValue(value:Int) {
		this.setIntValue(value);
		return this._intValue;
	}

	public inline function get_floatArrayValue():Array<Float> {
		return this._floatArrayValue;
	}

	public function set_floatArrayValue(value:Array<Float>) {
		setFloatArrayValue(value);
		return this._floatArrayValue;
	}

	public inline function get_intArrayValue():Array<Int> {
		return this._intArrayValue;
	}

	public function set_intArrayValue(value:Array<Int>) {
		setIntArrayValue(value);
		return this._intArrayValue;
	}

	public inline function get_matrixValue():Matrix4 {
		return this._matrixValue;
	}

	public function set_matrixValue(value:Matrix4) {
		setMatrixValue(value);
		return this._matrixValue;
	}

	public function get_texture():Texture2D {
		return this._texture;
	}

	public function set_texture(value:Texture2D) {
		this.setTexture(value);
		return this._texture;
	}

	public function get_textureSlot():Int {
		return this._textureSlot;
	}

	public function set_textureSlot(value:Int) {
		this.setTextureSlot(value);
		return this._textureSlot;
	}

	public inline function get_isGlobal():Bool{
		return this._isGlobal;
	}

	public inline function get_hasBeenSet():Bool{
		return this._hasBeenSet;
	}

	public inline function get_uniformInfo():UniformInfo {
		return this._uniformInfo;
	}



/* --------- Implementation --------- */

	public inline function at(index:Int):Uniform {
		if (this._uniformArray != null) {
			return this._uniformArray[index];

		} else {
			throw new XTException("UniformNotArray", "Uniform " + this._uniformInfo.name + " is not an array");
		}
	}

	public inline function get(typeElementName:String):Uniform {
		if (this._uniformStruct != null) {
			return this._uniformStruct.get(typeElementName);

		} else {
			throw new XTException("UniformNotStruct", "Uniform " + this._uniformInfo.name + " is not a struct");
		}
	}

	public function clone():Uniform {
		if (this._uniformArray != null) {
			var clone:Uniform = Uniform.createEmpty(this._name, this._uniformInfo, this._dataTypes);
			clone._uniformArray = new Array<Uniform>();
			for (uniform in this._uniformArray) {
				clone._uniformArray.push(uniform.clone());
			}
			return clone;

		} else if (this._uniformStruct != null) {
			var clone:Uniform = Uniform.createEmpty(this._name, this._uniformInfo, this._dataTypes);
			clone._uniformStruct = new Map<String, Uniform>();
			for (memberName in this._uniformStruct.keys()) {
				var uniform = this._uniformStruct.get(memberName);
				clone._uniformStruct.set(memberName, uniform.clone());
			}
			return clone;

		} else {

			return Uniform.createWithLocation(this._name, this._uniformInfo, this._location);
		}
	}


	public inline function prepareForUse() {
		if (this._uniformArray != null) {
			for (uniform in this._uniformArray) {
				uniform.prepareForUse();
			}

		} else if (this._uniformStruct != null) {
			for (uniform in this._uniformStruct) {
				uniform.prepareForUse();
			}

		} else {
			_hasBeenSet = false;
		}
	}

	public function use() {
		if (this._uniformArray != null) {
			for (uniform in this._uniformArray) {
				uniform.use();
			}

		} else if (this._uniformStruct != null) {
			for (uniform in this._uniformStruct) {
				uniform.use();
			}

		} else {
			var type = this._type;

			// Send value to the GPU if it is dirty
			if (_isDirty) {
				//XT.Log("Setting uniform " + this._name);
				if (type == "float") {
					GL.uniform1f(this._location, this._floatValue);

				} else if (type == "int") {
					GL.uniform1i(this._location, this._intValue);

				} else if (type == "bool") {
					GL.uniform1i(this._location, this._boolValue ? 1 : 0);

				} else if (type == "texture") {
					GL.uniform1i(this._location, this._textureSlot);

				} else if (type == "vec2") {
					#if js
					this.copyToTypedFloatArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					var count = Std.int(this._float32ArrayValue.length / 2);
					GL.uniform2fv(this._location, count, this._float32ArrayValue);

				} else if (type == "vec3") {
					#if js
					this.copyToTypedFloatArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					var count = Std.int(this._float32ArrayValue.length / 3);
					GL.uniform3fv(this._location, count, this._float32ArrayValue);

				} else if (type == "vec4") {
					#if js
					this.copyToTypedFloatArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					var count = Std.int(this._float32ArrayValue.length / 4);
					GL.uniform4fv(this._location, count, this._float32ArrayValue);

				} else if (type == "ivec2") {
					#if js
					this.copyToTypedIntArray(this._intArrayValue, this._int32ArrayValue);
					#else
					this._int32ArrayValue.set(this._intArrayValue);
					#end
					var count = Std.int(this._int32ArrayValue.length / 2);
					GL.uniform2iv(this._location, count, this._int32ArrayValue);

				} else if (type == "ivec3") {
					#if js
					this.copyToTypedIntArray(this._intArrayValue, this._int32ArrayValue);
					#else
					this._int32ArrayValue.set(this._intArrayValue);
					#end
					var count = Std.int(this._int32ArrayValue.length / 3);
					GL.uniform3iv(this._location, count, this._int32ArrayValue);

				} else if (type == "ivec4") {
					#if js
					this.copyToTypedIntArray(this._intArrayValue, this._int32ArrayValue);
					#else
					this._int32ArrayValue.set(this._intArrayValue);
					#end
					var count = Std.int(this._int32ArrayValue.length / 4);
					GL.uniform4iv(this._location, count , this._int32ArrayValue);

				} else if (type == "mat3") {
					MatrixHelper.copy3x3ToArray(this._matrixValue, this._floatArrayValue);
					#if js
					this.copyToTypedFloatArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					var count = Std.int(this._float32ArrayValue.length / 9);	// Matrix of 3x3
					GL.uniformMatrix3fv(this._location, count, false, this._float32ArrayValue);

				} else if (type == "mat4") {
					this._float32ArrayValue.set(this._matrixValue);
					var count = Std.int(this._float32ArrayValue.length / 16);	// Matrix of 4x4
					GL.uniformMatrix4fv(this._location, count, false, this._float32ArrayValue);
				}

				_isDirty = false;
			}

			// Bind texture
			if (type == 'texture') {
				var renderer = Director.current.renderer;
				var textureManager = renderer.textureManager;
				textureManager.setTexture(this._texture, this._textureSlot);
			}

		}
	}

	private inline function copyToTypedFloatArray(input:Array<Float>, out:Float32Array):Void {
		var length = input.length;
		for (i in 0 ... length) {
			out[i] = input[i];
		}
	}

	private inline function copyToTypedIntArray(input:Array<Int>, out:Int32Array):Void {
		var length = input.length;
		for (i in 0 ... length) {
			out[i] = input[i];
		}
	}

	public function copyFrom(uniform:Uniform):Void {
		if (this._uniformArray != null) {
			for (i in 0 ... this._uniformArray.length) {
				this._uniformArray[i].copyFrom(uniform.at(i));
			}

		} else if (this._uniformStruct != null) {
			for (memberName in this._uniformStruct.keys()) {
				this._uniformStruct.get(memberName).copyFrom(uniform.get(memberName));
			}

		} else {

			if (uniform.type != this._type) {
				throw new XTException("IncompatibleUniforms", "Cannot copy uniform values from different unfiform type");
			}
			if (this._type == "float") {
				this.setFloatValue(uniform.floatValue);

			} else if (this._type == "int") {
				this.setIntValue(uniform.intValue);

			} else if (this._type == "bool") {
				this.setBoolValue(uniform.boolValue);

			} else if (this._type == "vec2" || this.type == "vec3" || this.type == "vec4") {
				if (uniform.floatArrayValue != null && uniform.floatArrayValue.length > 0) {
					this.setFloatArrayValue(uniform.floatArrayValue);
				}

			} else if (this._type == "ivec2" || this.type == "ivec3" || this.type == "ivec4") {
				if (uniform.intArrayValue != null && uniform.intArrayValue.length > 0) {
					this.setIntArrayValue(uniform.intArrayValue);
				}

			} else if (this._type == "mat3" || this._type == "mat4") {
				this.setMatrixValue(uniform.matrixValue);

			} else if (this._type == "texture") {
				this.setTexture(uniform.texture);

				// Override program-specified texture slot _only_ if set by the user (default value changed)
				var textureSlot = (uniform.textureSlot != -1) ? uniform.textureSlot :this._defaultTextureSlot;
				this.setTextureSlot(textureSlot);
				//XT.Log(this._textureSlot);
			}
		}
	}


	public function setFloatValue(value:Float) {
		if (this._size != 1) {
			throw new XTException("IncoherentUniformValue", "A float value is being set for the uniform array " + _uniformInfo.name);

		} else if (this._type != "float") {
			throw new XTException("IncoherentUniformValue", "A float value is being set for a " + this._type + " uniform " + _uniformInfo.name);

		} else {
			_hasBeenSet = true;

			if (_floatValue != value) {
				_floatValue = value;
				_isDirty = true;
			}
		}
	}

	public function setIntValue(value:Int) {
		if (this._size != 1) {
			throw new XTException("IncoherentUniformValue", "An int value is being set for the uniform array " + _uniformInfo.name);

		} else if (this._type != "int") {
			throw new XTException("IncoherentUniformValue", "An int value is being set for a " + this._type + " uniform " + _uniformInfo.name);

		} else {
			_hasBeenSet = true;

			if (_intValue != value) {
				_intValue = value;
				_isDirty = true;
			}
		}
	}

	public function setBoolValue(value:Bool) {
		if (this._size != 1) {
			throw new XTException("IncoherentUniformValue", "A bool value is being set for the uniform array " + _uniformInfo.name);

		} else if (this._type != "bool") {
			throw new XTException("IncoherentUniformValue", "A bool value is being set for a " + this._type + " uniform " + _uniformInfo.name);

		} else {
			_hasBeenSet = true;

			if (_boolValue != value) {
				_boolValue = value;
				_isDirty = true;
			}
		}
	}

	public function setFloatArrayValue(value:Array<Float>) {
		if (value != null) {
			if (this._size == 1 || this._size == 16 || this._size == 16) {
				throw new XTException("IncoherentUniformValue", "A float or matrix value is being set for the array uniform " + _uniformInfo.name);

			} else if (_size != value.length) {
				throw new XTException("IncoherentUniformValue", "An array of size " + value.length + " is being set for the uniform array " + _uniformInfo.name + " with size " + _size);

			} else if (this._type != "vec2" && this._type != "vec3" && this._type != "vec4") {
				throw new XTException("IncoherentUniformValue", "A non float vector value is being set for a " + this._type + " uniform " + _uniformInfo.name);

			} else {
				this._hasBeenSet = true;

				// Comparison of both arrays
				var hasChanged = false;
				var i = 0;
				while (!hasChanged && i < value.length) {
					hasChanged = (value[i] != this._floatArrayValue[i]);
					i++;
				}

				if (hasChanged) {
					// Copy array values
					this._floatArrayValue = value.copy();
					this._isDirty = true;
				}

			}
		}
	}

	public function setIntArrayValue(value:Array<Int>) {
		if (value != null) {
			if (this._size == 1 || this._size == 16 || this._size == 16) {
				throw new XTException("IncoherentUniformValue", "A float or matrix value is being set for the array uniform " + _uniformInfo.name);

			} else if (_size != value.length) {
				throw new XTException("IncoherentUniformValue", "An array of size " + value.length + " is being set for the uniform array " + _uniformInfo.name + " with size " + _size);

			} else if (this._type != "ivec2" && this._type != "ivec3" && this._type != "ivec4") {
				throw new XTException("IncoherentUniformValue", "A non int vector value is being set for a " + this._type + " uniform " + _uniformInfo.name);

			} else {
				this._hasBeenSet = true;

				// Comparison of both arrays
				var hasChanged = false;
				var i = 0;
				while (!hasChanged && i < value.length) {
					hasChanged = (value[i] != this._intArrayValue[i]);
					i++;
				}

				if (hasChanged) {
					// Copy array values
					this._intArrayValue = value.copy();
					this._isDirty = true;
				}

			}
		}
	}

	public function setMatrixValue(value:Matrix4) {
		if (value != null) {
			this._hasBeenSet = true;

			// Comparison of both matrices
			var hasChanged = false;
			var i = 0;
			while (!hasChanged && i < 16) {
				hasChanged = (value[i] != this._matrixValue[i]);
				i++;
			}

			if (hasChanged) {
				// Copy matrix values
				this._matrixValue.copyFrom(value);
				this._isDirty = true;
			}
		}
	}

	public inline function setTexture(value:Texture2D) {
		if (this._texture != value) {
			this._texture = value;
		}
	}

	public function setTextureSlot(value:Int) {
		if (this._type != "texture") {
			throw new XTException("IncoherentUniformValue", "A texture slot is being set for a non-texture uniform");
		} else {
			_hasBeenSet = true;

			if (_textureSlot != value) {
				_textureSlot = value;
				_isDirty = true;
			}

		}
	}

	public inline function setDefaultTextureSlot(value:Int) {
		_defaultTextureSlot = value;
	}

	public function handleDefaultValue():Void {
		var defaultValue = this._uniformInfo.defaultValue;
		if (this._type == "texture") {
			defaultValue = this._uniformInfo.slot;
		}
		var type = this._uniformInfo.type;

		if (type == "float") {
			this._size = 1;
			if (defaultValue != null) {
				var floatValue:Float = Std.parseFloat(defaultValue);
				if (Math.isNaN(floatValue)) {
					throw new XTException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

				} else {
					this._defaultFloatValue = floatValue;
				}
			}
			setFloatValue(this._defaultFloatValue);

		} else if (type == "int") {
			if (defaultValue != null) {
				var intValue:Int = Std.parseInt(defaultValue);
				if (Math.isNaN(intValue)) {
					throw new XTException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

				} else {
					this._defaultIntValue = intValue;
				}
			}
			setIntValue(this._defaultIntValue);

		} else if (type == "bool") {
			this._size = 1;
			if (defaultValue != null) {
				this._defaultBoolValue = defaultValue == "true" ? true : false;
			}
			setBoolValue(this._defaultBoolValue);

		} else if (type == "vec2") {
			this._size = 2;
			this._float32ArrayValue = new Float32Array(2);
			if (defaultValue != null) {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
			}
			setFloatArrayValue(this._defaultFloatArrayValue);

		} else if (type == "vec3") {
			this._size = 3;
			this._float32ArrayValue = new Float32Array(3);
			if (defaultValue != null) {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
			}
			setFloatArrayValue(this._defaultFloatArrayValue);

		} else if (type == "vec4") {
			this._size = 4;
			this._float32ArrayValue = new Float32Array(4);
			if (defaultValue != null) {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
			}
			setFloatArrayValue(this._defaultFloatArrayValue);

		} else if (type == "ivec2") {
			this._size = 2;
			this._int32ArrayValue = new Int32Array(2);
			if (defaultValue != null) {
				this._defaultIntArrayValue = haxe.Json.parse(defaultValue);
			}
			setIntArrayValue(this._defaultIntArrayValue);

		} else if (type == "ivec3") {
			this._size = 3;
			this._int32ArrayValue = new Int32Array(3);
			if (defaultValue != null) {
				this._defaultIntArrayValue = haxe.Json.parse(defaultValue);
			}
			setIntArrayValue(this._defaultIntArrayValue);

		} else if (type == "ivec4") {
			this._size = 4;
			this._int32ArrayValue = new Int32Array(4);
			if (defaultValue != null) {
				this._defaultIntArrayValue = haxe.Json.parse(defaultValue);
			}
			setIntArrayValue(this._defaultIntArrayValue);

		} else if (type == "mat3" || type == "mat4") {
			if (type == "mat3") {
				this._size = 9;
				this._float32ArrayValue = new Float32Array(9);
			} else {
				this._size = 16;
				this._float32ArrayValue = new Float32Array(16);
			}
			if (defaultValue != null) {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]";
				}
				var floatArray:Array<Float> = haxe.Json.parse(defaultValue);
				this._defaultMatrixValue = new Matrix4(new Float32Array(floatArray));
			}
			setMatrixValue(this._defaultMatrixValue);

		} else if (type == "texture") {
			this._size = 1;
			if (defaultValue != null) {
				var value:Int = Std.parseInt(defaultValue);
				if (Math.isNaN(value)) {
					throw new XTException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

				} else {
					this._defaultTextureSlot = value;
				}
			}
			setTextureSlot(this._defaultTextureSlot);
		}

		// Reset has been set indicating that it hasn't been set by a user value
		this._hasBeenSet = false;
	}

}