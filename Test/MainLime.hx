package ;


import xt3d.utils.Size;
import xt3d.gl.view.Xt3dLimeGLView;
import xt3d.gl.view.Xt3dLimeGLView;
import xt3d.gl.view.Xt3dGLView;
import xt3d.utils.Color;
import xt3d.Director;
import xt3d.gl.view.Xt3dGLViewFactory;
import lime.graphics.RenderContext;
import lime.app.Application;


class MainLime extends Application {

	private var _director:Director;
	private var _glView:Xt3dLimeGLView;


	public function new () {
		super();

//		ApplicationMain.config.depthBuffer = true;
//		ApplicationMain.config.antialiasing = true;
//		ApplicationMain.config.width = 300;

		//var backgroundColor = Color.createWithComponents(0.5, 0.8, 0.8, 0.5);
		var backgroundColor = Color.createWithComponents(0.2, 0.2, 0.2);

		// Create opengl view and as it as a child
		this._glView = Xt3dGLViewFactory.instance().createView();
		this.addModule(this._glView);

		// Initialise director - one per application delegate
		this._director = Director.create();
		this._director.glView = this._glView;
		this._director.backgroundColor = backgroundColor;

		this._director.onReady(function () {
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
			this._director.addView(view);

		});

	}


//	override public function init(context:RenderContext):Void {
//		super.init(context);
//
//		this._glView.size = Size.createIntSize(window.width, window.height);
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