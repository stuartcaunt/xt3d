package xt3d.events;

import lime.ui.Touch;

interface TouchHandler {

	public function onTouchStart (touch:Touch):Bool;
	public function onTouchEnd (touch:Touch):Bool;
	public function onTouchMove (touch:Touch):Bool;
}
