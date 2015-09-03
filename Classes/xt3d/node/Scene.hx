package xt3d.node;

import xt3d.gl.shaders.UniformLib;
import xt3d.utils.color.Color;
import xt3d.utils.XT;
import xt3d.gl.XTGL;
import xt3d.node.Node3D;
import xt3d.core.Director;

class Scene extends Node3D {


	// properties
	public var opaqueObjects(get, null):Array<RenderObject>;
	public var transparentObjects(get, null):Array<RenderObject>;
	public var lights(get, null):Array<Light>;
	public var zSortingStrategy(get, set):Int;
	public var lightingEnabled(get, set):Bool;
	public var ambientLight(get, set):Color;

	private var _opaqueObjects:Array<RenderObject> = new Array<RenderObject>();
	private var _transparentObjects:Array<RenderObject> = new Array<RenderObject>();
	private var _zSortingStrategy:Int = XTGL.ZSortingAll;

	private var _lights:Array<Light> = new Array<Light>();
	private var _lightingEnabled:Bool = true;
	private var _ambientLight:Color = Color.createWithRGBHex(0x222222);

	private var _borrowedChildren:Map<Node3D, Node3D> = new Map<Node3D, Node3D>();
	private var _maxLights:Int;
	private var _lastNumberOfLights:Int = 0;

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
			this._maxLights = Director.current.configuration.getInt(XT.MAX_LIGHTS);
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

	public function get_lightingEnabled():Bool {
		return this._lightingEnabled;
	}

	public function set_lightingEnabled(value:Bool) {
		return this._lightingEnabled = value;
	}

	public function get_ambientLight():Color {
		return _ambientLight;
	}

	public function set_ambientLight(value:Color) {
		return this._ambientLight = value;
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
			XT.Log("Borrowed child node did not exist in scene");
		}
	}

	public function prepareRender(camera:Camera, uniformLib:UniformLib):Void {

		var numberOfLights:Int = Std.int(Math.min(this._lights.length, this._maxLights));
		if (numberOfLights < this._lights.length && this._lights.length != this._lastNumberOfLights) {
			XT.Warn("Number of lights in the scene (" + this._lights.length + ") exceeds maximum: only using " + this._maxLights);
		}
		this._lastNumberOfLights = this._lights.length;

		// Enable/disable lighting
		uniformLib.uniform("lightingEnabled").boolValue = this._lightingEnabled;

		if (this._lightingEnabled) {
			// Set ambient light
			uniformLib.uniform("sceneAmbientColor").floatArrayValue = this._ambientLight.rgbArray;

			// Disable unused lights
			if (this._lights.length < this._maxLights) {
				for (i in this._lights.length ... this._maxLights) {
					uniformLib.uniform("lights").at(i).get("enabled").boolValue = false;
				}
			}

			// Set parameters for used lights
			for (i in 0 ... numberOfLights) {
				lights[i].prepareRender(camera, uniformLib, i);
			}
		}

	}

}
