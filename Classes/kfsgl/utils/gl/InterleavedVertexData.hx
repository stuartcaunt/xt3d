package kfsgl.utils.gl;

/**
 * Used to mask if we immediately use:
 *  - an ArrayBuffer to hold vertex data, avoiding copying data but maybe slower access
 *  - a standard Array object, doubling data usage but maybe easier access
 **/
import openfl.utils.IMemoryRange;
import openfl.utils.Float32Array;
import openfl.gl.GL;
class InterleavedVertexData<T> extends VertexData {

	private var _array:Array<Float> = new Array<Float>();

	public function new(interleavedDataStructure:Map<String, Int>) {
		super();
	}

	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */



//	public function getByteLength():Int {
//		return getLength() * sizeof(T);
//	}

	override public function getBufferData():IMemoryRange {
#if use_float32array
		return _f32Array;
#else
		return new Float32Array(_array);
#end
	}

}
