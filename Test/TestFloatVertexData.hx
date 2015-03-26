package;

import kfsgl.core.FloatVertexData;
import openfl.display.Sprite;

class TestFloatVertexData extends Sprite {

	public function new () {
		super ();

		var floatData = new FloatVertexData();

		for (i in 0...10) {
			floatData.push(i * 10.0);

		}

	}
	
}