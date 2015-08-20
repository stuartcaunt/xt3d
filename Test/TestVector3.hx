package ;


import xt3d.utils.math.Vector4;
import xt3d.utils.XT;
import xt3d.utils.math.Vector3;
import lime.app.Application;


class TestVector3 extends Application {

	public function new () {
		super();

		var a3:Vector3 = Vector3.createWithComponents(1.0, 2.0, 3.0);
		var b3:Vector3 = Vector3.createWithComponents(3.0, 2.0, 1.0);

		XT.Log("a3.b3 = " + a3.dot(b3));

		var a4:Vector4 = Vector4.createWithComponents(1.0, 2.0, 3.0, 4.0);
		var b4:Vector4 = Vector4.createWithComponents(4.0, 3.0, 2.0, 1.0);
		XT.Log("a4.b4 = " + a4.dot(b4));

	}

}