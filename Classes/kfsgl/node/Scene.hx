package kfsgl.node;

import kfsgl.node.Node3D;

class Scene extends Node3D {

	// properties
	@:isVar public var opaqueObjects(get, null):Array<Node3D>;
	@:isVar public var transparentObjects(get, null):Array<Node3D>;

	private var _opaqueObjects:Array<Node3D>;
	private var _transparentObjects:Array<Node3D>;

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

	inline public function get_opaqueObjects():Array<Node3D> {
		return this._opaqueObjects;
	}

	inline public function get_transparentObjects():Array<Node3D> {
		return this._transparentObjects;
	}



	/* --------- Implementation --------- */

	inline public function getOpaqueObjects():Array<Node3D> {
		return this._opaqueObjects;
	}

	inline public function getTransparentObjects():Array<Node3D> {
		return this._transparentObjects;
	}

	inline public function addOpqueObject(object:Node3D):Void {
		this._opaqueObjects.push(object);
	}

	inline public function addTransparentObject(object:Node3D):Void {
		this._transparentObjects.push(object);
	}

	/* --------- Scene graph --------- */

	override public function updateObject():Void {
		// Initialise arrays for transparent and opaque objects
		this._opaqueObjects = new Array<Node3D>();
		this._transparentObjects = new Array<Node3D>();
	}


}
