package ;

import xt3d.core.Director;
import xt3d.node.Light;
import xt3d.core.Director;
import lime.math.Vector4;
import xt3d.node.MeshNode;
import xt3d.core.Material;
import xt3d.textures.Texture2D;
import xt3d.primitives.Sphere;
import xt3d.node.Node3D;
import xt3d.core.View;
import xt3d.utils.color.Color;


class PhongMars extends MainApplication {
	public function new () {
		super();
	}

	override public function createViews():Void {
		// Create test view
		var view = PhongMarsView.create();
		this._director.addView(view);
	}
}


class PhongMarsView extends View {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _sphereNode:Node3D;
	private var _light:Light;

	private var _rotation:Float = 0.0;
	private var _t:Float = 0.0;

	public static function create():PhongMarsView {
		var object = new PhongMarsView();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var retval;
		if ((retval = super.initBasic3D())) {

			var director:Director = Director.current;

			this.backgroundColor = Color.createWithComponents(0.2, 0.2, 0.2);

			// Create a camera and set it in the view
			var cameraDistance:Float = 90.0;
			this.camera.position = new Vector4(0, 0, cameraDistance);

			this._containerNode = Node3D.create();
			this.scene.addChild(this._containerNode);
			//scene.zSortingEnabled = false;

			// create geometries
			var sphere = Sphere.create(33.0, 32, 16);

			// Create a material
			var texture:Texture2D = director.textureCache.addTextureFromImageAsset("assets/images/marsmap2k.jpg");
			texture.retain();
			var material:Material = Material.create("generic+texture+phong");
			material.uniform("texture").texture = texture;
			material.uniform("uvScaleOffset").floatArrayValue = texture.uvScaleOffset;
			material.uniform("defaultShininess").floatValue = 10.0;
			material.transparent = true;

			// Create sphere mesh node
			this._sphereNode = MeshNode.create(sphere, material);
			this._containerNode.addChild(this._sphereNode);

			this._light = Light.createPointLight();
			this._light.position = new Vector4(80.0, 0.0, 40.0);
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

		this._t += 1.0 / 60.0;

		this._rotation += dt * (360.0 / 16.0);
		this._sphereNode.rotationY = this._rotation;
	}

}
