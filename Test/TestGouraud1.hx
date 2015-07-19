package ;

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

class TestGouraud1 extends View {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _sphereNode:Node3D;
	private var _light:Light;

	private var _rotation:Float = 0.0;
	private var _t:Float = 0.0;

	public static function create(backgroundColor:Color):TestGouraud1 {
		var object = new TestGouraud1();

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
			//scene.zSortingEnabled = false;

			// create geometries
			var sphere = Sphere.create(33.0, 64, 64);

			// Create a material
			var texture:Texture2D = director.textureCache.addTextureFromImageAsset("assets/images/marsmap2k.jpg");
			texture.retain();
			var material:Material = Material.create("generic+texture+gouraud+material");
			material.uniform("texture").texture = texture;
			material.uniform("uvScaleOffset").floatArrayValue = texture.uvScaleOffset;
			material.uniform("material").get("diffuseColor").floatArrayValue = Color.createWithRGBAHex(0xff000099).rgbaArray;
			material.uniform("material").get("shininess").floatValue = 10.0;
			//material.uniform("material").get("specularColor").floatArrayValue = Color.createWithRGBHex(0x000000).rgbArray;
			material.transparent = true;

			// Create sphere mesh node
			this._sphereNode = MeshNode.create(sphere, material);
			this._containerNode.addChild(this._sphereNode);

			this._light = Light.createPointLight();
			this._light.position = new Vector3D(80.0, 0.0, 40.0);

//			this._light = Light.createDirectionalLight();
//			this._light.direction = new Vector3D(100.0, 0.0, 0.0);

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
