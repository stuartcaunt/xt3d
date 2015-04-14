package;

import kfsgl.utils.KF;
import kfsgl.node.MeshNode;
import openfl.geom.Vector3D;
import kfsgl.node.Scene;
import kfsgl.primitives.Sphere;
import kfsgl.core.Geometry;
import kfsgl.camera.Camera;
import flash.geom.Matrix3D;
import kfsgl.renderer.shaders.UniformLib;
import kfsgl.material.Material;
import openfl.display.Sprite;
import openfl.display.OpenGLView;

import kfsgl.Director;
import kfsgl.view.View;
import kfsgl.utils.Color;

class Test1 extends Sprite {
	
	private var _director:Director;


	public function new () {
		super ();

		// Initialise director - one per application delegate
		_director = new Director();
		
		// Create opengl view and as it as a child
		var openglView = new OpenGLView();
		addChild(openglView);

		// Set opengl view in director
		_director.openglView = openglView;

		// Create a new view and add it to the director
		var view = new View();
		view.backgroundColor = new Color(0.8, 0.8, 0.8);

		// Create a camera and set it in the view
		var camera = Camera.create(view);
		view.camera = camera;
//		camera.position = new Vector3D(0, 5, 10);

		// Create scene and add it to the view
		var scene = Scene.create();
		view.scene = scene;

//		// Add camera to scene
//		scene.addChild(camera);

		// Add view to director
		_director.addView(view);

		// Create a material
		var material:Material = Material.create("test_color");

		// create a geometry
		var sphere = Sphere.create(2.0, 16, 16);
		var sphereNode = MeshNode.create(sphere, material);
		sphereNode.position = new Vector3D(0.0, 0.0, 0.0);

		scene.addChild(sphereNode);

		var material2:Material = Material.create("test_nocolor");
		material2.uniform("color").floatArrayValue = [0, 0, 1, 1];

		// create a geometry
		var sphere2 = Sphere.create(2.0, 16, 16);
		var sphereNode2 = MeshNode.create(sphere2, material2);
		sphereNode2.position = new Vector3D(1.0, 0.0, 0.0);

		scene.addChild(sphereNode2);

		// custom traversal
//		scene.traverse(function (node) {
//			node.visible = true;
//		});


		var rotation:Float = 0.0;
		_director.on("pre_render", function () {
			rotation += 1.0;
			sphereNode.rotationX = rotation	;
			scene.rotationY = rotation	;
		});

	}
	
}