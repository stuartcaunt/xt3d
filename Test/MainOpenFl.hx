package ;


import openfl.display.Sprite;
import xt3d.gl.view.Xt3dOpenFLGLView;
import xt3d.gl.view.Xt3dGLView;
import xt3d.utils.Color;
import xt3d.Director;
import xt3d.gl.view.Xt3dGLViewFactory;
import lime.app.Application;


class MainOpenFl extends Sprite {

	private var _director:Director;
	private var _glView:Xt3dOpenFLGLView;


	public function new () {
		super();

		var backgroundColor = Color.createWithComponents(0.2, 0.2, 0.2);

		// Create opengl view and as it as a child
		this._glView = Xt3dGLViewFactory.instance().createView();
		this.addChild(this._glView);

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