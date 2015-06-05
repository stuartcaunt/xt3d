package kfsgl.utils;

class KFObject {

	// properties
	public var retainCount(get, null):Int;
	public var uid(get, null):Int;

	private static var UID_COUNTER = 0;
	private var _uid = UID_COUNTER++;
	private var _retainCount:Int = 0;

	public function new() {

	}


	/* ----------- Properties ----------- */

	public function get_uid():Int {
		return this._uid;
	}


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

	public function update(dt:Float):Void {
		// Method to be overridden to get automatic updates every frame if scheduleUpdate has been called
	}

}
