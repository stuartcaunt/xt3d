package xt3d.view.filters;

import xt3d.material.filter.BlurMaterial;
import xt3d.material.Material;

class BlurFilter extends BasicViewFilter {

	// properties

	// members
	private var _blurMaterial:BlurMaterial;
	private var _isHorizontal:Bool;
	private var _blur:Float;

	public static function create(filteredView:View, blur:Float = 1.0):BlurFilter {
		var horizontalBlur = BlurFilter.createHorizontal(filteredView, blur);
		if (horizontalBlur != null) {
			return BlurFilter.createVertical(horizontalBlur, blur);
		}

		return null;
	}

	public static function createHorizontal(filteredView:View, blur:Float = 1.0):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, blur, true))) {
			object = null;
		}

		return object;
	}

	public static function createVertical(filteredView:View, blur:Float = 1.0):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, blur, false))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, blur:Float = 1.0, isHorizontal:Bool):Bool {
		this._isHorizontal = isHorizontal;
		this._blur = blur;
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView, this.getScaleForBlur(blur)))) {
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


//	1.3  1.3  1.0
//	2.5  1.5  0.5
//	3.3  1.3  0.33
//	6.7  1.7  1/6

	private function getScaleForBlur(blur:Float):Float {
		var scale = 1.0;
		if (blur >= 2.0) {

			scale = 1.0 / Math.floor(blur);
		}

		return scale;
	}

	private function getMaterialBlurForFilterBlur(blur:Float):Float {
		var materialBlur = blur;
		if (blur >= 2.0) {
			materialBlur = blur - Math.floor(blur) + 1.0;
		}

		return materialBlur;
	}


	override private function createRenderNodeMaterial():Material {
		// Create the blur material
		this._blurMaterial = BlurMaterial.create(this._isHorizontal);

		return this._blurMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Set the texture in the material
		this._blurMaterial.texture = this._renderTexture;

		// Set the blur spread
		this._blurMaterial.spread = this.getMaterialBlurForFilterBlur(this._blur);
	}

}

