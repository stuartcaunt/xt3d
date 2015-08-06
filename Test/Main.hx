package ;


import xt3d.gl.view.LimeGLView;
import xt3d.gl.view.LimeGLView;
import xt3d.gl.view.Xt3dGLView;
import xt3d.utils.Color;
import xt3d.Director;
import xt3d.gl.view.Xt3dGLViewFactory;
import lime.graphics.RenderContext;
import lime.app.Application;


class Main extends Application {

	private var _director:Director;


	public function new () {
		super();

		//var backgroundColor = Color.createWithComponents(0.5, 0.8, 0.8, 0.5);
		var backgroundColor = Color.createWithComponents(0.2, 0.2, 0.2);

		// Create opengl view and as it as a child
		var glView = Xt3dGLViewFactory.instance().createView();
		this.addModule(glView);

		// Initialise director - one per application delegate
		_director = Director.create();
		_director.glView = glView;
		_director.backgroundColor = backgroundColor;

		_director.onReady(function () {
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

		});

	}


//	override public function init(context:RenderContext):Void {
//		super.init(context);
//
//
//	}
//
//	public override function render (context:RenderContext):Void {
//		super.render(context);
//	}
//
//
//	public override function update (deltaTime:Int):Void {
//		super.update(deltaTime);
//	}

}