package xt3d.exporter.collada;

import xt3d.utils.general.DateTime;
import xt3d.utils.XT;
import xt3d.core.Material;
import xt3d.node.RenderObject;
import xt3d.node.Node3D;
import xt3d.core.Geometry;
import xt3d.core.View;

class ColladaExporter {

	// properties

	// members
	private var _exportBuffer:StringBuf;
	private var _view:View;

	public static function create(view:View):ColladaExporter {
		var object = new ColladaExporter();

		if (object != null && !(object.init(view))) {
			object = null;
		}

		return object;
	}

	public function init(view:View):Bool {
		this._view = view;

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function export(path:String = null):Void {
		this._exportBuffer = new StringBuf();

		// Get active geometries and materials from the scene
		var geometries:Map<Int, Geometry> = new Map<Int, Geometry>();
		var materials:Map<Int, Material> = new Map<Int, Material>();
		this.gatherGeometriesAndMaterials(this._view.scene, geometries, materials);

		this.write(geometries, materials);

		XT.Log(this._exportBuffer.toString());
	}


	private function gatherGeometriesAndMaterials(node:Node3D, geometries:Map<Int, Geometry>, materials:Map<Int, Material>):Void {
		// Only handle the node and it's children if it is not excluded
		if (!node.excluded) {

			// Only handle node if it is visible and contains a geometry
			if (node.visible && Std.is(node, RenderObject)) {
				var renderObject:RenderObject = cast node;

				// Get geometry
				if (renderObject.geometry != null && !geometries.exists(renderObject.geometry.uid)) {
					geometries.set(renderObject.geometry.uid, renderObject.geometry);
				}

				// Get material
				if (renderObject.material != null && !materials.exists(renderObject.material.uid)) {
					materials.set(renderObject.material.uid, renderObject.material);
				}
			}

			// Iterate over children
			for (child in node.children) {
				this.gatherGeometriesAndMaterials(child, geometries, materials);
			}
		}
	}

	private function write(geometries:Map<Int, Geometry>, materials:Map<Int, Material>):Void {
		// Main entry point to writing collada data
		this.addLine("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
		this.addLine("<COLLADA xmlns=\"http://www.collada.org/2008/03/COLLADASchema\" version=\"1.5.0\">");

		// Write assets
		this.writeAssets();

		// Write library
		this.writeLibrary(geometries, materials);

		// Finish collada
		this.addLine("</COLLADA>");
	}

	private function writeAssets():Void {
		this.addLine("<asset>", 1);
		this.addLine("<author>xTalk3d</author>", 2);
		var now = DateTime.now();
		this.addLine("<created>" + now + "</created>", 2);
		this.addLine("<modified>" + now + "</modified>", 2);

		this.addLine("</asset>", 1);
	}

	private function writeLibrary(geometries:Map<Int, Geometry>, materials:Map<Int, Material>):Void {
		this.addLine("<library_materials>", 1);
		this.addLine("</library_materials>", 1);

		this.addLine("<library_geometries>", 1);
		this.addLine("</library_geometries>", 1);
	}

	private function addLine(line:String, indent:Int = 0):Void {
		var indentText:String = "";
		for (i in 0 ... indent) {
			indentText += "\t";
		}
		this._exportBuffer.add(indentText + line + "\n");
	}

}
