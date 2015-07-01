package;

import openfl.gl.GL;
import kfsgl.utils.Size;
import kfsgl.textures.RenderTexture;
import kfsgl.primitives.Plane;
import kfsgl.primitives.Plane;
import kfsgl.gl.KFGL;
import kfsgl.utils.KF;
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

		//var backgroundColor = Color.createWithComponents(0.5, 0.8, 0.8, 0.5);
		var backgroundColor = Color.createWithComponents(0.2, 0.2, 0.2);

		// Create opengl view and as it as a child
		var openGLView = new OpenGLView();
		this.addChild(openGLView);

		// Initialise director - one per application delegate
		_director = Director.create(openGLView);
		_director.backgroundColor = backgroundColor;

		// Create test view
		//var view = TestView1.create(backgroundColor);
		var view = TestGouraud.create(backgroundColor);

		// Add view to director
		_director.addView(view);

	}
	
}