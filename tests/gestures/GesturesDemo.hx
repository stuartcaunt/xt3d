package;

import xt3d.events.gestures.PanGestureRecognizer.PanGestureDelegate;
import xt3d.events.gestures.PanGestureRecognizer;
import xt3d.utils.XT;
import xt3d.events.gestures.TapGestureRecognizer;
import xt3d.events.gestures.TapGestureRecognizer.TapGestureDelegate;
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


class GesturesDemo extends MainApplication {
	public function new () {
		super();
	}

	override public function createViews():Void {
		var view = GesturesDemoView.create();
		this._director.addView(view);
	}


}


class GesturesDemoView extends View implements TapGestureDelegate implements PanGestureDelegate {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _sphereNode:Node3D;
	private var _blueLight:Light;
	private var _redLight:Light;
	private var _greenLight:Light;
	private var _whiteLight:Light;

	private var _lightAngle:Float = 0.0;
	private var _sphereAngle:Float = 0.0;
	private var _containerAngle:Float = 0.0;

	private var _sceneObjects:Array<Node3D> = new Array<Node3D>();

	private var _tapGestureRecognizer:TapGestureRecognizer;
	private var _panGestureRecognizer:PanGestureRecognizer;

	public static function create():GesturesDemoView {
		var object = new GesturesDemoView();

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
			director.timeFactor = 0.3;

			// Create scene
			this.createScene();

			// Create lights
			this.createLights();

			// Recognizers
			this._tapGestureRecognizer = TapGestureRecognizer.create(this, 2);
			Director.current.gestureDispatcher.addGestureRecognizer(this._tapGestureRecognizer);

			this._panGestureRecognizer = PanGestureRecognizer.create(this);
			Director.current.gestureDispatcher.addGestureRecognizer(this._panGestureRecognizer);

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
		for (sceneObject in this._sceneObjects) {
			sceneObject.rotationY = this._sphereAngle;
		}

		var blueAngle = this._lightAngle;
		var redAngle = -(blueAngle + 120);
		var greenAngle = redAngle + 12;
		this._blueLight.position = new Vector4(7 * Math.sin(blueAngle * Math.PI / 90), 7 * Math.cos(blueAngle * Math.PI / 90), 7 * Math.cos(blueAngle * Math.PI / 180));
		this._redLight.position = new Vector4(7 * Math.sin(redAngle * Math.PI / 145), 7 * Math.cos(redAngle * Math.PI / 145), 7 * Math.cos(redAngle * Math.PI / 180));
		this._greenLight.position = new Vector4(7 * Math.sin(greenAngle * Math.PI / 60), 7 * Math.cos(greenAngle * Math.PI / 60), 7 * Math.cos(greenAngle * Math.PI / 180));

		this._containerNode.rotationY = this._containerAngle;

		this._lightAngle += dt * (360.0 / 3.0);
		this._sphereAngle += dt * (360.0 / 6.0);
		this._containerAngle += dt * (360.0 / 16.0);
	}


	private function createScene():Void {
		var director:Director = Director.current;

		// Create a camera and set it in the view
		var cameraDistance:Float = 20.0;
		this.camera.position = new Vector4(0, 0, cameraDistance);

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

		// Create mesh nodes
		for (k in 0 ... 3) {
			for (j in 0 ... 3) {
				for (i in 0 ... 3) {
					var sphereNode:MeshNode = MeshNode.create(sphere, material);
					sphereNode.position = new Vector4(((i - 1.0) * 4), ((j - 1.0) * 4), ((k - 1.0) * 4));
					this._containerNode.addChild(sphereNode);
					this._sceneObjects.push(sphereNode);
				}
			}
		}
	}


	private function createLights():Void {
		// Create the lights
		this._blueLight =Light.createPointLight(0x000011, 0x0000FF, 0xFFFFFF, 0.02);
		this._containerNode.addChild(this._blueLight);
		this._blueLight.renderLight = true;

		this._greenLight =Light.createPointLight(0x001100, 0x00FF00, 0xFFFFFF, 0.02);
		this._containerNode.addChild(this._greenLight);
		this._greenLight.renderLight = true;

		this._redLight =Light.createPointLight(0x110000, 0xFF0000, 0xFFFFFF, 0.02);
		this._containerNode.addChild(this._redLight);
		this._redLight.renderLight = true;

		this._whiteLight = Light.createPointLight();
		this._whiteLight.position = new Vector4(7.0, 7.0, 4.0);
		this._containerNode.addChild(this._whiteLight);
		this._whiteLight.renderLight = true;

		// Set the scene ambient color
		this._scene.ambientLight = Color.createWithRGBHex(0x444444);
	}

	public function onTap(tapEvent:TapEvent):Bool {
		if (tapEvent.tapType == TapType.TapTypeDown) {
			//XT.Log("TapDown");

		} else if (tapEvent.tapType == TapType.TapTypeUp) {
			XT.Log("Double-tap");
		}

		return false;
	}

	public function onPan(panEvent:PanEvent):Bool {
		XT.Log("Pan by " + panEvent.globalDelta + " location = " + panEvent.location);

		return false;
	}

}


