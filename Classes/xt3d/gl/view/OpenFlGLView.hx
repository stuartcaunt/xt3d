package xt3d.gl.view;

import openfl.events.Event;
import openfl.display.Sprite;

class OpenFlGLView extends Sprite implements Xt3dView {

	// properties

	// members

	public static function create():OpenFlGLView {
		var object = new OpenFlGLView();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {

		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		return true;
	}


	public function new() {
	}

	public function onAddedToStage() {
		if (stage == null) {
			return;
		}
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);


		// Finally, set up an event for the actual game loop stuff.
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		// We need to listen for resize event which means new context
		// it means that we need to recreate bitmapdatas of dumped tilesheets
		stage.addEventListener(Event.RESIZE, onResize);

	}

	private function onResize():Void {
	}

	private function onEnterFrame():Void {
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

}
