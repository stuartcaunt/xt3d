package xt3d.core;

import xt3d.gl.shaders.UniformLib;
import xt3d.gl.shaders.UniformLib;
import xt3d.node.RenderObject;
import xt3d.node.RenderObject;
enum GeometryBlendType {
	GeometryBlendTypeReplace;
	GeometryBlendTypeMix;
}


class RendererOverrider {

	// properties
	public var material(get, set):Material;
	public var geometry(get, set):Geometry;
	public var geometryBlend(get, set):GeometryBlendType;
	public var sortingEnabled(get, set):Bool;

	// members
	private var _material:Material;
	private var _geometry:Geometry;
	private var _geometryBlend:GeometryBlendType = GeometryBlendType.GeometryBlendTypeReplace;
	private var _sortingEnabled:Bool = false;


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


	/* --------- Implementation --------- */


	public function prepareRenderer():Void {
		// TODO... delegate ?
	}

	public function prepareRenderObject(renderObject:RenderObject, uniformLib:UniformLib):Void {
		// TODO... delegate ?
	}

}
