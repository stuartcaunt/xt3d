package kfsgl.utils;

class CountedObject {

	// properties
	public var retainCount(get, null):Int;

	// members
	private var _retainCount:Int = 0;

	public function new() {

	}


	/* ----------- Properties ----------- */

	public inline function get_retainCount():Int {
		return this._retainCount;
	}

	/* --------- Implementation --------- */

	public inline function retain():Void {
		this._retainCount++;
	}

	public inline function release():Void {
		this._retainCount--;
	}

}
