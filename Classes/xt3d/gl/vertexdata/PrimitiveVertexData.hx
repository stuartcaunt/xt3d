package xt3d.gl.vertexdata;

import xt3d.utils.errors.XTAbstractMethodError;
import openfl.utils.ArrayBufferView;
import lime.graphics.opengl.GL;

class PrimitiveVertexData extends VertexData {

	// properties
	public var attributeName(get, null):String;
	public var vertexSize(get, null):Int;

	// members
	private var _attributeName:String;
	private var _vertexSize:Int; // number of elements per vertex

	public function initPrimitiveVertexData(attributeName:String, vertexSize:Int):Bool {
		var retval;
		if ((retval = super.initVertexData())) {
			this._attributeName = attributeName;
			this._vertexSize = vertexSize;
		}

		return retval;
	}

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */

	public inline function get_attributeName():String {
		return this._attributeName;
	}

	public inline function get_vertexSize():Int {
		return this._vertexSize;
	}


	/* --------- Implementation --------- */

	override public function getVertexCount():Int {
		return Std.int(this.getLength() / this._vertexSize);
	}

	public inline function getAttributeName():String {
		return this._attributeName;
	}

	public function bindToAttribute(attributeLocation:Int, bufferManager:GLBufferManager):Void {
		throw new XTAbstractMethodError();
	}

}
