package kfsgl.node;

import kfsgl.renderer.shaders.ShaderProgram;
import kfsgl.errors.KFException;
import kfsgl.utils.gl.GLAttributeManager;
import openfl.gl.GL;
import kfsgl.core.Geometry;
import kfsgl.camera.Camera;
import openfl.geom.Matrix3D;
import kfsgl.material.Material;

class RenderObject extends Node3D {

	// properties
	public var material(get, set):Material;
	public var geometry(get, set):Geometry;
	public var modelMatrix(get, null):Matrix3D;
	public var modelViewMatrix(get, null):Matrix3D;
	public var modelViewProjectionMatrix(get, null):Matrix3D;
	public var normalMatrix(get, null):Matrix3D;
	public var renderElementsOffset(get, set):Int;
	public var renderElementsCount(get, set):Int;

	// members
	private var _material:Material;
	private var _geometry:Geometry;
	private var _drawMode:UInt;
	private var _modelViewMatrix:Matrix3D = new Matrix3D();
	private var _modelViewProjectionMatrix:Matrix3D = new Matrix3D();
	private var _normalMatrix:Matrix3D = new Matrix3D();

	private var _renderElementsOffset = -1;
	private var _renderElementsCount = -1;

	public function initRenderObject(geometry:Geometry, material:Material, drawMode:Int):Bool {
		var retval;
		if ((retval = super.init())) {
			this._geometry = geometry;
			this._material = material;
			this._drawMode = drawMode;

		}

		return retval;
	}

	private function new() {
		super();

	}

	/* ----------- Properties ----------- */


	public inline function get_geometry():Geometry {
		return this._geometry;
	}

	public inline function set_geometry(value:Geometry) {
		this.setGeometry(value);
		return this._geometry;
	}

	public inline function get_material():Material {
		return this._material;
	}

	public inline function set_material(value:Material) {
		this.setMaterial(value);
		return this._material;
	}

	public inline function get_modelMatrix():Matrix3D {
		return this._worldMatrix;
	}

	public inline function get_modelViewMatrix():Matrix3D {
		return this._modelViewMatrix;
	}

	public inline function get_modelViewProjectionMatrix():Matrix3D {
		return this._modelViewProjectionMatrix;
	}

	public inline function get_normalMatrix():Matrix3D {
		return this._normalMatrix;
	}

	public inline function get_renderElementsOffset():Int {
		return this._renderElementsOffset;
	}

	public inline function set_renderElementsOffset(value:Int) {
		return this._renderElementsOffset = value;
	}

	public inline function get_renderElementsCount():Int {
		return this._renderElementsCount;
	}

	public inline function set_renderElementsCount(value:Int) {
		return this._renderElementsCount = value;
	}


	/* --------- Implementation --------- */

	public inline function getGeometry():Geometry {
		return this._geometry;
	}

	public inline function setGeometry(value:Geometry) {
		this._geometry = value;
	}


	public inline function getMaterial():Material {
		return this._material;
	}

	public inline function setMaterial(value:Material) {
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

	public function renderBuffer(program:ShaderProgram, attributeManager:GLAttributeManager):Void {
		var programAttributes = program.attributes;
		var isIndexed = this._geometry.isIndexed;
		var isInterleaved = this._geometry.isInterleaved;
		var allVertexData = this._geometry.vertexData;

		// Initialise attribute manager for this object
		attributeManager.initForRenderObject();

		// Initialise state of attributes before render
		for (attributeState in programAttributes) {
			attributeState.used = false;
		}

		if (isInterleaved) {
			// TODO handle interleaved data

		} else {
			// Iterate over all vertex data in the geometry
			for (vertexData in allVertexData) {
				var attributeName = vertexData.attributeName;

				// If attribute exists in the program then set it
				if (programAttributes.exists(attributeName)) {
					var attributeState = programAttributes.get(attributeName);
					var attributeLocation = attributeState.location;

					// Verify that the attribute is used by the program
					if (attributeLocation >= 0) {
						// Enable the attribute
						attributeManager.enableAttribute(attributeLocation);

						// Attach buffer to attribute pointer
						vertexData.bindToAttribute(attributeLocation);

						// Set the state as used
						attributeState.used = true;
					}
				}
			}
		}

		// Disable unused attributes
		attributeManager.disableUnusedAttributes();

		// Verify that all attributes are used
		for (attributeState in programAttributes) {
			if (attributeState.location >= 0 && !attributeState.used) {
				throw new KFException("UnusedVertexAttribute", "The vertex attribute \"" + attributeState.name + "\" is unused for the program \"" + program.name + "\"");
			}
		}


		if (isIndexed) {
			var indices = this._geometry.indices;

			// Bind the indices
			indices.bind();

			var elementOffset = (this._renderElementsOffset != -1) ? this._renderElementsOffset : 0;
			var elementCount = (this._renderElementsCount != -1) ? this._renderElementsCount : geometry.indexCount;


			// Draw the indexed vertices
			GL.drawElements(this._drawMode, elementCount, indices.type, elementOffset);

		} else {
			var elementOffset = (this._renderElementsOffset != -1) ? this._renderElementsOffset : 0;
			var elementCount = (this._renderElementsCount != -1) ? this._renderElementsCount : geometry.vertexCount;

			GL.drawArrays(this._drawMode, elementOffset, elementCount);
		}


	}

	/* --------- Scene graph --------- */

	override public function updateObject(scene:Scene):Void {
		super.updateObject(scene);

		// Make sure the geometry data is written to opengl buffers
		this.geometry.updateGeometry();
	}

}
