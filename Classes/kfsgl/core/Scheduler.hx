package kfsgl.core;

import kfsgl.utils.KFObject;

typedef UpdatableElement = {
	var target:KFObject;
	var paused:Bool;
	var markedForDeletion:Bool;
};

typedef ScheduledTimer = {
	var target:KFObject;
	var paused:Bool;
	var markedForDeletion:Bool;
};


class Scheduler {

	// properties
	public var timeScale(get, set):Float;

	// members
	private var _scheduledUpdatesMap:Map<KFObject, UpdatableElement> = new Map<KFObject, UpdatableElement>();
	private var _scheduledUpdatesToAdd:Array<UpdatableElement> = new Array<UpdatableElement>();
	private var _scheduledUpdatesMapLocked:Bool = false;
	private var _timeScale:Float = 1.0;

	public static function create():Scheduler {
		var object = new Scheduler();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	public inline function get_timeScale():Float {
		return this._timeScale;
	}

	public inline function set_timeScale(value:Float) {
		return this._timeScale = value;
	}



	/* --------- Implementation --------- */

	public function schedule(target:KFObject, callback:Float->Void):Void {

	}

	public function scheduleUpdate(target:KFObject):Void {
		if (target == null) {
			return;
		}

		// Add if not already added
		if (!this._scheduledUpdatesMap.exists(target)) {

			var updatableElement = {
				target: target,
				paused: false,
				markedForDeletion: false
			};

			// Check if locked or not
			if (this._scheduledUpdatesMapLocked) {
				// Add later
				this._scheduledUpdatesToAdd.push(updatableElement);

			} else {
				// Add now
				this._scheduledUpdatesMap.set(target, updatableElement);
			}

		}

	}

	public function unscheduleUpdate(target:KFObject):Void {
		if (target == null) {
			return;
		}

		// Remove if exists
		if (this._scheduledUpdatesMap.exists(target)) {

			// Check if locked or not
			if (this._scheduledUpdatesMapLocked) {
				// Mark for removable
				var updatableElement = this._scheduledUpdatesMap.get(target);
				updatableElement.markedForDeletion = true;

			} else {
				// Remove now
				this._scheduledUpdatesMap.remove(target);
			}

		}
	}

	public function pauseTarget(target:KFObject):Void {
		if (target == null) {
			return;
		}

		// Check if exists
		if (this._scheduledUpdatesMap.exists(target)) {

			// Mark as paused
			var updatableElement = this._scheduledUpdatesMap.get(target);
			updatableElement.paused = true;
		}
	}

	public function resumeTarget(target:KFObject):Void {
		if (target == null) {
			return;
		}

		// Check if exists
		if (this._scheduledUpdatesMap.exists(target)) {

			// Mark as paused
			var updatableElement = this._scheduledUpdatesMap.get(target);
			updatableElement.paused = false;
		}
	}

	public function update(dt:Float):Void {
		// Lock modifications to the updates map
		this._scheduledUpdatesMapLocked = true;

		if (this._timeScale != 1.0) {
			dt *= this._timeScale;
		}

		// Iterate over updatables
		for (updatableElement in this._scheduledUpdatesMap) {
			if (!updatableElement.paused && !updatableElement.markedForDeletion) {
				updatableElement.target.update(dt);
			}
		}

		// Remove updates marked for deletion
		var targets = this._scheduledUpdatesMap.keys();
		while (targets.hasNext()) {
			var target = targets.next();
			var updatable = this._scheduledUpdatesMap.get(target);
			if (updatable.markedForDeletion) {
				this._scheduledUpdatesMap.remove(target);
			}
		}

		// Add new updates
		for (updatableElement in this._scheduledUpdatesToAdd) {
			// Add now
			this._scheduledUpdatesMap.set(updatableElement.target, updatableElement);
		}
		this._scheduledUpdatesToAdd = new Array<UpdatableElement>();

		// Unlock modifications to the updates map
		this._scheduledUpdatesMapLocked = false;
	}

}
