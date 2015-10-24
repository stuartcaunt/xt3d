package xt3d.node;


import xt3d.core.RendererOverrider;
import xt3d.primitives.Sphere;
import xt3d.core.Material;
import xt3d.utils.XT;
import xt3d.utils.math.MatrixHelper;
import xt3d.utils.math.VectorHelper;
import xt3d.gl.shaders.UniformLib;
import xt3d.node.Scene;
import xt3d.node.Node3D;
import lime.math.Vector4;
import xt3d.utils.color.Color;
import xt3d.gl.XTGL;

class Light extends Node3D {

	// properties
	public var lightType(get, set):Int;
	public var ambientColor(get, set):Color;
	public var diffuseColor(get, set):Color;
	public var specularColor(get, set):Color;

	public var constantAttenuation(get, set):Float;
	public var linearAttenuation(get, set):Float;
	public var quadraticAttenuation(get, set):Float;

	public var direction(get, set):Vector4;

	public var spotCutoffAngle(get, set):Float;
	public var spotFalloffExponent(get, set):Float;
	public var enabled(get, set):Bool;

	public var renderLight(get, set):Bool;

	// members
	private var _lightType:Int = XTGL.PointLight;
	private var _ambientColor:Color;
	private var _diffuseColor:Color;
	private var _specularColor:Color;

	private var _attenuation = [1.0, 0.0, 0.0];

	private var _direction:Vector4 = new Vector4();

	private var _spotCutoffAngle:Float = -1.0;
	private var _spotFalloffExponent:Float = 1.0;

	private var _enabled:Bool = true;

	private var _positionArray = new Array<Float>();
	private var _directionArray = new Array<Float>();

	private var _renderLight:Bool = false;
	private var _renderedLight:Node3D = null;

	public static function createPointLight(ambient:Int = 0x000000, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0):Light {
		var object = new Light();

		if (object != null && !(object.initPointLight(ambient, diffuse, specular, attenuation))) {
			object = null;
		}

		return object;
	}

	public static function createDirectionalLight(ambient:Int = 0x000000, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0, direction:Vector4 = null):Light {
		var object = new Light();

		if (object != null && !(object.initDirectionalLight(ambient, diffuse, specular, direction))) {
			object = null;
		}

		return object;
	}

	public static function createSpotLight(ambient:Int = 0x000000, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0, direction:Vector4 = null, cutoffAngle:Float = 30.0, falloffExponent:Float = 1.0):Light {
		var object = new Light();

		if (object != null && !(object.initSpotLight(ambient, diffuse, specular, attenuation, direction, cutoffAngle, falloffExponent))) {
			object = null;
		}

		return object;
	}

	public function initPointLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0):Bool {
		var retval;
		if ((retval = super.init())) {
			this._lightType = XTGL.PointLight;
			this._ambientColor = Color.createWithRGBHex(ambient);
			this._diffuseColor = Color.createWithRGBHex(diffuse);
			this._specularColor = Color.createWithRGBHex(specular);

			// Quadratic attenuation
			this._attenuation[2] = attenuation;

			this._renderLight = false;
		}

		return retval;
	}

	public function initDirectionalLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, direction:Vector4 = null):Bool {
		var retval;
		if ((retval = super.init())) {
			this._lightType = XTGL.DirectionalLight;
			this._ambientColor = Color.createWithRGBHex(ambient);
			this._diffuseColor = Color.createWithRGBHex(diffuse);
			this._specularColor = Color.createWithRGBHex(specular);

			if (direction == null) {
				direction = new Vector4();
			}
			this._direction = direction;

			this._renderLight = false;
		}

		return retval;
	}

	public function initSpotLight(ambient:Int = 0x222222, diffuse:Int = 0xFFFFFF, specular:Int = 0xFFFFFF, attenuation:Float = 0.0, direction:Vector4 = null, cutoffAngle:Float = 15.0, falloffExponent:Float = 0.0):Bool {
		var retval;
		if ((retval = super.init())) {
			this._lightType = XTGL.SpotLight;
			this._ambientColor = Color.createWithRGBHex(ambient);
			this._diffuseColor = Color.createWithRGBHex(diffuse);
			this._specularColor = Color.createWithRGBHex(specular);

			// Quadratic attenuation
			this._attenuation[2] = attenuation;

			if (direction == null) {
				direction = new Vector4();
			}
			this._direction = direction;

			this._spotCutoffAngle = cutoffAngle;
			this._spotFalloffExponent = falloffExponent;

			this._renderLight = false;
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
		return this._attenuation[0];
	}

	public inline function set_constantAttenuation(value:Float) {
		return this._attenuation[0] = value;
	}

	public inline function get_linearAttenuation():Float {
		return this._attenuation[1];
	}

	public inline function set_linearAttenuation(value:Float) {
		return this._attenuation[1] = value;
	}

	public inline function get_quadraticAttenuation():Float {
		return this._attenuation[2];
	}

	public inline function set_quadraticAttenuation(value:Float) {
		return this._attenuation[2] = value;
	}

	public inline function get_direction():Vector4 {
		return this._direction;
	}

	public inline function set_direction(value:Vector4) {
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

	public function get_enabled():Bool {
		return this._enabled;
	}

	public function set_enabled(value:Bool) {
		return this._enabled = value;
	}

	function set_renderLight(value:Bool) {
		this.setRenderLight(value);
		return this._renderLight;
	}

	function get_renderLight():Bool {
		return this._renderLight;
	}


	/* --------- Implementation --------- */

	public inline function setDirection(value:Vector4):Void {
		var len = value.length;
		this._direction.x = value.x / len;
		this._direction.y = value.y / len;
		this._direction.z = value.z / len;
	}

	override public function prepareObjectForRender(scene:Scene, overrider:RendererOverrider = null):Void {
		if (this._enabled) {
			scene.addLight(this);
		}
	}

	public function setRenderLight(renderLight:Bool):Void {
		if (this._lightType == XTGL.DirectionalLight) {
			XT.Warn("Light is directional an cannot therefore be rendered on scene");
			return;
		}

		if (renderLight != this._renderLight) {
			// Remove previous rendered light
			if (!renderLight && this._renderedLight != null) {
				this.removeChild(this._renderedLight);
			}

			this._renderLight = renderLight;

			if (this._renderLight) {
				var material:Material = Material.create("generic");
				material.uniform("color").floatArrayValue = this._diffuseColor.rgbaArray;
				var mesh:Sphere = Sphere.create(0.2, 4, 2);

				this._renderedLight = MeshNode.create(mesh, material);
				this.addChild(this._renderedLight);
			}
		}
	}


	public function prepareRender(camera:Camera, uniformLib:UniformLib, index:Int):Void {
		uniformLib.uniform("lights").at(index).get("enabled").boolValue = this._enabled;

		// Position (depending on point, directional and spot lights
		if (this._lightType == XTGL.PointLight || this._lightType == XTGL.SpotLight) {
			MatrixHelper.transform4x4VectorToArray(camera.viewMatrix, this.worldPosition, this._positionArray);
			uniformLib.uniform("lights").at(index).get("position").floatArrayValue = this._positionArray;

			// Attenuation
			uniformLib.uniform("lights").at(index).get("attenuation").floatArrayValue = this._attenuation;

		} else {
			MatrixHelper.transform3x3VectorToArray(camera.viewMatrix, this._direction, this._directionArray);
			this._directionArray[0] = -this._directionArray[0];
			this._directionArray[1] = -this._directionArray[1];
			this._directionArray[2] = -this._directionArray[2];
			this._directionArray[3] = 0.0;
			uniformLib.uniform("lights").at(index).get("position").floatArrayValue = this._directionArray;
		}

		// Colors
		uniformLib.uniform("lights").at(index).get("ambientColor").floatArrayValue = this._ambientColor.rgbArray;
		uniformLib.uniform("lights").at(index).get("diffuseColor").floatArrayValue = this._diffuseColor.rgbArray;
		uniformLib.uniform("lights").at(index).get("specularColor").floatArrayValue = this._specularColor.rgbArray;

		// Spot lights
		if (this._lightType == XTGL.SpotLight) {
			MatrixHelper.transform3x3VectorToArray(camera.viewMatrix, this._direction, this._directionArray);

			uniformLib.uniform("lights").at(index).get("spotDirection").floatArrayValue = this._directionArray;
			uniformLib.uniform("lights").at(index).get("spotCutoffAngle").floatValue = this._spotCutoffAngle;
			uniformLib.uniform("lights").at(index).get("spotFalloffExponent").floatValue = this._spotFalloffExponent;

		} else {
			uniformLib.uniform("lights").at(index).get("spotCutoffAngle").floatValue = -1.0;
		}


	}

}
