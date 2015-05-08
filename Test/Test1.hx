package;

import kfsgl.textures.TextureCache;
import kfsgl.textures.Texture2D;
import kfsgl.node.Node3D;
import kfsgl.node.MeshNode;
import openfl.geom.Vector3D;
import kfsgl.node.Scene;
import kfsgl.primitives.Sphere;
import kfsgl.core.Geometry;
import kfsgl.core.Camera;
import kfsgl.core.Material;
import openfl.display.Sprite;
import openfl.display.OpenGLView;

import kfsgl.Director;
import kfsgl.core.View;
import kfsgl.utils.Color;

class Test1 extends Sprite {
	
	private var _director:Director;


	public function new () {
		super ();

		// Create opengl view and as it as a child
		var openGLView = new OpenGLView();
		this.addChild(openGLView);

		// Initialise director - one per application delegate
		_director = Director.create(openGLView);

		// Create a new view and add it to the director
		var view = new View();
		view.backgroundColor = new Color(0.8, 0.8, 0.8);

		// Create a camera and set it in the view
		var camera = Camera.create(view);
		view.camera = camera;
		camera.position = new Vector3D(0, 5, 10);

		// Create scene and add it to the view
		var scene = Scene.create();
		view.scene = scene;

		// Add camera to scene
		scene.addChild(camera);

		// Add view to director
		_director.addView(view);


		var parent = Node3D.create();
		scene.addChild(parent);


		// create a geometry
		var sphere = Sphere.create(2.0, 16, 16);

		// Create a material
		var material:Material = Material.create("test_color");

		// Create mesh node
		var sphereNode = MeshNode.create(sphere, material);
		sphereNode.position = new Vector3D(0.0, 0.0, -1.0);
		parent.addChild(sphereNode);

		var material2:Material = Material.create("test_nocolor");
		material2.uniform("color").floatArrayValue = [0, 0, 1, 1];

		// Create mesh node
		var sphereNode2 = MeshNode.create(sphere, material);
		sphereNode2.position = new Vector3D(0.7, 0.0, 0.7);
		parent.addChild(sphereNode2);

		var texture:Texture2D = _director.textureCache.addTextureFromAssetImage("assets/images/HedgeHogAdventure.png");
		texture.retain();
		var textureMaterial:Material = Material.create("test_texture");
		textureMaterial.uniform("texture").texture = texture;
		textureMaterial.uniform("uvScaleOffset").floatArrayValue = texture.uvScaleOffset;
		textureMaterial.uniform("color").floatArrayValue = [1, 1, 1, 1];

		// Create mesh node
		var sphereNode3 = MeshNode.create(sphere, textureMaterial);
		sphereNode3.position = new Vector3D(-0.7, 0.0, 0.7);
		parent.addChild(sphereNode3);


// custom traversal
//		scene.traverse(function (node) {
//			node.visible = true;
//		});


		var rotation:Float = 0.0;
		_director.on("pre_render", function () {
			rotation += 1.0;
			sphereNode.rotationX = rotation	;
			sphereNode3.rotationY = rotation;
			parent.rotationY = rotation	;
		});

	}
	
}