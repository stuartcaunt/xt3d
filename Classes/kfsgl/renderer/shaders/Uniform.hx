package kfsgl.renderer.shaders;

import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;
import openfl.gl.GL;
import haxe.Json;
import openfl.geom.Matrix3D;

import kfsgl.renderer.shaders.UniformInfo;
import kfsgl.utils.KF;
import kfsgl.utils.errors.KFException;

class Uniform  {

	// properties
	public var name(get_name, null):String;
	public var value(get_value, set_value):Float;
	public var type(get, null):String;
	public var floatArrayValue(get_floatArrayValue, set_floatArrayValue):Array<Float>;
	public var matrixValue(get_matrixValue, set_matrixValue):Matrix3D;
	public var isGlobal(get, null):Bool;
	public var hasBeenSet(get, null):Bool;


	// members
	private var _name:String;
	private var _type:String;
	private var _uniformInfo:UniformInfo;
	private var _location:GLUniformLocation;
	private var _isGlobal:Bool = false;
	private var _size:Int;

	private var _floatValue:Float = 0.0;
	private var _floatArrayValue:Array<Float> = new Array<Float>();
	private var _matrixValue:Matrix3D = new Matrix3D();

	private var _defaultFloatValue:Float;
	private var _defaultFloatArrayValue:Array<Float> = new Array<Float>();
	private var _defaultMatrixValue:Matrix3D = new Matrix3D();

	private var _hasBeenSet:Bool = false;
	private var _isDirty:Bool = true;

	public static function create(name:String, uniformInfo:UniformInfo, location:GLUniformLocation):Uniform {
		var object = new Uniform();

		if (object != null && !(object.init(name, uniformInfo, location))) {
			object = null;
		}

		return object;
	}

	public static function createEmpty(name:String, uniformInfo:UniformInfo):Uniform {
		var object = new Uniform();

		if (object != null && !(object.initEmpty(name, uniformInfo))) {
			object = null;
		}

		return object;

	}

	public function init(name:String, uniformInfo:UniformInfo, location:GLUniformLocation):Bool {
		this._name = name;
		this._type = uniformInfo.type;
		this._uniformInfo = uniformInfo;
		this._location = location;
		this._isGlobal = uniformInfo.global;

		handleDefaultValue();

		return true;
	}


	public function initEmpty(name:String, uniformInfo:UniformInfo):Bool {
		this._name = name;
		this._type = uniformInfo.type;
		this._uniformInfo = uniformInfo;
		this._isGlobal = uniformInfo.global;

		handleDefaultValue();

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

	public inline function get_value():Float {
		return this._floatValue;
	}

	public function set_value(value:Float) {
		this.setValue(value);
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

	public inline function get_isGlobal():Bool{
		return this._isGlobal;
	}

	public inline function get_hasBeenSet():Bool{
		return this._hasBeenSet;
	}


/* --------- Implementation --------- */

	public function clone():Uniform {
		return Uniform.create(this._name, this._uniformInfo, this._location);
	}

	public function uniformInfo():UniformInfo {
		return this._uniformInfo;
	}


	public function prepareForUse() {
		_hasBeenSet = false;
	}

	public function use() {
		// If hasn't been set then use the default value
		if (!_hasBeenSet) {
			if (this._size == 1) {
				setValue(this._defaultFloatValue);
			} else if (this._size < 16) {
				setArrayValue(this._defaultFloatArrayValue);
			} else {
				setMatrixValue(this._defaultMatrixValue);
			}
		}

		// Send value to the GPU if it is dirty
		if (_isDirty) {
			var type = this._uniformInfo.type;
			if (type == "float") {
				GL.uniform1f(this._location, this._floatValue);

			} else if (type == "vec2") {
				GL.uniform2f(this._location, this._floatArrayValue[0], this._floatArrayValue[1]);

			} else if (type == "vec3") {
				GL.uniform3f(this._location, this._floatArrayValue[0], this._floatArrayValue[1], this._floatArrayValue[2]);

			} else if (type == "vec4") {
				GL.uniform4f(this._location, this._floatArrayValue[0], this._floatArrayValue[1], this._floatArrayValue[2], this._floatArrayValue[3]);

			} else if (type == "mat3") {
				var float32ArrayValue = new Float32Array(this._floatArrayValue);
				GL.uniformMatrix3fv(this._location, false, float32ArrayValue);

			} else if (type == "mat4") {
				var float32ArrayValue = new Float32Array(this._matrixValue.rawData);
				GL.uniformMatrix4fv(this._location, false, float32ArrayValue);
			}

			_isDirty = false;
		}

	}

	public function copyFrom(uniform:Uniform):Void {
		if (uniform.type != this._type) {
			throw new KFException("IncompatibleUniforms", "Cannot copy uniform values from different unfiform type");
		}
		if (this._type == "float") {
			this.setValue(uniform.value);

		} else if (this._type == "vec2" || this.type == "vec3" || this.type == "vec4") {
			this.setArrayValue(uniform.floatArrayValue);

		} else if (this._type == "mat3" || this._type == "mat4") {
			this.setMatrixValue(uniform.matrixValue);
		}
	}


	public function setValue(value:Float) {
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

	public function setArrayValue(value:Array<Float>) {
		if (_size == 1 || _size == 16) {
			throw new KFException("IncoherentUniformValue", "A float or matrix value is being set for the array uniform " + _uniformInfo.name);
		
		} else if (_size != value.length) {
			throw new KFException("IncoherentUniformValue", "An array of size " + value.length + " is being set for the uniform array " + _uniformInfo.name + " with size " + _size);
		
		} else {
			this._hasBeenSet = true;

			// Comparison of both arrays
			if (value.toString() != this._floatArrayValue.toString()) {
				// Copy array values
				this._floatArrayValue = value.copy();
				this._isDirty = true;
			}

		}
	}

	public function setMatrixValue(value:Matrix3D) {
		this._hasBeenSet = true;

		// Comparison of both matrices
		if (value.rawData.toString() != this._matrixValue.rawData.toString()) {

			// Copy array values
			this._matrixValue.copyFrom(value);
			this._isDirty = true;
		}
	}


	public function handleDefaultValue() {
		var defaultValue = this._uniformInfo.defaultValue;
		if (defaultValue != null) {
			var type = this._uniformInfo.type;

			if (type == "float") {
				this._size = 1;
				var floatValue:Float = Std.parseFloat(defaultValue);
				if (floatValue == Math.NaN) {
					throw new KFException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

				} else {
					this._defaultFloatValue = floatValue;
					setValue(this._defaultFloatValue);
				}

			} else if (type == "vec2") {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				this._size = 2;
				setArrayValue(this._defaultFloatArrayValue);

			} else if (type == "vec3") {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				this._size = 3;
				setArrayValue(this._defaultFloatArrayValue);

			} else if (type == "vec4") {
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				this._size = 4;
				setArrayValue(this._defaultFloatArrayValue);

			} else if (type == "mat3") {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 1, 0, 0, 0, 1]";
				}
				this._defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				this._size = 9;
				setArrayValue(this._defaultFloatArrayValue);

			} else if (type == "mat4") {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]";
				}
				var floatArray:Array<Float> = haxe.Json.parse(defaultValue);
				this._defaultMatrixValue.copyRawDataFrom(floatArray);
				this._size = 16;
				setMatrixValue(this._defaultMatrixValue);

			}
		}
	}

	public function toString() {
		var type = _uniformInfo.type;
		var text:String = "unifom " + _name + " (";

		if (type == "float") {
			text += _floatValue;

		} else if (type == "vec2") {
			text += _floatArrayValue.toString();

		} else if (type == "vec3") {
			text += _floatArrayValue.toString();

		} else if (type == "ve4") {
			text += _floatArrayValue.toString();

		} else if (type == "mat3") {
			text += _floatArrayValue.toString();

		} else if (type == "mat4") {
			text += _matrixValue.rawData.toString();

		}

		text += ")" + " : " + _uniformInfo.name + " = " + _location;

		return text;
	}

}