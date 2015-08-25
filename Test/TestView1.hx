package ;

import xt3d.utils.XT;
import xt3d.Director;
import lime.math.Vector4;
import xt3d.node.MeshNode;
import xt3d.primitives.Plane;
import xt3d.core.Material;
import xt3d.textures.RenderTexture;
import xt3d.utils.Size;
import xt3d.textures.Texture2D;
import xt3d.primitives.Sphere;
import xt3d.node.Node3D;
import xt3d.core.View;
import xt3d.utils.Color;

class TestView1 extends View {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _sphereNode:Node3D;
	private var _sphereNode2:Node3D;
	private var _sphereNode3:Node3D;
	private var _sphereNode4:Node3D;
	private var _renderNode:Node3D;
	private var _renderTextureView:View;
	private var _renderTexture:RenderTexture;

	private var _rotation:Float = 0.0;
	private var _t:Float = 0.0;

public static function create(backgroundColor:Color):TestView1 {
		var object = new TestView1();

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
			var cameraDistance:Float = 20.0;
			this.camera.position = new Vector4(0, 0, cameraDistance);

			this._containerNode = Node3D.create();
			this._containerNode.position = new Vector4(0, 2.0, 0);
			this.scene.addChild(this._containerNode);
			//scene.zSortingEnabled = false;

			// create geometries
			var sphere = Sphere.create(2.0, 16, 16);

			// Create a material
			var material:Material = Material.create("generic+vertexColors");
			//material.opacity = 0.5;

			//		var material2:Material = Material.create("test_nocolor");
			//		material2.uniform("color").floatArrayValue = [0, 0, 1, 1];


			// Create sphere mesh node
			this._sphereNode = MeshNode.create(sphere, material);
			this._sphereNode.position = new Vector4(0.0, 0.0, -10.0);
			this._containerNode.addChild(this._sphereNode);

			// Create mesh node
			this._sphereNode2 = MeshNode.create(sphere, material);
			this._sphereNode2.position = new Vector4(7.0, 0.0, 7.0);
			this._containerNode.addChild(this._sphereNode2);

			//var texture:Texture2D = _director.textureCache.addTextureFromImageAsset("assets/images/HedgeHogAdventure.png");
			var texture:Texture2D = director.textureCache.addTextureFromColor(Color.createWithComponents(1, 1, 0.5, 0.8));
			texture.retain();
			var textureMaterial:Material = Material.create("generic+texture");
			textureMaterial.uniform("texture").texture = texture;
			textureMaterial.transparent = true;

			// Create mesh node
			this._sphereNode3 = MeshNode.create(sphere, textureMaterial);
			this._sphereNode3.position = new Vector4(-7.0, 0.0, 7.0);
			this._containerNode.addChild(this._sphereNode3);

			this._sphereNode4 = null;
			//var texture2:Texture2D = _director.textureCache.addTextureFromImageUrl("http://blog.tartiflop.com/wp-content/uploads/2008/11/checker.jpg");
			director.textureCache.addTextureFromImageAssetAsync("assets/images/checker.jpg", null, function (texture2:Texture2D) {

				texture2.retain();
				var textureMaterial2:Material = Material.create("generic+texture");
				textureMaterial2.uniform("texture").textureSlot = 1;
				textureMaterial2.uniform("texture").texture = texture2;
				textureMaterial2.opacity = 0.5;

				// Create mesh node
				this._sphereNode4 = MeshNode.create(sphere, textureMaterial2);
				this._sphereNode4.position = new Vector4(0.0, 0.0, 0.0);
				this._containerNode.addChild(this._sphereNode4);

			});



			var planeTexture:Texture2D = director.textureCache.addTextureFromImageAsset("assets/images/Ciel-00.jpg");
			planeTexture.retain();
			var planeMaterial:Material = Material.create("generic+texture");
			planeMaterial.uniform("texture").texture = planeTexture;
			planeMaterial.uniform("uvScaleOffset").floatArrayValue = planeTexture.uvScaleOffset;
			planeMaterial.depthTest = false;
			planeMaterial.depthWrite = false;

//		var planeTexture:Texture2D = _director.textureCache.addTextureFromImageAsset("assets/images/bunny.png");
//		planeTexture.retain();
//		var planeMaterial:Material = Material.create("test_texture");
//		planeMaterial.uniform("texture").texture = planeTexture;
//		planeMaterial.uniform("uvScaleOffset").floatArrayValue = planeTexture.uvScaleOffset;
//		planeMaterial.transparent = true;

			var visibleHeightAtOrigin = 2.0 * Math.tan(this.camera.fov * Math.PI / 360.0) * cameraDistance;
			var visibleWidthAtOrigin = visibleHeightAtOrigin * planeTexture.contentSize.width / planeTexture.contentSize.height;
			var plane = Plane.create(visibleWidthAtOrigin, visibleHeightAtOrigin, 4, 4);


			// Create plane mesh node
			var planeNode = MeshNode.create(plane, planeMaterial);
			this.scene.addChild(planeNode);


			// Create rendertexture and view
			var size = Size.createIntSize(640, 480);
			this._renderTexture = RenderTexture.create(size);
			this._renderTextureView = View.createBasic3D(size);
			//this._renderTextureView.scene = view.scene;
			this._renderTextureView.backgroundColor = Color.createWithRGBAHex(0x00000033);
			this._renderTextureView.camera.position = new Vector4(0.0, 4.0, 20.0);
			var renderMaterial:Material = Material.create("generic+texture");
			renderMaterial.uniform("texture").texture = this._renderTexture;
			renderMaterial.uniform("uvScaleOffset").floatArrayValue = this._renderTexture.uvScaleOffset;
			//renderMaterial.opacity = 0.7;
			renderMaterial.transparent = true;
			var renderPlane = Plane.create(8, 6, 4, 4);
			this._renderNode = MeshNode.create(renderPlane, renderMaterial);
			this._renderNode.position = new Vector4(0.0, -5.0, 3.0);
			//renderNode.rotationX = -70.0;
			this.scene.addChild(this._renderNode);

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

		this._rotation += dt * 180.0;
		this._sphereNode.rotationX = this._rotation;
		this._sphereNode2.rotationX = this._rotation;
		this._sphereNode2.rotationZ = this._rotation;
		this._sphereNode3.rotationY = this._rotation;
		if (this._sphereNode4 != null) {
			this._sphereNode4.rotationZ = this._rotation;
		}
		this._containerNode.rotationY = this._rotation * 0.5;

		var theta:Float = Math.sin(0.5 * _t * 2.0 * Math.PI) * 60.0;
		this._renderNode.rotationX = theta;

		// Render to texture
		this._renderTextureView.renderNodeToTexture(this._containerNode, this._renderTexture);
	}

}
