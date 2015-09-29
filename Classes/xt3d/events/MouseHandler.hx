package xt3d.events;

interface MouseHandler {

	public function onMouseDown (x:Float, y:Float, button:Int):Bool;
	public function onMouseMove (x:Float, y:Float):Bool;
	public function onMouseMoveRelative (x:Float, y:Float):Bool;
	public function onMouseUp (x:Float, y:Float, button:Int):Bool;
	public function onMouseWheel (deltaX:Float, deltaY:Float):Bool;

}
