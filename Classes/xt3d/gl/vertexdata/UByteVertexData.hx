package xt3d.gl.vertexdata;

import xt3d.utils.errors.XTException;
import xt3d.gl.vertexdata.PrimitiveVertexData;
import lime.utils.UInt8Array;
import lime.utils.ArrayBufferView;
import lime.graphics.opengl.GL;

class UByteVertexData extends PrimitiveVertexData {

	// properties

	// members
	private var _ui8Array:UInt8Array = null;
	private var _fixedCapacity:Int = 0;
	private var _nextIndex:Int = 0;

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

	public static function createWithFixedCapacity(fixedCapacity:Int, attributeName:String, vertexSize:Int):UByteVertexData {
		var object = new UByteVertexData();

		if (object != null && !(object.initWithFixedCapacity(fixedCapacity, attributeName, vertexSize))) {
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

	public function initWithFixedCapacity(fixedCapacity:Int, attributeName:String, vertexSize:Int):Bool {
		var retval;
		if ((retval = super.initPrimitiveVertexData(attributeName, vertexSize))) {
			this._ui8Array = new UInt8Array(fixedCapacity);
			this._fixedCapacity = fixedCapacity;
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
		if (this._ui8Array != null) {
			return this._nextIndex;
		} else {
			return this._array.length;
		}
	}


	override public function getBufferData():ArrayBufferView {
		if (this._ui8Array != null) {
			return this._ui8Array;
		} else {
			return new UInt8Array(this._array);
		}
	}

	override public function bindToAttribute(attributeLocation:Int, bufferManager:GLBufferManager):Void {
		// Bind the buffer
		bufferManager.setVertexBuffer(this._buffer);

		// attach buffer to attribute
		GL.vertexAttribPointer(attributeLocation, this._vertexSize, GL.UNSIGNED_BYTE, true, 0, 0);
	}

	public inline function set(index:Int, value:UInt):Void {
		if (this._ui8Array != null) {
			this.handleIndex(index, true);
			this._ui8Array[this._nextIndex++] = value;

		} else {
			this._array[index] = value;
		}
		this._isDirty = true;
	}

	public inline function get(index:Int):UInt {
		if (this._ui8Array != null) {
			this.handleIndex(index, false);
			return this._ui8Array[index];

		} else {
			return _array[index];
		}
	}

	public inline function push(value:UInt):Void {
		if (this._ui8Array != null) {
			this.handleIndex(this._nextIndex, false);
			this._ui8Array[this._nextIndex++] = value;

		} else {
			_array.push(value);
		}
		this._isDirty = true;
	}

	public inline function pop():UInt {
		if (this._ui8Array != null) {
			if (this._nextIndex <= 0) {
				throw new XTException("IndexOutOfBounds", "Cannot pop from empty array");
			}
			this._nextIndex--;

			this._isDirty = true;
			return this._ui8Array[this._nextIndex];

		} else {
			this._isDirty = true;
			return _array.pop();
		}
	}

	private inline function handleIndex(index:Int, updateNextIndex:Bool):Void {
		if (index >= this._fixedCapacity) {
			throw new XTException("IndexOutOfBounds", "The index " + index + " is outside the fixed capacity of " + this._fixedCapacity);
		}
		if (updateNextIndex && index > this._nextIndex) {
			this._nextIndex = index;
		}
	}


}
