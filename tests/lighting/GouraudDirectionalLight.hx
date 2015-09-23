package ;

import xt3d.primitives.Plane;
import xt3d.node.Light;
import xt3d.core.Director;
import lime.math.Vector4;
import xt3d.node.MeshNode;
import xt3d.core.Material;
import xt3d.node.Node3D;
import xt3d.core.View;
import xt3d.utils.color.Color;


class GouraudDirectionalLight extends MainApplication {
	public function new () {
		super();
	}

	override public function createViews():Void {
		var view = GouraudDirectionalLightView.create();
		this._director.addView(view);
	}
}

class GouraudDirectionalLightView extends View {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _meshNode:Node3D;
	private var _light:Light;

	private var _t:Float = 0.0;

	public static function create():GouraudDirectionalLightView {
		var object = new GouraudDirectionalLightView();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var retval;
		if ((retval = super.initBasic3D())) {

			var director:Director = Director.current;

			this.backgroundColor = director.backgroundColor;

			// Create a camera and set it in the view
			var cameraDistance:Float = 90.0;
			this.camera.position = new Vector4(cameraDistance, 0, cameraDistance);

			this._containerNode = Node3D.create();
			this.scene.addChild(this._containerNode);

			// create geometries
			var geometry = Plane.create(100.0, 100.0, 4, 4);

			// Create a material
			var material:Material = Material.create("generic+gouraud");
			material.uniform("color").floatArrayValue = Color.createWithRGBHex(0x555599).rgbaArray;

			// Create sphere mesh node
			this._meshNode = MeshNode.create(geometry, material);
			this._containerNode.addChild(this._meshNode);

			this._light = Light.createDirectionalLight();
			this._light.direction = new Vector4(0.0, 0.0, -1.0);
			this._light.specularColor = Color.black;
			this._containerNode.addChild(this._light);

			// Schedule update
			this.scheduleUpdate();

		}
		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override public function update(dt:Float):Void {

		this._t += dt;

		var maxAngle:Float = 45.0;
		var angle:Float = Math.sin(_t * 2.0 * Math.PI / 4.0) * maxAngle;
		var x = Math.sin(angle * Math.PI / 180.0);

		this._light.direction = new Vector4(x, 0.0, -1.0);
	}

}
