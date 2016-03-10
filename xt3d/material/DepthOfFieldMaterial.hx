package xt3d.material;

import xt3d.textures.Texture2D;

class DepthOfFieldMaterial extends Material {

	// Properties
	public var renderedTexture(get, set):Texture2D;
	public var depthTexture(get, set):Texture2D;
	public var depthNear(get, set):Float;
	public var depthFar(get, set):Float;
	public var focalDepth(get, set):Float;
	public var focalRange(get, set):Float;

	// Members
	private var _isHorizontal:Bool;
	private var _renderedTexture:Texture2D;
	private var _depthTexture:Texture2D;

	private var _depthNear:Float;
	private var _depthFar:Float;

	private var _uvScaleOffset:Array<Float> = new Array<Float>();
	private var _focalDepth:Float;
	private var _focalRange:Float;

	public static function create(isHorizontal:Bool):DepthOfFieldMaterial {
		var object = new DepthOfFieldMaterial();

		if (object != null && !(object.init(isHorizontal))) {
			object = null;
		}

		return object;
	}

	public function init(isHorizontal:Bool):Bool {
		this._isHorizontal = isHorizontal;
		var isOk;

		var materialName;
		if (this._isHorizontal) {
			materialName = "depthOfFieldX";

		} else {
			materialName = "depthOfFieldY";
		}

		if ((isOk = super.initMaterial(materialName))) {
		}

		return isOk;
	}


	/* ----------- Properties ----------- */

	public inline function get_renderedTexture():Texture2D {
		return this._renderedTexture;
	}

	public inline function set_renderedTexture(value:Texture2D) {
		this.setRenderedTexture(value);
		return this._renderedTexture;
	}

	public inline function get_depthTexture():Texture2D {
		return this._depthTexture;
	}

	public inline function set_depthTexture(value:Texture2D) {
		this.setDepthTexture(value);
		return this._depthTexture;
	}

	inline function get_depthNear():Float {
		return this._depthNear;
	}

	inline function set_depthNear(value:Float) {
		this.setDepthNear(value);
		return this.depthNear;
	}

	inline function get_depthFar():Float {
		return this._depthFar;
	}

	inline function set_depthFar(value:Float) {
		this.setDepthFar(value);
		return this.depthFar;
	}

	inline function get_focalDepth():Float {
		return this._focalDepth;
	}

	inline function set_focalDepth(value:Float) {
		this.setFocalDepth(value);
		return this._focalDepth;
	}

	inline function get_focalRange():Float {
		return this._focalRange;
	}

	inline function set_focalRange(value:Float) {
		this.setFocalRange(value);
		return this._focalRange;
	}


	/* --------- Implementation --------- */

	public function setRenderedTexture(value:Texture2D):Void {
		if (this._renderedTexture != null) {
			this._renderedTexture.release();
			this._renderedTexture = null;
		}

		if (value != null) {
			this._renderedTexture = value;
			this._renderedTexture.retain();

			this.uniform("texture").texture = this._renderedTexture;

			var textureUvScaleOffset = this._renderedTexture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

			if (this._isHorizontal) {
				this.uniform("textureWidth").floatValue = this._renderedTexture.pixelsWidth;

			} else {
				this.uniform("textureHeight").floatValue = this._renderedTexture.pixelsHeight;
			}

		} else {
			this.uniform("texture").texture = null;
		}
	}

	public function setDepthTexture(value:Texture2D):Void {
		if (this._depthTexture != null) {
			this._depthTexture.release();
			this._depthTexture = null;
		}

		if (value != null) {
			this._depthTexture = value;
			this._depthTexture.retain();

			this.uniform("depthTexture").texture = this._depthTexture;

		} else {
			this.uniform("texture").texture = null;
		}
	}

	public function setUvScaleOffset(uvScaleX:Float, uvScaleY:Float, uvOffsetX:Float, uvOffsetY:Float):Void {
		this._uvScaleOffset[0] = uvScaleX;
		this._uvScaleOffset[1] = uvScaleY;
		this._uvScaleOffset[2] = uvOffsetX;
		this._uvScaleOffset[3] = uvOffsetY;

		this.uniform("uvScaleOffset").floatArrayValue = this._uvScaleOffset;
	}

	public function setDepthNear(depthNear:Float):Void {
		this._depthNear = depthNear;
		this.uniform("depthNear").floatValue = this._depthNear;
	}

	public function setDepthFar(depthFar:Float):Void {
		this._depthFar = depthFar;
		this.uniform("depthFar").floatValue = this._depthFar;
	}

	public function setFocalDepth(focalDepth:Float):Void {
		this._focalDepth = focalDepth;

		this.uniform("focalDepth").floatValue = this._focalDepth;
	}

	public function setFocalRange(focalRange:Float):Void {
		this._focalRange = focalRange;

		this.uniform("focalRange").floatValue = this._focalRange;
	}
}
