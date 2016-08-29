package xt3d.core;

import xt3d.utils.XTObject;

class EventEmitter extends XTObject {

	private var _listeners:Map<String, Array<Void->Void> > = new Map<String, Array<Void->Void> >();

	public function new() {
		super();
	}

	public function on(event:String, callback:Void->Void) {
		var callbacks = _listeners.get(event);
		if (callbacks == null) {
			callbacks = new Array<Void->Void>();
			_listeners.set(event, callbacks);
		}
		callbacks.push(callback);
	}

	public function removeListener(event:String, callback:Void->Void) {
		var callbacks = _listeners.get(event);

		// Remove callback in array
		var index = callbacks.indexOf(callback);
		if (index >= 0) {
			callbacks.splice(index, 1);
		}
	}


	private function emit(event:String) {
		var callbacks = _listeners.get(event);
		if (callbacks != null) {
			for (callback in callbacks) {
				callback();
			}
		}
	}

}
