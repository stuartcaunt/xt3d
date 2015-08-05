package;

import openfl.gl.GL;
import xt3d.utils.Size;
import xt3d.textures.RenderTexture;
import xt3d.primitives.Plane;
import xt3d.gl.KFGL;
import xt3d.utils.KF;
import xt3d.textures.TextureCache;
import xt3d.textures.Texture2D;
import xt3d.node.Node3D;
import xt3d.node.MeshNode;
import openfl.geom.Vector3D;
import xt3d.node.Scene;
import xt3d.primitives.Sphere;
import xt3d.core.Geometry;
import xt3d.node.Camera;
import xt3d.core.Material;
import openfl.display.Sprite;
import openfl.display.OpenGLView;

import xt3d.Director;
import xt3d.core.View;
import xt3d.utils.Color;

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

		//var view = TestGouraud1.create(backgroundColor);
		//var view = TestGouraud2.create(backgroundColor);
		//var view = TestGouraud3.create(backgroundColor);
		//var view = TestGouraud4.create(backgroundColor);

		var view = TestPhong1.create(backgroundColor);
		//var view = TestPhong2.create(backgroundColor);
		//var view = TestPhong3.create(backgroundColor);
		//var view = TestPhong4.create(backgroundColor);

		// Add view to director
		_director.addView(view);

	}
	
}