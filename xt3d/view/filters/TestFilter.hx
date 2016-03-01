package xt3d.view.filters;

import xt3d.material.TextureMaterial;
import xt3d.utils.color.Color;
import xt3d.material.Material;

class TestFilter extends BasicViewFilter {

	// properties

	// members
	private var _filterMaterial:TextureMaterial;

	public static function create(filteredView:View):TestFilter {
		var object = new TestFilter();

		if (object != null && !(object.init(filteredView))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View):Bool {
		var ok;
		if ((ok = super.initBasicViewFilter(filteredView))) {
		}

		return ok;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override private function createRenderNodeMaterial():Material {
		// Override in all filters

		this._filterMaterial = TextureMaterial.createWithColor(Color.createWithRGBHex(0xffffff));

		return this._filterMaterial;
	}

	override private function updateRenderMaterials():Void {
		// Override in all Filters

		// Set the texture in the material
		this._filterMaterial.texture = this._renderTexture;
	}

}
