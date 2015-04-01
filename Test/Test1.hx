package;

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
		var camera:Camera = Camera.create(view);
		view.camera = camera;

		// Add view to director
		_director.addView(view);

		// Create a material
		var material:Material = Material.create("test_color");
		material.setProgramName("test_nocolor");

		// create a geometry
		var geometry:Geometry = new Geometry();

		// Set a common uniform
		UniformLib.instance().uniform("common", "viewMatrix").setMatrixValue(new Matrix3D());

	}
	
}