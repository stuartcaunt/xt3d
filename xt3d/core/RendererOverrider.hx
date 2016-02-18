package xt3d.core;

import xt3d.node.Scene;
import xt3d.node.Camera;
import xt3d.node.RenderObject;
import xt3d.material.Material;


enum GeometryBlendType {
	GeometryBlendTypeReplace;
	GeometryBlendTypeMix;
}


interface RendererOverriderDelegate {
	public function onRenderStart(scene:Scene, camera:Camera):Void;
	public function prepareRenderObject(renderObject:RenderObject, material:Material):Void;
}

class RendererOverrider {

	// properties
	public var material(get, set):Material;
	public var geometry(get, set):Geometry;
	public var geometryBlend(get, set):GeometryBlendType;
	public var sortingEnabled(get, set):Bool;
	public var blendingEnabled(get, set):Bool;
	public var delegate(get, set):RendererOverriderDelegate;

	// members
	private var _material:Material;
	private var _geometry:Geometry;
	private var _geometryBlend:GeometryBlendType = GeometryBlendType.GeometryBlendTypeReplace;
	private var _sortingEnabled:Bool = true;
	private var _blendingEnabled:Bool = true;

	private var _delegate:RendererOverriderDelegate = null;


	public static function create():RendererOverrider {
		var object = new RendererOverrider();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public static function createWithMaterial(material:Material):RendererOverrider {
		var object = new RendererOverrider();

		if (object != null && !(object.initWithMaterial(material))) {
			object = null;
		}

		return object;
	}

	public static function createWithGeometry(geometry:Geometry):RendererOverrider {
		var object = new RendererOverrider();

		if (object != null && !(object.initWithGeometry(geometry))) {
			object = null;
		}

		return object;
	}

	public static function createWithMaterialAndGeometry(material:Material, geometry:Geometry):RendererOverrider {
		var object = new RendererOverrider();

		if (object != null && !(object.initWithMaterialAndGeometry(material, geometry))) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		this._material = null;
		this._geometry = null;

		return true;
	}

	public function initWithMaterial(material:Material):Bool {
		this._material = material;
		this._geometry = null;

		return true;
	}

	public function initWithGeometry(geometry:Geometry):Bool {
		this._material = null;
		this._geometry = geometry;

		return true;
	}

	public function initWithMaterialAndGeometry(material:Material, geometry:Geometry):Bool {
		this._material = material;
		this._geometry = geometry;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	inline function get_material():Material {
		return this._material;
	}

	inline	function set_material(value:Material) {
		return this._material = value;
	}

	inline function get_geometry():Geometry {
		return this._geometry;
	}

	inline function set_geometry(value:Geometry) {
		return this._geometry = value;
	}

	inline function get_geometryBlend() {
		return this._geometryBlend;
	}

	inline function set_geometryBlend(value) {
		return this._geometryBlend = value;
	}

	inline function get_sortingEnabled():Bool {
		return this._sortingEnabled;
	}

	inline function set_sortingEnabled(value:Bool) {
		return this._sortingEnabled = value;
	}

	inline function get_blendingEnabled():Bool {
		return this._blendingEnabled;
	}

	inline function set_blendingEnabled(value:Bool) {
		return this._blendingEnabled = value;
	}

	inline function get_delegate():RendererOverriderDelegate {
		return this._delegate;
	}

	inline function set_delegate(value:RendererOverriderDelegate) {
		return this._delegate = value;
	}


	/* --------- Implementation --------- */


	public function onRenderStart(scene:Scene, camera:Camera):Void {
		if (this._delegate != null) {
			this._delegate.onRenderStart(scene, camera);
		}
	}

	public function prepareRenderObject(renderObject:RenderObject, material:Material):Void {
		if (this._delegate != null) {
			this._delegate.prepareRenderObject(renderObject, material);
		}
	}

}
