package xt3d.material;

import xt3d.textures.Texture2D;

class DepthOfFieldMaterial extends Material {

	private var _renderedTexture:Texture2D;
	private var _depthTexture:Texture2D;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();
	private var _focalDepth:Float;

	public static function create():DepthOfFieldMaterial {
		var object = new DepthOfFieldMaterial();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var isOk;
		if ((isOk = super.initMaterial("depthOfFieldBokeh"))) {
		}

		return isOk;
	}

	public function setRenderedTexture(value:Texture2D):Void {
		if (this._renderedTexture != null) {
			this._renderedTexture.release();
		}

		if (value != null) {
			this._renderedTexture = value;
			this._renderedTexture.retain();

			this.uniform("texture").texture = this._renderedTexture;

			var textureUvScaleOffset = this._renderedTexture.uvScaleOffset;
			this.setUvScaleOffset(textureUvScaleOffset[0], textureUvScaleOffset[1], textureUvScaleOffset[2], textureUvScaleOffset[3]);

			this.uniform("textureWidth").floatValue = this._renderedTexture.pixelsWidth;
			this.uniform("textureHeight").floatValue = this._renderedTexture.pixelsHeight;

		} else {
			this.uniform("texture").texture = null;
		}
	}

	public function setDepthTexture(value:Texture2D):Void {
		if (this._depthTexture != null) {
			this._depthTexture.release();
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

	public function setFocalDepth(focalDepth:Float):Void {
		this._focalDepth = focalDepth;

		this.uniform("focalDepth").floatValue = this._focalDepth;
	}
}
