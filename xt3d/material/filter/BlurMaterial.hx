package xt3d.material.filter;

import xt3d.textures.Texture2D;

class BlurMaterial extends Material {

	private var _isHorizontal:Bool;
	private var _texture:Texture2D;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();

	public static function create(isHorizontal:Bool):BlurMaterial {
		var object = new BlurMaterial();

		if (object != null && !(object.init(isHorizontal))) {
			object = null;
		}

		return object;
	}

	public function init(isHorizontal:Bool):Bool {
		this._isHorizontal = isHorizontal;
		var blurFactor = 15;

		var materialName;
		if (this._isHorizontal) {
			materialName = "blurX" + blurFactor;

		} else {
			materialName = "blurY" + blurFactor;
		}

		var isOk;
		if ((isOk = super.initMaterial(materialName))) {
		}

		return isOk;
	}

	public function setTexture(value:Texture2D):Void {
		if (this._texture != null) {
			this._texture.release();
			this._texture = null;
		}

		if (value != null) {
			this._texture = value;
			this._texture.retain();

			this.uniform("texture").texture = this._texture;

			var textureUvScaleOffset = this._texture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

			if (this._isHorizontal) {
				this.uniform("textureWidth").floatValue = this._texture.pixelsWidth;

			} else {
				this.uniform("textureHeight").floatValue = this._texture.pixelsHeight;
			}

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

}