package ;

import xt3d.events.picking.FacePicker;
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


class FacePickingDemo extends MainApplication {
	public function new () {
		super();
	}

	override public function createViews():Void {
		var view = FacePickingDemoView.create();
		this._director.addView(view);
	}


}


class FacePickingDemoView extends View implements TapGestureDelegate {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _facePicker:FacePicker;
	private var _containerAngle:Float = 0.0;
	private var _whiteLight:Light;

	public static function create():FacePickingDemoView {
		var object = new FacePickingDemoView();

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

			this._facePicker = FacePicker.create(FacePickerGeometryType.FacePickerGeometryTypeQuad);

			// Recognizers
			var tapGestureRecognizer = TapGestureRecognizer.create(this);
			this.scene.addChild(tapGestureRecognizer);

			var cameraController = CameraController.create(this._camera, 10.0);
			cameraController.xOrbitFactor = 1.5;
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

		this._containerNode.rotationY = this._containerAngle;
		this._containerAngle -= dt * (360.0 / 16.0);
	}


	private function createScene():Void {
		var director:Director = Director.current;

		this._containerNode = Node3D.create();
		this.scene.addChild(this._containerNode);

		// Create material
		var texture:Texture2D = director.textureCache.addTextureFromImageAsset("assets/images/marsmap2k.jpg");
		texture.retain();
		var material:Material = Material.create("generic+texture+phong");
		material.uniform("texture").texture = texture;
		material.uniform("uvScaleOffset").floatArrayValue = texture.uvScaleOffset;
		material.uniform("defaultShininess").floatValue = 0.7;

		// create geometriy
		var sphere = Sphere.create(1.3, 15, 15);

		var sphereNode:MeshNode = MeshNode.create(sphere, material);
		this._containerNode.addChild(sphereNode);
	}


	private function createLights():Void {

		this._whiteLight = Light.createPointLight();
		this._whiteLight.position = new Vector4(7.0, 7.0, 4.0);
		this._scene.addChild(this._whiteLight);
		this._whiteLight.renderLight = true;

		// Set the scene ambient color
		this._scene.ambientLight = Color.createWithRGBHex(0x444444);
	}

	public function onTap(tapEvent:TapEvent):Bool {
		if (tapEvent.tapType == TapType.TapTypeDown) {
			this._facePicker.findPicked(this.scene, this.camera, tapEvent.location);

		} else if (tapEvent.tapType == TapType.TapTypeUp) {
		}

		return false;
	}

}


