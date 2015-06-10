package kfsgl.node;

import kfsgl.core.Light;
import kfsgl.utils.KF;
import kfsgl.gl.KFGL;
import kfsgl.node.Node3D;

class Scene extends Node3D {

	// properties
	public var opaqueObjects(get, null):Array<RenderObject>;
	public var transparentObjects(get, null):Array<RenderObject>;
	public var lights(get, null):Array<Light>;
	public var zSortingStrategy(get, set):Int;

	private var _opaqueObjects:Array<RenderObject>;
	private var _transparentObjects:Array<RenderObject>;
	private var _zSortingStrategy:Int = KFGL.ZSortingAll;
	private var _lights:Array<Light> = new Array<Light>();

	private var _borrowedChildren:Map<Node3D, Node3D> = new Map<Node3D, Node3D>();

	// members
	public static function create():Scene {
		var object = new Scene();

		if (object != null && !(object.initScene())) {
			object = null;
		}

		return object;
	}

	public function initScene():Bool {
		var retval;
		if ((retval = super.init())) {

		}

		return retval;
	}

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */

	inline public function get_opaqueObjects():Array<RenderObject> {
		return this._opaqueObjects;
	}

	inline public function get_transparentObjects():Array<RenderObject> {
		return this._transparentObjects;
	}

	public inline function get_lights():Array<Light> {
		return this._lights;
	}

	public inline function get_zSortingStrategy():Int {
		return this._zSortingStrategy;
	}

	public inline function set_zSortingStrategy(value:Int) {
		return this._zSortingStrategy = value;
	}


	/* --------- Implementation --------- */

	inline public function getOpaqueObjects():Array<RenderObject> {
		return this._opaqueObjects;
	}

	inline public function getTransparentObjects():Array<RenderObject> {
		return this._transparentObjects;
	}

	inline public function addOpqueObject(object:RenderObject):Void {
		this._opaqueObjects.push(object);
	}

	inline public function addTransparentObject(object:RenderObject):Void {
		this._transparentObjects.push(object);
	}

	inline public function addLight(light:Light):Void {
		this._lights.push(light);
	}


	/* --------- Scene graph --------- */

	override public function updateObject(scene:Scene):Void {
		// Initialise arrays for transparent and opaque objects
		this._opaqueObjects.splice(0, this._opaqueObjects.length);
		this._transparentObjects.splice(0, this._transparentObjects.length);
		this._lights.splice(0, this._lights.length);
	}

	inline public function borrowChild(child:Node3D):Void {
		// Keep reference to original parent
		this._borrowedChildren.set(child, child.parent);

		// Nullify parent
		child.parent = null;

		// Set parent to this
		this.addChild(child);
	}

	inline public function returnBorrowedChild(child:Node3D):Void {
		if (this._borrowedChildren.exists(child)) {
			var parent = this._borrowedChildren.get(child);

			// Remove child from scene graph
			this.removeChild(child);

			// Remove child from borrow children
			this._borrowedChildren.remove(child);

			// Replace original parent
			child.parent = parent;

		} else {
			KF.Log("Borrowed child node did not exist in scene");
		}
	}


}
