package ;

import kfsgl.primitives.Plane;
import kfsgl.node.Light;
import kfsgl.utils.KF;
import kfsgl.Director;
import openfl.geom.Vector3D;
import kfsgl.node.MeshNode;
import kfsgl.primitives.Plane;
import kfsgl.core.Material;
import kfsgl.textures.RenderTexture;
import kfsgl.utils.Size;
import kfsgl.textures.Texture2D;
import kfsgl.primitives.Sphere;
import kfsgl.node.Node3D;
import kfsgl.core.View;
import kfsgl.utils.Color;

class TestGouraud2 extends View {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _meshNode:Node3D;
	private var _light:Light;

	private var _t:Float = 0.0;

	public static function create(backgroundColor:Color):TestGouraud2 {
		var object = new TestGouraud2();

		if (object != null && !(object.init(backgroundColor))) {
			object = null;
		}

		return object;
	}

	public function init(backgroundColor:Color):Bool {
		var retval;
		if ((retval = super.initBasic3D())) {

			var director:Director = Director.current;

			this.backgroundColor = backgroundColor;

			// Create a camera and set it in the view
			var cameraDistance:Float = 90.0;
			this.camera.position = new Vector3D(0, 0, cameraDistance);

			this._containerNode = Node3D.create();
			this.scene.addChild(this._containerNode);

			// create geometries
			var geometry = Plane.create(50.0, 50.0, 64, 64);

			// Create a material
			var material:Material = Material.create("generic_gouraud");
			material.uniform("color").floatArrayValue = Color.createWithRGBHex(0x555599).rgbaArray;

			// Create sphere mesh node
			this._meshNode = MeshNode.create(geometry, material);
			this._containerNode.addChild(this._meshNode);

			this._light = Light.createSpotLight();
			this._light.position = new Vector3D(0.0, 0.0, 20.0);
			this._light.direction = new Vector3D(0.0, 0.0, -1.0);
			this._light.spotCutoffAngle = 30.0;
			this._light.spotFalloffExponent = 1.0;
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

		this._light.direction = new Vector3D(x, 0.0, -1.0);
	}

}
