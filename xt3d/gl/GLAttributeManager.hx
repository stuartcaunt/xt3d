package xt3d.gl;

import xt3d.gl.GLCurrentContext.GL;

typedef AttributeState = {
	var location:Int;
	var used:Bool;
	var enabled:Bool;
};


class GLAttributeManager {

	// properties

	// members
	private var _attributeStates:Array<AttributeState> = new Array<AttributeState>();
	private var _glInfo:GLInfo;

	public static function create(glInfo:GLInfo):GLAttributeManager {
		var object = new GLAttributeManager();

		if (object != null && !(object.init(glInfo))) {
			object = null;
		}

		return object;
	}

	public function init(glInfo:GLInfo):Bool {
		this._glInfo = glInfo;
		for (i in 0 ... this._glInfo.maxVertexAttribs) {
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
			attributeState.enabled = true;
		}

	}

	public function disableUnusedAttributes():Void {
		for (attributeState in this._attributeStates) {
			if (!attributeState.used && attributeState.enabled) {
				GL.disableVertexAttribArray(attributeState.location);
				attributeState.enabled = false;
			}
		}
	}

}
