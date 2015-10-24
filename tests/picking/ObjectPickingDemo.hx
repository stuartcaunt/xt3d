package ;

import xt3d.gl.XTGL;
import xt3d.events.picking.ObjectPicker;
import xt3d.extras.CameraController;
import xt3d.utils.XT;
import xt3d.events.gestures.TapGestureRecognizer;
import xt3d.core.Director;
import xt3d.node.Light;
import lime.math.Vector4;
import xt3d.node.MeshNode;
import xt3d.core.Material;
import xt3d.textures.Texture2D;
import xt3d.primitives.Sphere;
import xt3d.node.Node3D;
import xt3d.core.View;
import xt3d.utils.color.Color;


class ObjectPickingDemo extends MainApplication {
	public function new () {
		super();
	}

	override public function createViews():Void {
		var view = ObjectPickingDemoView.create();
		this._director.addView(view);
	}


}


class ObjectPickingDemoView extends View implements TapGestureDelegate {

	// properties

	// members
	private var _container:Node3D;
	private var _objectPicker:ObjectPicker;
	private var _containerAngle:Float = 0.0;
	private var _sphereAngle:Float = 0.0;
	private var _whiteLight:Light;
	private var _redLight:Light;
	private var _blueLight:Light;
	private var _sphere1:MeshNode;
	private var _sphere2:MeshNode;

	public static function create():ObjectPickingDemoView {
		var object = new ObjectPickingDemoView();

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

			// Create scene
			this.createScene();

			// Create lights
			this.createLights();

			this._objectPicker = ObjectPicker.create();

			// Recognizers
			var tapGestureRecognizer = TapGestureRecognizer.create(this);
			this.scene.addChild(tapGestureRecognizer);

			var cameraController = CameraController.create(this._camera, 10.0);
			cameraController.cameraPosition = new Vector4(0.0, 2.0, 7.0);
			this.scene.addChild(cameraController);

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
		this._container.rotationY = this._containerAngle;

		this._sphere1.rotationY = this._sphereAngle;
		this._sphere2.rotationY = this._sphereAngle;

		this._sphereAngle = this._sphereAngle + 1;
		this._containerAngle = this._containerAngle + 1;
	}


	private function createScene():Void {
		var director:Director = Director.current;

		this._container = Node3D.create();
		this.scene.addChild(this._container);

		var container1 = Node3D.create();
		container1.position = new Vector4(-2.0, 0.0, 0.0);
		this._container.addChild(container1);

		var container2 = Node3D.create();
		container2.position = new Vector4(2.0, 0.0, 0.0);
		this._container.addChild(container2);

		// Create material
		var texture:Texture2D = director.textureCache.addTextureFromImageAsset("assets/images/checker.png");
		texture.retain();
		var material:Material = Material.create("generic+texture+phong+alphaCulling");
		material.uniform("texture").texture = texture;
		material.uniform("uvScaleOffset").floatArrayValue = texture.uvScaleOffset;
		material.transparent = true;
		material.side = XTGL.DoubleSide;

		// create geometriy
		var sphere = Sphere.create(1.0, 25, 25);

		this._sphere1 = MeshNode.create(sphere, material);
		container1.addChild(this._sphere1);

		this._sphere2 = MeshNode.create(sphere, material);
		container2.addChild(this._sphere2);
	}


	private function createLights():Void {

		this._whiteLight = Light.createPointLight();
		this._whiteLight.position = new Vector4(0.0, 2.0, 5.0);
		this._scene.addChild(this._whiteLight);

		this._redLight = Light.createPointLight(0x110000, 0xFF0000, 0xFFFFFF, 0.001);
		this._redLight.position = new Vector4(-2.0, 0.0, 0.0);
		this._scene.addChild(this._redLight);

		this._blueLight = Light.createPointLight(0x000011, 0x0000FF, 0xFFFFFF, 0.001);
		this._blueLight.position = new Vector4(2.0, 0.0, 0.0);
		this._scene.addChild(this._blueLight);

		// Set the scene ambient color
		this._scene.ambientLight = Color.createWithRGBHex(0x111111);
	}

	public function onTap(tapEvent:TapEvent):Bool {
		if (tapEvent.tapType == TapType.TapTypeDown) {
			var pickingResult = this._objectPicker.findPickedObject(this, tapEvent.location);
			if (pickingResult.renderObject != null) {
				XT.Log("Got object " + pickingResult.renderObject.renderId);

//				if (pickingResult.renderObject == this._meshNode) {
//				}

			}

		} else if (tapEvent.tapType == TapType.TapTypeUp) {
		}

		return false;
	}

}


