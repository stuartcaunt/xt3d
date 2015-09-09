package xt3d.utils.general;

import xt3d.utils.string.StringFunctions;
class FPSCalculator {

	// properties
	public var fps(get, null):Float;

	// members
	private static var N_TICKS:Int = 20;
	private static var N_TICKS_TO_OUTPUT:Int = 60;
	private var _deltaTimes:Array<Float> = new Array<Float>();
	private var _tickIndex:Int = 0;
	private var _outputTickIndex:Int = 0;
	private var _fps:Float = 0.0;

	public static function create():FPSCalculator {
		var object = new FPSCalculator();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		for (i in 0 ... N_TICKS){
			this._deltaTimes[i] = 0.0;
		}

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	public inline function get_fps():Float {
		return this._fps;
	}


	/* --------- Implementation --------- */

	public function update(dt:Float):Void {
		this._deltaTimes[this._tickIndex] = dt;
		this._tickIndex++;
		this._outputTickIndex++;

		if (this._tickIndex >= N_TICKS) {
			this._tickIndex = 0;
		}

		if (this._outputTickIndex == N_TICKS_TO_OUTPUT) {
			this._outputTickIndex = 0;

			var total:Float = 0.0;
			for (i in 0 ... N_TICKS) {
				total += this._deltaTimes[i];
			}
			total /= N_TICKS;

			this._fps =1.0 / total;

			XT.Log("fps : " + StringFunctions.floatToStringNumberOfDp(this._fps, 1));
		}
	}

}
