package xt3d.material;

import xt3d.gl.shaders.UniformLib;
class DepthMaterial extends Material {

	public var near(get, null):Float;
	public var far(get, null):Float;

	private var _near:Float;
	private var _far:Float;

	public static function create():DepthMaterial {
		var object = new DepthMaterial();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var isOk;
		if ((isOk = super.initMaterial("depth"))) {
		}

		return isOk;
	}

	inline function get_near():Float {
		return this._near;
	}

	inline function get_far():Float {
		return this._far;
	}

	override public function updateProgramUniforms(uniformLib:UniformLib):Void {
		super.updateProgramUniforms(uniformLib);

		// Store the near and far values used for the rendering
		this._near = uniformLib.uniform("near").floatValue;
		this._far = uniformLib.uniform("far").floatValue;
	}

}
