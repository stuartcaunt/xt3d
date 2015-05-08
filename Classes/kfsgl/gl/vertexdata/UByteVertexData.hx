package kfsgl.gl.vertexdata;

import kfsgl.gl.vertexdata.PrimitiveVertexData;
import openfl.utils.UInt8Array;
import openfl.utils.ArrayBufferView;
import openfl.gl.GL;

class UByteVertexData extends PrimitiveVertexData {

	// properties

	// members
	private var _array:Array<UInt> = new Array<UInt>();

	public static function create(attributeName:String, vertexSize:Int):UByteVertexData {
		var object = new UByteVertexData();

		if (object != null && !(object.init(attributeName, vertexSize))) {
			object = null;
		}

		return object;
	}

	public static function createWithArray(attributeName:String, array:Array<UInt>, vertexSize:Int):UByteVertexData {
		var object = new UByteVertexData();

		if (object != null && !(object.initWithArray(attributeName, array, vertexSize))) {
			object = null;
		}

		return object;
	}

	public function init(attributeName:String, vertexSize:Int):Bool {
		var retval;
		if ((retval = super.initPrimitiveVertexData(attributeName, vertexSize))) {
		}

		return retval;
	}

	public function initWithArray(attributeName:String, array:Array<UInt>, vertexSize:Int):Bool {
		var retval;
		if ((retval = super.initPrimitiveVertexData(attributeName, vertexSize))) {
			this._array = array;
		}

		return retval;
	}


	public function new() {
		super();
	}

	/* ----------- Properties ----------- */



	/* --------- Implementation --------- */

	// Number of elements
	override public function getLength():Int {
		return this._array.length;
	}


	override public function getBufferData():ArrayBufferView {
		return new UInt8Array(this._array);
	}

	override public function bindToAttribute(attributeLocation:Int, bufferManager:GLBufferManager):Void {
		// Bind the buffer
		bufferManager.setVertexBuffer(this._buffer);

		// attach buffer to attribute
		GL.vertexAttribPointer(attributeLocation, this._vertexSize, GL.UNSIGNED_BYTE, true, 0, 0);
	}


	public inline function set(index:Int, value:UInt):Void {
		_array[index] = value;
		this._isDirty = true;
	}

	public inline function get(index:Int):UInt {
		return _array[index];
	}

	public inline function push(value:UInt):Void {
		_array.push(value);
		this._isDirty = true;
	}

	public inline function pop():UInt {
		return _array.pop();
		this._isDirty = true;
	}

}
