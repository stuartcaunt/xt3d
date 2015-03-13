package kfsgl.renderer.shaders;

import openfl.utils.Float32Array;
import openfl.gl.GL;
import haxe.Json;
import openfl.geom.Matrix3D;

import kfsgl.renderer.shaders.UniformLib;
import kfsgl.utils.KF;
import kfsgl.errors.KFException;

class Uniform  {

	// properties
	public var name(get_name, null):String;
	public var value(get_value, set_value):Float;
	public var floatArrayValue(get_floatArrayValue, set_floatArrayValue):Array<Float>;
	public var matrixValue(get_matrixValue, set_matrixValue):Matrix3D;


	// members
	private var _name:String;
	private var _uniformInfo:KFUniformInfo;
	private var _location:Int;
	private var _size:Int;

	private var _floatValue:Float = 0.0;
	private var _floatArrayValue:Array<Float> = new Array<Float>();
	private var _matrixValue:Matrix3D = new Matrix3D();

	private var _defaultFloatValue:Float;
	private var _defaultFloatArrayValue:Array<Float> = new Array<Float>();
	private var _defaultMatrixValue:Matrix3D = new Matrix3D();

	private var _hasBeenSet:Bool = false;
	private var _isDirty:Bool = true;

	public function new(name:String, uniformInfo:KFUniformInfo, location:Int) {
		_name = name;
		_uniformInfo = uniformInfo;
		_location = location;

		handleDefaultValue();

		//KF.Log(toString());
	}

	/* ----------- Properties ----------- */


	public inline function get_name():String {
		return this._name;
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
		set_floatArrayValue(value);
		return this._floatArrayValue;
	}

	public inline function get_matrixValue():Matrix3D {
		return this._matrixValue;
	}

	public function set_matrixValue(value:Matrix3D) {
		setMatrixValue(value);
		return this._matrixValue;
	}


	/* --------- Implementation --------- */

	public function clone():Uniform {
		return new Uniform(_name, _uniformInfo, _location);
	}

	public function uniformInfo():KFUniformInfo {
		return _uniformInfo;
	}


	public function prepareForUse() {
		_hasBeenSet = false;
	}

	public function use() {
		// If hasn't been set then use the default value
		if (!_hasBeenSet) {
			if (_size == 1) {
				setValue(_defaultFloatValue);
			} else if (_size < 16) {
				setArrayValue(_defaultFloatArrayValue);
			} else {
				setMatrixValue(_defaultMatrixValue);
			}
		}

		// Send value to the GPU if it is dirty
		if (_isDirty) {
			var type = _uniformInfo.type;
			if (type == "float") {
				GL.uniform1f(_location, _defaultFloatValue);

			} else if (type == "vec2") {
				GL.uniform2f(_location, _defaultFloatArrayValue[0], _defaultFloatArrayValue[1]);

			} else if (type == "vec3") {
				GL.uniform3f(_location, _defaultFloatArrayValue[0], _defaultFloatArrayValue[1], _defaultFloatArrayValue[2]);

			} else if (type == "ve4") {
				GL.uniform4f(_location, _defaultFloatArrayValue[0], _defaultFloatArrayValue[1], _defaultFloatArrayValue[2], _defaultFloatArrayValue[3]);

			} else if (type == "mat3") {
				var float32ArrayValue = new Float32Array(_defaultFloatArrayValue);
				GL.uniformMatrix3fv(_location, false, float32ArrayValue);

			} else if (type == "mat4") {
				var float32ArrayValue = new Float32Array(_defaultMatrixValue.rawData);
				GL.uniformMatrix4fv(_location, false, float32ArrayValue);
			}

			_isDirty = false;
		}

	}

	public function setValue(value:Float) {
		if (_size != 1) {
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
			_hasBeenSet = true;

			// Comparison of both arrays
			if (value.toString() != _floatArrayValue.toString()) {
				// Copy array values
				_floatArrayValue = value.copy();
				_isDirty = true;
			}

		}
	}

	public function setMatrixValue(value:Matrix3D) {
		_hasBeenSet = true;

		// Comparison of both matrices
		if (value.rawData.toString() != _matrixValue.rawData.toString()) {

			// Copy array values
			_matrixValue.copyFrom(value);
			_isDirty = true;
		}
	}

	public function handleDefaultValue() {
		var defaultValue = _uniformInfo.defaultValue;
		if (defaultValue != null) {
			var type = _uniformInfo.type;

			if (type == "float") {
				_size = 1;
				var floatValue:Float = Std.parseFloat(defaultValue);
				if (floatValue == Math.NaN) {
					throw new KFException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

				} else {
					_defaultFloatValue = floatValue;
					setValue(_defaultFloatValue);
				}

			} else if (type == "vec2") {
				_defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				_size = 2;
				setArrayValue(_defaultFloatArrayValue);

			} else if (type == "vec3") {
				_defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				_size = 3;
				setArrayValue(_defaultFloatArrayValue);

			} else if (type == "ve4") {
				setArrayValue(_defaultFloatArrayValue);
				_defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				_size = 4;
				setArrayValue(_defaultFloatArrayValue);

			} else if (type == "mat3") {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 1, 0, 0, 0, 1]";
				}
				_defaultFloatArrayValue = haxe.Json.parse(defaultValue);
				_size = 9;
				setArrayValue(_defaultFloatArrayValue);

			} else if (type == "mat4") {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]";
				}
				var floatArray:Array<Float> = haxe.Json.parse(defaultValue);
				_defaultMatrixValue.copyRawDataFrom(floatArray);
				_size = 16;
				setMatrixValue(_defaultMatrixValue);

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