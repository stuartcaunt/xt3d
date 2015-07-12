package kfsgl.gl.shaders;

import kfsgl.utils.math.MatrixHelper;
import openfl.gl.GLProgram;
import kfsgl.gl.GLTextureManager;
import kfsgl.textures.Texture2D;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;
import openfl.gl.GL;
import haxe.Json;
import openfl.geom.Matrix3D;

import kfsgl.utils.KF;
import kfsgl.utils.errors.KFException;
import kfsgl.gl.shaders.ShaderTypedefs;

class Uniform  {

	// properties
	public var name(get_name, null):String;
	public var type(get, null):String;
	public var boolValue(get, set):Bool;
	public var floatValue(get, set):Float;
	public var floatArrayValue(get_floatArrayValue, set_floatArrayValue):Array<Float>;
	public var matrixValue(get_matrixValue, set_matrixValue):Matrix3D;
	public var texture(get_texture, set_texture):Texture2D;
	public var textureSlot(get_textureSlot, set_textureSlot):Int;
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
	private var _floatArrayValue:Array<Float> = new Array<Float>();
	private var _float32ArrayValue:Float32Array;
	private var _matrixValue:Matrix3D = new Matrix3D();
	private var _texture:Texture2D = null;
	private var _textureSlot:Int = -1;

	private var _defaultBoolValue:Bool = false;
	private var _defaultFloatValue:Float = 0.0;
	private var _defaultFloatArrayValue:Array<Float> = null;
	private var _defaultMatrixValue:Matrix3D = new Matrix3D();
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
				KF.Warn("Unknown data type \"" + uniformType + "\" for uniform \"" + this._name + "\"");
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
				KF.Warn("Unknown data type \"" + uniformType + "\" for uniform \"" + this._name + "\"");
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

	public inline function get_floatArrayValue():Array<Float> {
		return this._floatArrayValue;
	}

	public function set_floatArrayValue(value:Array<Float>) {
		setArrayValue(value);
		return this._floatArrayValue;
	}

	public inline function get_matrixValue():Matrix3D {
		return this._matrixValue;
	}

	public function set_matrixValue(value:Matrix3D) {
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
			throw new KFException("UniformNotArray", "Uniform " + this._uniformInfo.name + " is not an array");
		}
	}

	public inline function get(typeElementName:String):Uniform {
		if (this._uniformStruct != null) {
			return this._uniformStruct.get(typeElementName);

		} else {
			throw new KFException("UniformNotStruct", "Uniform " + this._uniformInfo.name + " is not a struct");
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
				//KF.Log("Setting uniform " + this._name);
				if (type == "float") {
					GL.uniform1f(this._location, this._floatValue);

				} else if (type == "bool") {
					GL.uniform1i(this._location, this._boolValue ? 1 : 0);

				} else if (type == "texture") {
					GL.uniform1i(this._location, this._textureSlot);

				} else if (type == "vec2") {
					#if js
					this.copyToTypedArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					GL.uniform2fv(this._location, this._float32ArrayValue);

				} else if (type == "vec3") {
					#if js
					this.copyToTypedArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					GL.uniform3fv(this._location, this._float32ArrayValue);

				} else if (type == "vec4") {
					#if js
					this.copyToTypedArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					GL.uniform4fv(this._location, this._float32ArrayValue);

				} else if (type == "mat3") {
					MatrixHelper.copy3x3ToArray(this._matrixValue, this._floatArrayValue);
					#if js
					this.copyToTypedArray(this._floatArrayValue, this._float32ArrayValue);
					#else
					this._float32ArrayValue.set(this._floatArrayValue);
					#end
					GL.uniformMatrix3fv(this._location, false, this._float32ArrayValue);

				} else if (type == "mat4") {
					#if js
					this.copyToTypedArray(this._matrixValue.rawData.toArray(), this._float32ArrayValue);
					#elseif neko
					this._float32ArrayValue.set(this._matrixValue.rawData.toArray());
					#elseif (ios || mac || android)
					this._float32ArrayValue.set(this._matrixValue.rawData);
						#else
					this._float32ArrayValue.set(this._matrixValue.rawData.toArray());
						#end
					GL.uniformMatrix4fv(this._location, false, this._float32ArrayValue);
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

	private inline function copyToTypedArray(input:Array<Float>, out:Float32Array):Void {
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
				throw new KFException("IncompatibleUniforms", "Cannot copy uniform values from different unfiform type");
			}
			if (this._type == "float") {
				this.setFloatValue(uniform.floatValue);

			} else if (this._type == "bool") {
				this.setBoolValue(uniform.boolValue);

			} else if (this._type == "vec2" || this.type == "vec3" || this.type == "vec4") {
				if (uniform.floatArrayValue != null && uniform.floatArrayValue.length > 0) {
					this.setArrayValue(uniform.floatArrayValue);
				}

			} else if (this._type == "mat3" || this._type == "mat4") {
				this.setMatrixValue(uniform.matrixValue);

			} else if (this._type == "texture") {
				this.setTexture(uniform.texture);

				// Override program-specified texture slot _only_ if set by the user (default value changed)
				var textureSlot = (uniform.textureSlot != -1) ? uniform.textureSlot :this._defaultTextureSlot;
				this.setTextureSlot(textureSlot);
				//KF.Log(this._textureSlot);
			}
		}
	}


	public function setFloatValue(value:Float) {
		if (this._size != 1) {
			throw new KFException("IncoherentUniformValue", "A float value is being set for the uniform array " + _uniformInfo.name);
		} else {
			_hasBeenSet = true;

			if (_floatValue != value) {
				_floatValue = value;
				_isDirty = true;
			}
		}
	}

	public function setBoolValue(value:Bool) {
		if (this._size != 1) {
			throw new KFException("IncoherentUniformValue", "A bool value is being set for the uniform array " + _uniformInfo.name);
		} else {
			_hasBeenSet = true;

			if (_boolValue != value) {
				_boolValue = value;
				_isDirty = true;
			}
		}
	}

	public function setArrayValue(value:Array<Float>) {
		if (value != null) {
			if (this._size == 1 || this._size == 16 || this._size == 16) {
				throw new KFException("IncoherentUniformValue", "A float or matrix value is being set for the array uniform " + _uniformInfo.name);

			} else if (_size != value.length) {
				throw new KFException("IncoherentUniformValue", "An array of size " + value.length + " is being set for the uniform array " + _uniformInfo.name + " with size " + _size);

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

	public function setMatrixValue(value:Matrix3D) {
		if (value != null) {
			this._hasBeenSet = true;

			// Comparison of both matrices
			var hasChanged = false;
			var i = 0;
			var valueRawData = value.rawData;
			var matrixRawData = this._matrixValue.rawData;
			while (!hasChanged && i < 16) {
				hasChanged = (valueRawData[i] != matrixRawData[i]);
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
			throw new KFException("IncoherentUniformValue", "A texture slot is being set for a non-texture uniform");
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
				if (floatValue == Math.NaN) {
					throw new KFException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

				} else {
					this._defaultFloatValue = floatValue;
				}
			}
			setFloatValue(this._defaultFloatValue);

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
			setArrayValue(this._defaultFloatArrayValue);

		} else if (type == "vec3") {
			this._size = 3;
			this._float32ArrayValue = new Float32Array(3);
			if (defaultValue != null) {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
			}
			setArrayValue(this._defaultFloatArrayValue);

		} else if (type == "vec4") {
			this._size = 4;
			this._float32ArrayValue = new Float32Array(4);
			if (defaultValue != null) {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
			}
			setArrayValue(this._defaultFloatArrayValue);

		} else if (type == "mat3" || type == "mat4") {
			if (type == "mat3") {
				this._size = 9;
			} else {
				this._size = 16;
			}
			this._float32ArrayValue = new Float32Array(16);
			if (defaultValue != null) {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]";
				}
				var floatArray:Array<Float> = haxe.Json.parse(defaultValue);
				this._defaultMatrixValue.copyRawDataFrom(floatArray);
			}
			setMatrixValue(this._defaultMatrixValue);

		} else if (type == "texture") {
			this._size = 1;
			if (defaultValue != null) {
				var value:Int = Std.parseInt(defaultValue);
				if (value == Math.NaN) {
					throw new KFException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

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