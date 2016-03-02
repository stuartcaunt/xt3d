package xt3d.material;

import xt3d.textures.Texture2D;

class DepthDebugMaterial extends Material {

	// members
	private var _texture:Texture2D = null;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();

	public static function create():DepthDebugMaterial {
		var object = new DepthDebugMaterial();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var isOk;
		if ((isOk = super.initMaterial("depth_debug"))) {
		}

		return isOk;
	}

	public function setTexture(value:Texture2D):Void {
		if (this._texture != null) {
			this._texture.release();
		}

		if (value != null) {
			this._texture = value;
			this._texture.retain();

			this.uniform("texture").texture = this._texture;

			var textureUvScaleOffset = this._texture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

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
