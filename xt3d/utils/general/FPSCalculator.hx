package xt3d.utils.general;

import xt3d.core.Director;
import xt3d.font.BMFontLabel;
import xt3d.view.View;
import xt3d.node.Camera;
import xt3d.core.Renderer;
import lime.math.Rectangle;
import xt3d.utils.string.StringFunctions;
import lime.Assets;

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
	private var _view:View;
	private var _bmFontLabel:BMFontLabel;

	public static function create():FPSCalculator {
		var object = new FPSCalculator();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		this._view = View.createBasic2D();
		this._bmFontLabel = BMFontLabel.createWithText("", "xt3d-assets/fonts/fps.fnt");
		this._view.scene.addChild(this._bmFontLabel);

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

			//XT.Log("fps : " + StringFunctions.floatToStringNumberOfDp(this._fps, 1));
		}
	}

	public function render():Void {
		var director = Director.current;

		// Update viewport and ortho projection
		var displaySize = director.displaySize;
		this._view.displaySize = displaySize;
		this._view.camera.setOrthoProjection(0, displaySize.width, 0, displaySize.height, 1.0, 1000.0);

		// Update the text
		this._bmFontLabel.setText(StringFunctions.floatToStringNumberOfDp(this._fps, 1));
		var y = displaySize.height - this._bmFontLabel.contentSize.height;
		this._bmFontLabel.setPositionValues(8.0, y, 0.0);

		this._view.updateView();
		this._view.render();
	}
}
