package;

import openfl.display.Sprite;
import openfl.display.OpenGLView;

import tartiflop.KFDirector;
import tartiflop.KFView;
import tartiflop.KFColor;

class Test1 extends Sprite {
	
	private var _director:KFDirector;


	public function new () {
		super ();

		// Initialise director - one per application delegate
		_director = new KFDirector();
		
		// Create opengl view and as it as a child
		var openglView = new OpenGLView();
		addChild(openglView);

		// Set opengl view in director
		_director.openglView = openglView;

		// Create a new view and add it to the director
		var view = new KFView();
		view.backgroundColor = new KFColor(0.8, 0.8, 0.8);
		_director.addView(view);

	}
	
}