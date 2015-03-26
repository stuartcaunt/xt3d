package kfsgl.core;

/**
 * Used to mask if we immediately use:
 *  - an ArrayBuffer to hold vertex data, avoiding copying data but maybe slower access
 *  - a standard Array object, doubling data usage but maybe easier access
 **/
import openfl.utils.Float32Array;
import flash.utils.ByteArray;
import openfl.utils.ArrayBufferView;
import openfl.gl.GL;
class InterlacedVertexData<T> extends VertexData {

	private var _array:Array<Float> = new Array<Float>();

	public function new(interleavedDataStructure:Map<String, Int>) {
		super();
	}

	override public function getLength():Int {
		return this._array.length;
	}

//	public function getByteLength():Int {
//		return getLength() * sizeof(T);
//	}

	override public function bufferData():Void {

		var tmp:ByteArray = new ByteArray();

		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(_array), GL.STATIC_DRAW);
	}



}
