package xt3d.view.filters;

import xt3d.material.filter.BlurMaterial;
import xt3d.material.Material;

class BlurFilter extends BasicViewFilter {

	// properties

	// members
	private var _blurMaterial:BlurMaterial;
	private var _isHorizontal:Bool;

	public static function create(filteredView:View, scale:Float = 1.0):BlurFilter {
		var horizontalBlur = BlurFilter.createHorizontal(filteredView, scale);
		if (horizontalBlur != null) {
			return BlurFilter.createVertical(horizontalBlur, scale);
		}

		return null;
	}

	public static function createHorizontal(filteredView:View, scale:Float = 1.0):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, scale, true))) {
			object = null;
		}

		return object;
	}

	public static function createVertical(filteredView:View, scale:Float = 1.0):BlurFilter {
		var object = new BlurFilter();

		if (object != null && !(object.init(filteredView, scale, false))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View, scale:Float = 1.0, isHorizontal:Bool):Bool {
		this._isHorizontal = isHorizontal;
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView, scale))) {
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

