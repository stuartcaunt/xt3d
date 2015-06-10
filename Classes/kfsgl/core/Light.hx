package kfsgl.core;


import kfsgl.node.Node3D;
import openfl.geom.Vector3D;
import kfsgl.utils.Color;
import kfsgl.gl.KFGL;

class Light extends Node3D {

	// properties
	public var lightType(get, set):Int;
	public var ambientColor(get, set):Color;
	public var diffuseColor(get, set):Color;
	public var specularColor(get, set):Color;

	public var constantAttenuation(get, set):Float;
	public var linearAttenuation(get, set):Float;
	public var quadraticAttenuation(get, set):Float;

	public var direction(get, set):Vector3D;

	public var spotCutoffAngle(get, set):Float;
	public var spotFalloffExponent(get, set):Float;


	// members
	private var _lightType:Int = KFGL.PointLight;
	private var _ambientColor:Color;
	private var _diffuseColor:Color;
	private var _specularColor:Color;

	private var _constantAttenuation:Float = 1.0;
	private var _linearAttenuation:Float = 0.0;
	private var _quadraticAttenuation:Float = 0.0;

	private var _direction:Vector3D = new Vector3D();

	private var _spotCutoffAngle:Float = 15.0;
	private var _spotFalloffExponent:Float = 0.0;

	public static function createPointLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0):Light {
		var object = new Light();

		if (object != null && !(object.initPointLight(ambient, diffuse, specular, attenuation))) {
			object = null;
		}

		return object;
	}

	public static function createDirectionalLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0, direction:Vector3D = null):Light {
		var object = new Light();

		if (object != null && !(object.initDirectionalLight(ambient, diffuse, specular, attenuation, direction))) {
			object = null;
		}

		return object;
	}

	public static function createSpotLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0, direction:Vector3D = null, cutoffAngle:Float = 15.0, falloffExponent:Float = 0.0):Light {
		var object = new Light();

		if (object != null && !(object.initSpotLight(ambient, diffuse, specular, attenuation, direction, cutoffAngle, falloffExponent))) {
			object = null;
		}

		return object;
	}

	public function initPointLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0):Bool {
		var retval;
		if ((retval = super.init())) {
			this._lightType = KFGL.PointLight;
			this._ambientColor = Color.createWithRGBHex(ambient);
			this._diffuseColor = Color.createWithRGBHex(diffuse);
			this._specularColor = Color.createWithRGBHex(specular);

			this._quadraticAttenuation = attenuation;
		}

		return retval;
	}

	public function initDirectionalLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0, direction:Vector3D = null):Bool {
		var retval;
		if ((retval = super.init())) {
			this._lightType = KFGL.DirectionalLight;
			this._ambientColor = Color.createWithRGBHex(ambient);
			this._diffuseColor = Color.createWithRGBHex(diffuse);
			this._specularColor = Color.createWithRGBHex(specular);

			this._quadraticAttenuation = attenuation;

			if (direction == null) {
				direction = new Vector3D();
			}
			this._direction = direction;
		}

		return retval;
	}

	public function initSpotLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0, direction:Vector3D = null, cutoffAngle:Float = 15.0, falloffExponent:Float = 0.0):Bool {
		var retval;
		if ((retval = super.init())) {
			this._lightType = KFGL.SpotLight;
			this._ambientColor = Color.createWithRGBHex(ambient);
			this._diffuseColor = Color.createWithRGBHex(diffuse);
			this._specularColor = Color.createWithRGBHex(specular);

			this._quadraticAttenuation = attenuation;

			if (direction == null) {
				direction = new Vector3D();
			}
			this._direction = direction;

			this._spotCutoffAngle = cutoffAngle;
			this._spotFalloffExponent = falloffExponent;
		}

		return retval;
	}


	public function new() {
		super();
	}


/* ----------- Properties ----------- */


	public inline function get_lightType():Int {
		return this._lightType;
	}

	public inline function set_lightType(value:Int) {
		return this._lightType = value;
	}

	public inline function get_ambientColor():Color {
		return this._ambientColor;
	}

	public inline function set_ambientColor(value:Color) {
		return this._ambientColor = value;
	}

	public inline function get_diffuseColor():Color {
		return this._diffuseColor;
	}

	public inline function set_diffuseColor(value:Color) {
		return this._diffuseColor = value;
	}

	public inline function get_specularColor():Color {
		return this._specularColor;
	}

	public inline function set_specularColor(value:Color) {
		return this._specularColor = value;
	}

	public inline function get_constantAttenuation():Float {
		return this._constantAttenuation;
	}

	public inline function set_constantAttenuation(value:Float) {
		return this._constantAttenuation = value;
	}

	public inline function get_linearAttenuation():Float {
		return this._linearAttenuation;
	}

	public inline function set_linearAttenuation(value:Float) {
		return this._linearAttenuation = value;
	}

	public inline function get_quadraticAttenuation():Float {
		return this._quadraticAttenuation;
	}

	public inline function set_quadraticAttenuation(value:Float) {
		return this._quadraticAttenuation = value;
	}

	public inline function get_direction():Vector3D {
		return this._direction;
	}

	public inline function set_direction(value:Vector3D) {
		this.setDirection(value);
		return this._direction;
	}

	public inline function get_spotCutoffAngle():Float {
		return this._spotCutoffAngle;
	}

	public inline function set_spotCutoffAngle(value:Float) {
		return this._spotCutoffAngle = value;
	}

	public inline function get_spotFalloffExponent():Float {
		return this._spotFalloffExponent;
	}

	public inline function set_spotFalloffExponent(value:Float) {
		return this._spotFalloffExponent = value;
	}



	/* --------- Implementation --------- */

	public inline function setDirection(value:Vector3D):Void {
		var len = value.length;
		this._direction.x = value.x / len;
		this._direction.y = value.y / len;
		this._direction.z = value.z / len;
	}

}
