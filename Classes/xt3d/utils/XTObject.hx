package xt3d.utils;

class XTObject {

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
	public function scheduleUpdate():Void {
		Director.current.scheduler.scheduleUpdate(this);
	}

	public function unscheduleUpdate():Void {
		Director.current.scheduler.unscheduleUpdate(this);
	}

	public function pauseScheduler():Void {
		Director.current.scheduler.pauseTarget(this);
	}

	public function resumeScheduler():Void {
		Director.current.scheduler.resumeTarget(this);
	}

	public function schedule(callback:Float->Void, interval:Float = 0.0, delay:Float = 0.0, repeat:UInt = XT.RepeatForever, paused:Bool = false):Void {
		Director.current.scheduler.schedule(this, callback, interval, delay, repeat, paused);
	}

	public function scheduleOnce(callback:Float->Void, delay:Float = 0.):Void {
		Director.current.scheduler.schedule(this, callback, 0.0, delay, 0);
	}

	public function unschedule(callback:Float->Void):Void {
		Director.current.scheduler.unschedule(this, callback);
	}

	public function unscheduleAll():Void {
		Director.current.scheduler.unscheduleAllForTarget(this);
	}

}
