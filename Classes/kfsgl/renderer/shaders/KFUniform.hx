package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.KFUniformLib;
import kfsgl.utils.KF;
import kfsgl.errors.KFException;

class KFUniform  {

	private var _name:String;
	private var _uniformInfo:KFUniformInfo;
	private var _location:Int;
	private var _size:Int;
	private var _floatValue:Array<Float> = new Array<Float>();

	private var _defaultFloatValue:Array<Float> = new Array<Float>();

	private var _hasBeenSet:Bool;
	private var _isDirty:Bool;

	public function new(name:String, uniformInfo:KFUniformInfo, location:Int) {
		_name = name;
		_uniformInfo = uniformInfo;
		_location = location;

		handleDefaultValue();


		KF.Log("uniform " + _name + " (" + _defaultFloatValue + ")" + " : " + _uniformInfo.name + " = " + _location);

	}


	public function clone():KFUniform {
		return new KFUniform(_name, _uniformInfo, _location);
	}


	public function prepareForUse() {
		_hasBeenSet = false;
	}

	public function use() {
		// If hasn't been set then use the default value
		if (!_hasBeenSet && _defaultFloatValue.length > 0) {
			if (_size == 1) {
				setValue(_defaultFloatValue[0]);
			} else {
				setValues(_defaultFloatValue);
			}
		}

		// Send value to the GPU if it is dirty
		if (_isDirty) {
			// TODO set value in the GPU
		}
	}

	public function setValue(value:Float) {
		if (_size != 1) {
			throw new KFException("IncoherentUniformValue", "A float value is being set for the uniform array " + _uniformInfo.name);
		} else {
			_hasBeenSet = true;

			if (_floatValue[0] != value) {
				_floatValue[0] = value;
				_isDirty = true;
			}
		}
	}

	public function setValues(values:Array<Float>) {
		if (_size == 1) {
			throw new KFException("IncoherentUniformValue", "An array value is being set for the uniform float " + _uniformInfo.name);
		
		} else if (_size != values.length) {
			throw new KFException("IncoherentUniformValue", "An array of size " + values.length + " is being set for the uniform array " + _uniformInfo.name + " with size " + _size);
		
		} else {
			_hasBeenSet = true;

			// Comparison of both arrays
			if (values.toString() != _floatValue.toString()) {

				// Copy array values
				_floatValue = values.copy();
				_isDirty = true;
			}

		}
	}

	public function handleDefaultValue() {
		var defaultValue = _uniformInfo.defaultValue;
		if (defaultValue != null) {
			var type = _uniformInfo.type;

			if (type == "float") {
				var floatValue:Float = Std.parseFloat(defaultValue);
				if (floatValue == Math.NaN) {
					throw new KFException("UnableToParseUniformValue", "Could not parse default value " + defaultValue + " for uniform " + _uniformInfo.name);

				} else {
					_floatValue.push(floatValue);
				}
				_size = 1;
				
			} else if (type == "vec2") {
				_defaultFloatValue = haxe.Json.parse(defaultValue);
				_size = 2;
				
			} else if (type == "vec3") {
				_defaultFloatValue = haxe.Json.parse(defaultValue);
				_size = 3;

			} else if (type == "ve4") {
				_defaultFloatValue = haxe.Json.parse(defaultValue);
				_size = 4;
				
			} else if (type == "mat3") {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 1, 0, 0, 0, 1]";
				}
				_defaultFloatValue = haxe.Json.parse(defaultValue);
				_size = 9;
				
			} else if (type == "mat4") {
				if (defaultValue == "identity") {
					defaultValue = "[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]";
				}
				_defaultFloatValue = haxe.Json.parse(defaultValue);
				_size = 16;

			}
		}
	}

}