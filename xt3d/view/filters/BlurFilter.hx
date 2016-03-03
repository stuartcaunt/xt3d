package xt3d.view.filters;

import xt3d.material.BlurMaterial;
import xt3d.material.Material;

class BlurFilter extends BasicViewFilter {

	// properties

	// members
	private var _blurMaterial:BlurMaterial;
	private var _isHorizontal:Bool;

	public static function create(filteredView:View):BlurFilter {
		var horizontalBlur = BlurFilter.createHorizontal(filteredView);
		if (horizontalBlur != null) {
			return BlurFilter.createVertical(horizontalBlur);
		}

		return null;
	}

	public static function createHorizontal(filteredView:View):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, true))) {
			object = null;
		}

		return object;
	}

	public static function createVertical(filteredView:View):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, false))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, isHorizontal:Bool):Bool {
		this._isHorizontal = isHorizontal;
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView))) {
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override private function createRenderNodeMaterial():Material {
		// Create the blur material
		this._blurMaterial = BlurMaterial.create(this._isHorizontal);

		return this._blurMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Set the texture in the material
		this._blurMaterial.setTexture(this._renderTexture);
	}

}

