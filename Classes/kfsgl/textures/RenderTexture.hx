package kfsgl.textures;

import kfsgl.utils.Size;
import kfsgl.utils.Color;
import kfsgl.utils.KF;
import kfsgl.gl.GLTextureManager;
class RenderTexture extends Texture2D {

	// properties

	// members

	public static function create(size:Size<Int>, textureOptions:TextureOptions = null, textureManager:GLTextureManager = null):RenderTexture {
		var object = new RenderTexture();

		if (object != null && !(object.init(size, textureOptions, textureManager))) {
			object = null;
		}

		return object;
	}

	public function init(size:Size<Int>, textureOptions:TextureOptions = null, textureManager:GLTextureManager = null):Bool {
		var retval;
		if ((retval = super.initEmpty(size.width, size.height, textureOptions, textureManager))) {


		}

		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


	public function begin() {
		KF.Log("begin");
	}

	public function beginWithClear(clearColor:Color) {
		KF.Log("beginWithClear");
	}

	public function end() {
		KF.Log("end");
	}

}
