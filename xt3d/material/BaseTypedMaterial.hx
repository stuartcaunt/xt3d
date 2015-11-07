package xt3d.material;

import xt3d.utils.XT;
import xt3d.utils.errors.XTException;
import xt3d.utils.color.Color;
class BaseTypedMaterial extends Material {

	// properties
	public var lightingEnabled(get, set):Bool;
	public var isHighQualityLighting(get, set):Bool;
	public var lightingColorAttributesEnabled(get, set):Bool;
	public var alphaCullingEnabled(get, set):Bool;
	public var vertexColorsEnabled(get, set):Bool;

	// Generic
	public var color(get, set):Color;
	public var opacity(get, set):Float;

	// Lighting
	public var shininess(get, set):Float;

	// Lighting color attributes
	public var ambientColor(get, set):Color;
	public var diffuseColor(get, set):Color;
	public var specularColor(get, set):Color;

	// Alpha culling
	public var alphaCullingValue(get, set):Float;

	// members
	private var _lightingEnabled:Bool = false;
	private var _isHighQualityLighting:Bool = true;
	private var _lightingColorAttributesEnabled:Bool = false;
	private var _alphaCullingEnabled:Bool = false;
	private var _vertexColorsEnabled:Bool = false;

	// Generic
	private var _color:Color = Color.createWithRGBAHex(0xffffffff);
	private var _opacity:Float = 1.0;

	// Lighting
	private var _shininess:Float = 1.0;

	// Lighting color attributes
	private var _ambientColor:Color = Color.createWithRGBHex(0xffffff);
	private var _diffuseColor:Color = Color.createWithRGBAHex(0xffffffff);
	private var _specularColor:Color = Color.createWithRGBHex(0xffffff);

	// Alpha culling
	private var _alphaCullingValue:Float = 0.0;

	public function initBaseTypedMaterial(lightingEnabled:Bool = false,
										  highQualityLighting:Bool = true,
										  lightingColorAttributesEnabled:Bool = false,
										  alphaCullingEnabled:Bool = false,
										  vertexColorsEnabled:Bool = false):Bool {
		var isOk;
		this._lightingEnabled = lightingEnabled;
		this._isHighQualityLighting = highQualityLighting;
		this._lightingColorAttributesEnabled = lightingColorAttributesEnabled;
		this._alphaCullingEnabled = alphaCullingEnabled;
		this._vertexColorsEnabled = vertexColorsEnabled;

		var materialName = this.constructMaterialName();

		if ((isOk = super.initMaterial(materialName))) {
			// Set material uniform values
			this.setMaterialUniforms();
		}

		return isOk;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public inline function get_lightingEnabled():Bool {
		return this._lightingEnabled;
	}

	public inline function set_lightingEnabled(value:Bool) {
		this.setLightingEnabled(value);
		return this._lightingEnabled;
	}

	public inline function get_isHighQualityLighting():Bool {
		return this._isHighQualityLighting;
	}

	public inline function set_isHighQualityLighting(value:Bool) {
		this.setIsHighQualityLighting(value);
		return this._isHighQualityLighting;
	}

	public inline function get_lightingColorAttributesEnabled():Bool {
		return this._lightingColorAttributesEnabled;
	}

	public inline function set_lightingColorAttributesEnabled(value:Bool) {
		this.setLightingColorAttributesEnabled(value);
		return this._lightingColorAttributesEnabled = value;
	}

	public inline function get_alphaCullingEnabled():Bool {
		return this._alphaCullingEnabled;
	}

	public inline function set_alphaCullingEnabled(value:Bool) {
		this.setAlphaCullingEnabled(value);
		return this._alphaCullingEnabled;
	}

	public inline function get_vertexColorsEnabled():Bool {
		return this._vertexColorsEnabled;
	}

	public inline function set_vertexColorsEnabled(value:Bool) {
		this.setVertexColorsEnabled(value);
		return this.vertexColorsEnabled;
	}

	function get_color():Color {
		return this._color;
	}

	function set_color(value:Color) {
		this.setColor(value);
		return this._color;
	}

	public override function get_transparent():Bool {
		return (this._transparent || this._opacity < 1.0);
	}

	public inline function get_opacity():Float {
		return this._opacity;
	}

	public inline function set_opacity(value:Float) {
		this.setOpacity(value);
		return this._opacity;
	}

	public inline function get_shininess():Float {
		return this._shininess;
	}

	public inline function set_shininess(value:Float) {
		this.setShininess(value);
		return this._shininess;
	}

	public inline function get_ambientColor():Color {
		return this._ambientColor;
	}

	public inline function set_ambientColor(value:Color) {
		this.setAmbientColor(value);
		return this._ambientColor;
	}

	public inline function get_diffuseColor():Color {
		return this._diffuseColor;
	}

	public inline function set_diffuseColor(value:Color) {
		this.setDiffuseColor(value);
		return this._diffuseColor;
	}

	public inline function get_specularColor():Color {
		return this._specularColor;
	}

	public inline function set_specularColor(value:Color) {
		this.setSpecularColor(value);
		return this._specularColor;
	}

	public inline function get_alphaCullingValue():Float {
		return this._alphaCullingValue;
	}

	public inline function set_alphaCullingValue(value:Float) {
		this.setAlphaCullingValue(value);
		return this._alphaCullingValue;
	}


	/* --------- Implementation --------- */

	public inline function setLightingEnabled(value:Bool) {
		this._isHighQualityLighting = value;

		// Rebuild material
		this.constructMaterial();
	}

	public inline function setIsHighQualityLighting(value:Bool) {
		this._lightingEnabled = value;

		// Rebuild material
		this.constructMaterial();
	}

	public inline function setLightingColorAttributesEnabled(value:Bool) {
		this._lightingColorAttributesEnabled = value;

		// Rebuild material
		this.constructMaterial();
	}

	public inline function setAlphaCullingEnabled(value:Bool) {
		this._alphaCullingEnabled = value;

		// Rebuild material
		this.constructMaterial();
	}

	public inline function setVertexColorsEnabled(value:Bool) {
		this._vertexColorsEnabled = value;

		// Rebuild material
		this.constructMaterial();
	}

	public inline function setColor(value:Color):Void {
		this._color.copyFrom(value);
		try {
			this.uniform("color").floatArrayValue = value.rgbaArray;
		} catch (e:XTException) {
		}
	}

	public inline function setOpacity(value:Float):Void {
		this._opacity = value;
		try {
			this.uniform("opacity").floatValue = value;
		} catch (e:XTException) {
		}
	}

	public inline function setAmbientColor(value:Color):Void {
		this._ambientColor.copyFrom(value);
		try {
			this.uniform("ambientColor").floatArrayValue = value.rgbArray;
		} catch (e:XTException) {
		}
	}

	public inline function setDiffuseColor(value:Color):Void {
		this._diffuseColor.copyFrom(value);
		try {
			this.uniform("diffuseColor").floatArrayValue = value.rgbaArray;
		} catch (e:XTException) {
		}
	}

	public inline function setSpecularColor(value:Color):Void {
		this._specularColor.copyFrom(value);
		try {
			this.uniform("specularColor").floatArrayValue = value.rgbaArray;
		} catch (e:XTException) {
		}
	}

	public inline function setShininess(value:Float):Void {
		this._shininess = value;
		try {
			if (this._lightingColorAttributesEnabled) {
				this.uniform("shininess").floatValue = this._shininess;

			} else {
				this.uniform("defaultShininess").floatValue = this._shininess;
			}
		} catch (e:XTException) {
		}
	}

	public inline function setAlphaCullingValue(value:Float):Void {
		this._alphaCullingValue = value;
		try {
			this.uniform("alphaCullingValue").floatValue = value;
		} catch (e:XTException) {
		}
	}


	private function constructMaterial():Void {
		var materialName = this.constructMaterialName();

		// Compare to current material
		if (this._programName != materialName) {

			// Set the program in the material
			this.setProgramName(materialName);

			// Set the material uniforms
			this.setMaterialUniforms();
		}

	}

	private function constructMaterialName():String {
		var materialName:String = "generic";

		// Specific name of typed material
		var typedMaterialName = this.getTypedMaterialName();
		if (typedMaterialName != null && typedMaterialName != "") {
			materialName += "+" + this.getTypedMaterialName();
		}

		// Vertex color
		if (this._vertexColorsEnabled) {
			materialName += "+vertexColors";
		}

		// Lighting
		if (this._lightingEnabled) {
			// Phong or Gouraud
			if (this._isHighQualityLighting) {
				materialName += "+phong";

			} else  {
				materialName += "+gouraud";
			}

			// lighting color attributes
			if (this._lightingColorAttributesEnabled) {
				materialName += "+material";
			}
		}

		// Alpha culling
		if (this._alphaCullingEnabled) {
			materialName += "+alphaCulling";
		}

		// Any additional extensions
		materialName += this.getTypedMaterialExtensions();

		return materialName;
	}

	private function setMaterialUniforms():Void {
		// Generic
		this.uniform("color").floatArrayValue = this._color.rgbaArray;
		this.uniform("opacity").floatValue = this._opacity;

		// Lighting
		if (this._lightingEnabled) {
			if (this._lightingColorAttributesEnabled) {
				this.uniform("shininess").floatValue = this._shininess;
				this.uniform("ambientColor").floatArrayValue = this._ambientColor.rgbArray;
				this.uniform("diffuseColor").floatArrayValue = this._diffuseColor.rgbaArray;
				this.uniform("specularColor").floatArrayValue = this._specularColor.rgbArray;

			} else {
				this.uniform("defaultShininess").floatValue = this._shininess;
			}
		}

		// Alpha culling
		if (this._alphaCullingEnabled) {
			this.uniform("alphaCullingValue").floatValue = this._alphaCullingValue;
		}

		// Typed material uniforms
		this.setTypedMaterialUniforms();
	}


	private function getTypedMaterialName():String {
		// To be overridden
		return "";
	}

	private function getTypedMaterialExtensions():String {
		// To be overridden
		return "";
	}

	private function setTypedMaterialUniforms():Void {
		// To be overridden
	}

}
