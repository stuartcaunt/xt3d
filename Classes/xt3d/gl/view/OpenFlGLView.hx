package xt3d.gl.view;

import openfl._internal.renderer.AbstractRenderer;
import openfl._internal.renderer.AbstractRenderer;
import lime.graphics.RenderContext;
import xt3d.utils.errors.KFException;
import lime.graphics.GLRenderContext;
import openfl.events.Event;
import openfl.display.Sprite;

class OpenFlGLView extends Sprite implements Xt3dGLView {

	// properties

	// members
	private var _gl:GLRenderContext = null;
	private var _listeners:Array<Xt3dGLViewListener> = new Array<Xt3dGLViewListener>();
	private var _width:Int;
	private var _height:Int;

	public static function create(width:Int = 1024, height:Int = 768):OpenFlGLView {
		var object = new OpenFlGLView();

		if (object != null && !(object.initView(width, height))) {
			object = null;
		}

		return object;
	}

	public function initView(width:Int = 1024, height:Int = 768):Bool {
		this._width = width;
		this._height = height;

		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		return true;
	}


	public function new() {
	}

	public function onAddedToStage() {
		if (stage == null) {
			return;
		}
		stage.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		// Finally, set up an event for the actual game loop stuff.
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		// We need to listen for resize event which means new context
		// it means that we need to recreate bitmapdatas of dumped tilesheets
		stage.addEventListener(Event.RESIZE, onResize);

		// Get render context
		var renderer:AbstractRenderer = @:privateAccess(stage.__renderer);

		this._gl = renderer.gl;


		this.setRenderContext(context);

		// If we have a context then initialise all listeners
		if (this._gl != null) {
			this.onInit();

		} else {
			throw new KFException("InvalidGraphicsContext", "xTalk3d cannot run without OpenGL");
		}


		this._width = stage.stageWidth;
		this._height = stage.stageHeight;

		for (listener in this._listeners) {
			listener.onContextInitialised(this);
		}
	}

	private function onResize():Void {
	}

	private function onEnterFrame():Void {
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	private function onUpdate(dt:Float):Void {
		for (listener in this._listeners) {
			listener.onUpdate(this, dt);
		}
	}

	private function onRender():Void {
		for (listener in this._listeners) {
			listener.onRender(this);
		}
	}

	private function onEvent(event:String):Void {
		for (listener in this._listeners) {
			listener.onEvent(this, event);
		}
	}

	/* --------- Xt3dGLView Implementation --------- */

	public function addListener(listener:Xt3dGLViewListener):Void {
		if (this._listeners.indexOf(listener) == -1) {
			this._listeners.push(listener);

			// If already initialised then notify listener
			if (this._gl != null) {
				listener.onContextInitialised(this);
			}
		}
	}

	public function removeListener(listener:Xt3dGLViewListener):Void {
		var index = this._listeners.indexOf(listener);
		if (index != -1) {
			this._listeners.slice(index, 1);
		}
	}

}
