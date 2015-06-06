package kfsgl.core;

import kfsgl.utils.KF;
import kfsgl.utils.KFObject;

typedef UpdatableElement = {
	var target:KFObject;
	var paused:Bool;
	var markedForDeletion:Bool;
};

typedef ScheduledTimer = {
	var target:KFObject;
	var callback:Float->Void;
	var runForever:Bool;
	var useDelay:Bool;
	var delay:Float;
	var interval:Float;
	var elapsedTime:Float;
	var timesExecuted:UInt;
	var repeat:UInt;
};

typedef TimerElement = {
	var target:KFObject;
	var timers:Array<ScheduledTimer>;
	var paused:Bool;
	var currentTimerIndex:Int;
	var markedForDeletion:Bool;
};


class Scheduler {

	// properties
	public var timeScale(get, set):Float;

	// members
	private var _scheduledUpdatesMap:Map<KFObject, UpdatableElement> = new Map<KFObject, UpdatableElement>();
	private var _scheduledUpdatesToAdd:Array<UpdatableElement> = new Array<UpdatableElement>();
	private var _scheduledUpdatesMapLocked:Bool = false;
	private var _scheduledTimersMap:Map<KFObject, TimerElement> = new Map<KFObject, TimerElement>();
	private var _timeScale:Float = 1.0;
	private var _currentTimerTarget:KFObject = null;
	private var _currentTimerTargetMarkedForDeletion:Bool = false;

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

	public function schedule(target:KFObject, callback:Float->Void, interval:Float = 0.0, delay:Float = 0.0, repeat:UInt = KF.RepeatForever, paused:Bool = false):Void {
		if (target == null || callback == null) {
			return;
		}

		// Find TimerElement corresponding to target
		var timerElement:TimerElement = null;
		if (!this._scheduledTimersMap.exists(target)) {
			timerElement = {
				target: target,
				timers: new Array<ScheduledTimer>(),
				paused: paused,
				currentTimerIndex: -1,
				markedForDeletion: false
			};
			this._scheduledTimersMap.set(target, timerElement);

		} else {
			timerElement = this._scheduledTimersMap.get(target);
		}

		// Check if timer exists
		for (scheduledTimer in timerElement.timers) {
			if (Reflect.compareMethods(scheduledTimer.callback, callback)) {
				KF.Log("Scheduler.schedule : Callback already scheduled. Updating interval from " + scheduledTimer.interval + " to " + interval);
				scheduledTimer.interval = interval;
				return;
			}
		}

		// Create new ScheduledTime
		var scheduledTimer:ScheduledTimer = {
			target: target,
			callback: callback,
			runForever: (repeat == KF.RepeatForever) ? true : false,
			useDelay: (delay > 0.0) ? true : false,
			delay: delay,
			interval: interval,
			elapsedTime: -1.0,
			timesExecuted: 0,
			repeat: repeat
		};

		timerElement.timers.push(scheduledTimer);
	}

	public function unschedule(target:KFObject, callback:Float->Void):Void {
		if (target == null || callback == null) {
			return;
		}

		// Find TimerElement corresponding to target
		if (this._scheduledTimersMap.exists(target)) {
			var timerElement:TimerElement = this._scheduledTimersMap.get(target);

			// Find timer for callback
			for (i in 0 ... timerElement.timers.length) {
				var timer:ScheduledTimer = timerElement.timers[i];

				// Check if callback matched
				if (Reflect.compareMethods(timer.callback, callback)) {

					// Remove time
					timerElement.timers.remove(timer);

					// Check if we are currently updating
					if (timerElement.currentTimerIndex >= i) {
						timerElement.currentTimerIndex--;
					}

					// Remove target?
					if (timerElement.timers.length == 0) {
						if (this._currentTimerTarget == target) {
							this._currentTimerTargetMarkedForDeletion = true;

						} else {
							this._scheduledTimersMap.remove(target);
						}
					}

					return;
				}

			}
		}
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

		// Check for timers
		if (this._scheduledTimersMap.exists(target)) {

			// Mark as paused
			var timerElement:TimerElement = this._scheduledTimersMap.get(target);
			timerElement.paused = true;
		}

		// Check if exists for update
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

		// Check for timers
		if (this._scheduledTimersMap.exists(target)) {

			// Mark as paused
			var timerElement:TimerElement = this._scheduledTimersMap.get(target);
			timerElement.paused = false;
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

		// Iterate over timers
		for (timerElement in this._scheduledTimersMap) {
			this._currentTimerTarget = timerElement.target;
			this._currentTimerTargetMarkedForDeletion = false;

			if (!timerElement.paused) {
				timerElement.currentTimerIndex = 0;
				while (timerElement.currentTimerIndex < timerElement.timers.length) {
					var timer:ScheduledTimer = timerElement.timers[timerElement.currentTimerIndex];

					this.updateTimer(timer, dt);

					timerElement.currentTimerIndex++;
				}
			}

			// Check if we should delete the target
			if (this._currentTimerTargetMarkedForDeletion) {
				timerElement.markedForDeletion = true;
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

		// Remove timers marked for deletion
		var targets = this._scheduledTimersMap.keys();
		while (targets.hasNext()) {
			var target = targets.next();
			var timer = this._scheduledTimersMap.get(target);
			if (timer.markedForDeletion) {
				this._scheduledTimersMap.remove(target);
			}
		}

		// Unlock modifications to the updates map
		this._scheduledUpdatesMapLocked = false;
	}

	private function updateTimer(timer:ScheduledTimer, dt:Float) {
		if (timer.elapsedTime < 0.0) {
			// Initialise on first execution since possibly added during an update cycle
			timer.elapsedTime = 0.0;
			timer.timesExecuted = 0;

		} else if (timer.runForever && !timer.useDelay) {
			// Standard timer
			timer.elapsedTime += dt;

			if (timer.elapsedTime >= timer.interval) {
				// Perform callback
				timer.callback(timer.elapsedTime);

				// Reset timer
				timer.elapsedTime = 0.0;
			}


		} else {
			timer.elapsedTime +=dt;

			if (timer.useDelay) {
				// Handle delay time before executing callback
				if (timer.elapsedTime > timer.delay) {
					// Perform callback
					timer.callback(timer.elapsedTime);

					timer.useDelay = false;
					timer.elapsedTime -= timer.delay;
					timer.timesExecuted++;
				}

			} else {
				// Handle timer interval
				if (timer.elapsedTime > timer.interval) {
					// Perform callback
					timer.callback(timer.elapsedTime);

					timer.elapsedTime = 0.0;
					timer.timesExecuted++;
				}
			}

			// Check if timer terminated and remove from scheduler
			if (timer.timesExecuted > timer.repeat) {
				this.unschedule(timer.target, timer.callback);
			}

		}
	}

}
