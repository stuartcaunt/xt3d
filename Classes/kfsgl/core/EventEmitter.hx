package kfsgl.core;

class EventEmitter {

	private var _listeners:Map<String, Array<Void->Void> > = new Map<String, Array<Void->Void> >();

	public function new() {
	}

	public function on(event:String, callback:Void->Void) {
		var callbacks = _listeners.get(event);
		if (callbacks == null) {
			callbacks = new Array<Void->Void>();
			_listeners.set(event, callbacks);
		}
		callbacks.push(callback);
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
