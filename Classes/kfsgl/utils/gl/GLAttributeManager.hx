package kfsgl.utils.gl;

import openfl.gl.GL;

typedef AttributeState = {
	var location:Int;
	var used:Bool;
	var enabled:Bool;
};


class GLAttributeManager {

	// properties

	// members
	private static var MAX_ATTRIBUTES = 16;
	private var _attributeStates:Array<AttributeState> = new Array<AttributeState>();

	public static function create():GLAttributeManager {
		var object = new GLAttributeManager();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		for (i in 0 ... MAX_ATTRIBUTES) {
			var attributeState:AttributeState = { location:i, used:false, enabled:false };
			_attributeStates.push(attributeState);
		}

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function initForRenderObject():Void {
		for (attributeState in this._attributeStates) {
			attributeState.used = false;
		}
	}

	public function enableAttribute(attributeLocation:Int):Void {
		var attributeState = this._attributeStates[attributeLocation];
		attributeState.used = true;
		if (attributeState.enabled == false) {

			GL.enableVertexAttribArray(attributeLocation);
			attributeState.enabled == true;
		}

	}

	public function disableUnusedAttributes():Void {
		for (attributeState in this._attributeStates) {
			if (!attributeState.used && attributeState.enabled) {
				GL.disableVertexAttribArray(attributeState.location);
				attributeState.enabled == false;
			}
		}
	}

}
