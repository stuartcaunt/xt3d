package ;

import openfl.events.Event;
import kfsgl.utils.KF;
import openfl.display.Stage3D;
import openfl.display.Stage;
import openfl.geom.Rectangle;
import openfl.display.Sprite;

class TestContext3D extends Sprite {

	// members
	var _stage3D:Stage3D;


	public function new() {
		super();

		var stageWidth:Int  = 320;
		var stageHeight:Int = 480;

		var viewport:Rectangle = new Rectangle(0, 0, stageWidth, stageHeight);


		var stage3D = this.createContext3D(stage, viewport, this.onContextCreated);
	}

	private function onContextCreated():Void {
		KF.Log("Context created");
	}

	/* --------- Implementation --------- */

	private function createContext3D(stage:Stage, viewport:Rectangle, callback:Void->Void):Stage3D {

		var stage3DsLength = stage.stage3Ds.length;
		KF.Log("Number of stage3Ds = " + stage3DsLength);

		var stage3D:Stage3D = stage.stage3Ds[0];

		stage3D.addEventListener(Event.CONTEXT3D_CREATE, callback, false, 1000, false);

		stage3D.requestContext3D(Std.string(renderMode));

		return stage3D;
	}

}
