package xt3d.core;

import xt3d.node.Scene;
import xt3d.node.Camera;
import xt3d.node.RenderObject;
import xt3d.material.Material;
import xt3d.geometry.Geometry;


enum GeometryBlendType {
	GeometryBlendTypeReplace;
	GeometryBlendTypeMix;
	GeometryBlendTypeNone;
}


interface RendererOverriderMaterialDelegate {
	public function getMaterialOverride(renderObject:RenderObject, material:Material):Material;
}

interface RendererOverriderGeometryDelegate {
	public function getGeometryOverride(renderObject:RenderObject, geometry:Geometry):Geometry;
}

class RendererOverrider {

	// properties
	public var geometryBlend(get, set):GeometryBlendType;
	public var sortingEnabled(get, set):Bool;
	public var blendingEnabled(get, set):Bool;
	public var materialDelegate(get, set):RendererOverriderMaterialDelegate;
	public var geometryDelegate(get, set):RendererOverriderGeometryDelegate;

	// members
	private var _geometryBlend:GeometryBlendType = GeometryBlendType.GeometryBlendTypeNone;
	private var _sortingEnabled:Bool = true;
	private var _blendingEnabled:Bool = true;

	private var _materialDelegate:RendererOverriderMaterialDelegate = null;
	private var _geometryDelegate:RendererOverriderGeometryDelegate = null;


	public static function create(materialDelegate:RendererOverriderMaterialDelegate = null, geometryDelegate:RendererOverriderGeometryDelegate = null):RendererOverrider {
		var object = new RendererOverrider();

		if (object != null && !(object.init(materialDelegate, geometryDelegate))) {
			object = null;
		}

		return object;
	}

	public function init(materialDelegate:RendererOverriderMaterialDelegate = null, geometryDelegate:RendererOverriderGeometryDelegate = null):Bool {
		this._materialDelegate = materialDelegate;
		this._geometryDelegate = geometryDelegate;

		return true;
	}

	public function new() {
	}


	/* ----------- Properties ----------- */

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

	public inline function get_materialDelegate():RendererOverriderMaterialDelegate {
		return this._materialDelegate;
	}

	public inline function set_materialDelegate(value:RendererOverriderMaterialDelegate) {
		return this._materialDelegate = value;
	}

	public inline function get_geometryDelegate():RendererOverriderGeometryDelegate {
		return this._geometryDelegate;
	}

	public inline function set_geometryDelegate(value:RendererOverriderGeometryDelegate) {
		return this._geometryDelegate = value;
	}


	/* --------- Implementation --------- */


	public function getMaterialOverride(renderObject:RenderObject, originalMaterial:Material):Material {
		if (this._materialDelegate != null) {
			return this._materialDelegate.getMaterialOverride(renderObject, originalMaterial);
		}
		return originalMaterial;
	}

	public function getGeometryOverride(renderObject:RenderObject, originalGeometry:Geometry):Geometry {
		if (this._geometryDelegate != null) {
			return this._geometryDelegate.getGeometryOverride(renderObject, originalGeometry);
		}
		return originalGeometry;
	}

}
