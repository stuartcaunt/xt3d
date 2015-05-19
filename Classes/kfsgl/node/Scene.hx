package kfsgl.node;

import kfsgl.gl.KFGL;
import kfsgl.node.Node3D;

class Scene extends Node3D {

	// properties
	public var opaqueObjects(get, null):Array<RenderObject>;
	public var transparentObjects(get, null):Array<RenderObject>;
	public var zSortingStrategy(get, set):Int;

	private var _opaqueObjects:Array<RenderObject>;
	private var _transparentObjects:Array<RenderObject>;
	private var _zSortingStrategy:Int = KFGL.ZSortingAll;
//	private var _lights:Array<Light>;

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

	public inline function get_zSortingStrategy():Int {
		return this._zSortingStrategy;
	}

	public inline function set_zSortingStrategy(value:Int) {
		return this._zSortingStrategy = value;
	}


	/* --------- Scene graph --------- */

	override public function updateObject(scene:Scene):Void {
		// Initialise arrays for transparent and opaque objects
		this._opaqueObjects = new Array<RenderObject>();
		this._transparentObjects = new Array<RenderObject>();
	}


}
