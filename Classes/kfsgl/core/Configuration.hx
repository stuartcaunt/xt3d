package kfsgl.core;

class Configuration {

	// members
	private var _configuration:Map<String, String> = new Map<String, String>();

	public static function create(configuration:Map<String, String> = null):Configuration {
		var object = new Configuration();

		if (object != null && !(object.init(configuration))) {
			object = null;
		}

		return object;
	}

	public function init(configuration:Map<String, String> = null):Bool {
		if (configuration != null) {
			// Clone config
			for (key in configuration.keys()) {
				this._configuration.set(key, configuration.get(key));
			}
		}

		return true;
	}


	public function new() {
	}


	/* --------- Implementation --------- */

	public function get(key:String):String {
		return this._configuration.get(key);
	}

	public function getInt(key:String):Int {
		if (this._configuration.exists(key)) {
			var stringValue = this._configuration.get(key);

			var intValue:Int = Std.parseInt(stringValue);
			if (intValue == Math.NaN) {
				return null;

			} else {
				return intValue;
			}
		}

		return null;
	}

	public function getFloat(key:String):Float {
		if (this._configuration.exists(key)) {
			var stringValue = this._configuration.get(key);

			var floatValue:Float = Std.parseFloat(stringValue);
			if (floatValue == Math.NaN) {
				return null;

			} else {
				return floatValue;
			}
		}

		return null;
	}

}
