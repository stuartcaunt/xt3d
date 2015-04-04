package kfsgl.node;

import kfsgl.camera.Camera;
import openfl.geom.Matrix3D;
import kfsgl.material.Material;

class RenderObject extends Node3D {

	// properties
	public var material(get, set):Material;
	public var modelMatrix(get, null):Matrix3D;
	public var modelViewMatrix(get, null):Matrix3D;
	public var modelViewProjectionMatrix(get, null):Matrix3D;
	public var normalMatrix(get, null):Matrix3D;

	// members
	private var _material:Material;
	private var _modelViewMatrix:Matrix3D = new Matrix3D();
	private var _modelViewProjectionMatrix:Matrix3D = new Matrix3D();
	private var _normalMatrix:Matrix3D = new Matrix3D();

	public function initWithMaterial(material:Material):Bool {
		var retval;
		if ((retval = super.init())) {
			this._material = material;

		}

		return retval;
	}

	private function new() {
		super();

	}

	/* ----------- Properties ----------- */

	public function get_material():Material {
		return this._material;
	}

	public function set_material(value:Material) {
		this.setMaterial(value);
		return this._material;
	}

	public function get_modelMatrix():Matrix3D {
		return this._worldMatrix;
	}

	public function get_modelViewMatrix():Matrix3D {
		return this._modelViewMatrix;
	}

	public function get_modelViewProjectionMatrix():Matrix3D {
		return this._modelViewProjectionMatrix;
	}

	public function get_normalMatrix():Matrix3D {
		return this._normalMatrix;
	}


/* --------- Implementation --------- */


	public function getMaterial():Material {
		return this._material;
	}

	public function setMaterial(value:Material) {
		this._material = value;
	}

	public function updateRenderMatrices(camera:Camera):Void {
		// Model view matrix
		this._modelViewMatrix.copyFrom(camera.viewMatrix);
		this._modelViewMatrix.prepend(this._worldMatrix);

		// normal matrix
		// TODO: test if normals are used in material
		this._normalMatrix.copyFrom(_modelViewMatrix);
		this._normalMatrix.invert();
		this._normalMatrix.transpose();

		// Model view project matrix
		this._modelViewProjectionMatrix.copyFrom(this._modelViewMatrix);
		this._modelViewProjectionMatrix.append(camera.projectionMatrix);

	}

	/* --------- Scene graph --------- */

	override public function updateObject(scene:Scene):Void {
		super.updateObject(scene);
	}

}
