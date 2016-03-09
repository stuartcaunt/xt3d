package xt3d.material;

import xt3d.textures.Texture2D;

class DepthOfFieldBokehMaterial extends Material {

	// Properties
	public var renderedTexture(get, set):Texture2D;
	public var depthTexture(get, set):Texture2D;
	public var focalDepth(get, set):Float;
	public var focalRange(get, set):Float;
	public var highlightThreshold(get, set):Float;
	public var highlightGain(get, set):Float;
	public var chromaticFringe(get, set):Float;
	public var edgeBias(get, set):Float;
	public var dither(get, set):Float;

	// Members

	private var _renderedTexture:Texture2D;
	private var _depthTexture:Texture2D;
	private var _uvScaleOffset:Array<Float> = new Array<Float>();

	private var _focalDepth:Float;
	private var _focalRange:Float;

	private var _highlightThreshold:Float; // highlight threshold;
	private var _highlightGain:Float; // highlight gain;
	private var _chromaticFringe:Float; // bokeh chromatic aberration/fringing
	private var _edgeBias:Float; // bokeh edge bias
	private var _dither:Float; // dither amount

	public static function create():DepthOfFieldBokehMaterial {
		var object = new DepthOfFieldBokehMaterial();

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

	inline function get_highlightThreshold():Float {
		return this._highlightThreshold;
	}

	inline function set_highlightThreshold(value:Float) {
		this.setHighlightThreshold(value);
		return this._highlightThreshold;
	}

	inline function get_highlightGain():Float {
		return this._highlightGain;
	}

	inline function set_highlightGain(value:Float) {
		this.setHighlightGain(value);
		return this._highlightGain;
	}

	inline function get_chromaticFringe():Float {
		return this._chromaticFringe;
	}

	inline function set_chromaticFringe(value:Float) {
		this.setChromaticFringe(value);
		return this._chromaticFringe;
	}

	inline function get_edgeBias():Float {
		return this._edgeBias;
	}

	inline function set_edgeBias(value:Float) {
		this.setEdgeBias(value);
		return this._edgeBias;
	}

	inline function get_dither():Float {
		return this._dither;
	}

	inline function set_dither(value:Float) {
		this.setDither(value);
		return this._dither;
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

			this.uniform("textureWidth").floatValue = this._renderedTexture.pixelsWidth;
			this.uniform("textureHeight").floatValue = this._renderedTexture.pixelsHeight;

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

	public function setFocalDepth(focalDepth:Float):Void {
		this._focalDepth = focalDepth;
		this.uniform("focalDepth").floatValue = this._focalDepth;
	}

	public function setFocalRange(focalRange:Float):Void {
		this._focalRange = focalRange;
		this.uniform("focalRange").floatValue = this._focalRange;
	}

	public function setHighlightThreshold(highlightThreshold:Float):Void {
		this._highlightThreshold = highlightThreshold;
		this.uniform("highlightThreshold").floatValue = this._highlightThreshold;
	}

	public function setHighlightGain(highlightGain:Float):Void {
		this._highlightGain = highlightGain;
		this.uniform("highlightGain").floatValue = this._highlightGain;
	}

	public function setChromaticFringe(chromaticFringe:Float):Void {
		this._chromaticFringe = chromaticFringe;
		this.uniform("chromaticFringe").floatValue = this._chromaticFringe;
	}

	public function setEdgeBias(edgeBias:Float):Void {
		this._edgeBias = edgeBias;
		this.uniform("edgeBias").floatValue = this._edgeBias;
	}

	public function setDither(dither:Float):Void {
		this._dither = dither;
		this.uniform("dither").floatValue = this._dither;
	}
}
