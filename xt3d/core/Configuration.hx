package xt3d.core;

import xt3d.utils.errors.XTException;
import xt3d.utils.XT;
import xt3d.gl.XTGL;
class Configuration {

	// members
	private var _configuration:Map<String, String> = [
		XT.MAX_LIGHTS => "4",
		XT.SHADER_PRECISION => XTGL.MEDIUM_PRECISION,
		XT.DEFAULT_FPS => "60.0"
	];

	public static function create(userConfiguration:Map<String, String> = null):Configuration {
		var object = new Configuration();

		if (object != null && !(object.init(userConfiguration))) {
			object = null;
		}

		return object;
	}

	public function init(userConfiguration:Map<String, String> = null):Bool {
		if (userConfiguration != null) {
			// Override default configuration with user values
			for (key in userConfiguration.keys()) {
				this._configuration.set(key, userConfiguration.get(key));
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

			return Std.parseInt(stringValue);
		}

		throw new XTException("KeyDoesNotExist", "No value for the key \"" + key + "\" exists in the configuration");
	}

	public function getFloat(key:String):Float {
		if (this._configuration.exists(key)) {
			var stringValue = this._configuration.get(key);

			return Std.parseFloat(stringValue);
		}

		throw new XTException("KeyDoesNotExist", "No value for the key \"" + key + "\" exists in the configuration");
	}

}
