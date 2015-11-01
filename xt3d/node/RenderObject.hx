package xt3d.node;

import xt3d.core.RendererOverrider;
import xt3d.math.Vector4;
import xt3d.math.VectorHelper;
import xt3d.gl.GLBufferManager;
import xt3d.gl.shaders.ShaderProgram;
import xt3d.utils.errors.XTException;
import xt3d.gl.GLAttributeManager;
import lime.graphics.opengl.GL;
import xt3d.core.Geometry;
import xt3d.math.Matrix4;
import xt3d.core.Material;
import xt3d.core.Director;

class RenderObject extends Node3D {

	// properties
	public var material(get, set):Material;
	public var geometry(get, set):Geometry;
	public var modelMatrix(get, null):Matrix4;
	public var modelViewMatrix(get, null):Matrix4;
	public var modelViewProjectionMatrix(get, null):Matrix4;
	public var normalMatrix(get, null):Matrix4;
	public var renderElementsOffset(get, set):Int;
	public var renderElementsCount(get, set):Int;
	public var renderZ(get, null):Float;
	public var renderId(get, set):Int;

	// members
	private var _material:Material;
	private var _geometry:Geometry;
	private var _drawMode:UInt;
	private var _modelViewMatrix:Matrix4 = new Matrix4();
	private var _modelViewProjectionMatrix:Matrix4 = new Matrix4();
	private var _normalMatrix:Matrix4 = new Matrix4();
	private var _normalMatrixDirty:Bool = false;

	private var _renderElementsOffset = -1;
	private var _renderElementsCount = -1;

	private var _renderId:Int = 0;

	private var _renderZ:Float = 0.0;

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

	public inline function get_modelMatrix():Matrix4 {
		return this._worldMatrix;
	}

	public inline function get_modelViewMatrix():Matrix4 {
		return this._modelViewMatrix;
	}

	public inline function get_modelViewProjectionMatrix():Matrix4 {
		return this._modelViewProjectionMatrix;
	}

	public inline function get_normalMatrix():Matrix4 {
		return this.getNormalMatrix();
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

	public inline function get_renderZ():Float {
		return this._renderZ;
	}

	public inline function get_renderId():Int {
		return this._renderId;
	}

	public inline function set_renderId(value:Int) {
		return this._renderId = value;
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

	public inline function getNormalMatrix():Matrix4 {
		if (this._normalMatrixDirty) {
			// normal matrix
			this._normalMatrix.copyFrom(this._modelViewMatrix);
			this._normalMatrix.invert();
			this._normalMatrix.transpose();

			this._normalMatrixDirty = false;
		}
		return this._normalMatrix;
	}

	public function updateRenderMatrices(camera:Camera):Void {
		// Model view matrix
		this._modelViewMatrix.copyFrom(camera.viewMatrix);
		this._modelViewMatrix.prepend(this._worldMatrix);

		// Set normal matrix as dirty but don't calculate it yet
		this._normalMatrixDirty = true;

		// Model view project matrix
		this._modelViewProjectionMatrix.copyFrom(this._modelViewMatrix);
		this._modelViewProjectionMatrix.append(camera.projectionMatrix);

	}

	public function renderBuffer(program:ShaderProgram, overrider:RendererOverrider = null):Void {
		var renderer = Director.current.renderer;
		var attributeManager = renderer.attributeManager;
		var bufferManager = renderer.bufferManager;

		var geometry = this._geometry;
		if (overrider != null && overrider.geometry != null && overrider.geometryBlend == GeometryBlendType.GeometryBlendTypeReplace) {
			geometry = overrider.geometry;
		}

		var isIndexed = geometry.isIndexed;

		// Initialise attribute manager for this object
		attributeManager.initForRenderObject();

		// Initialise state of attributes before render
		var programAttributes = program.attributes;
		for (attributeState in programAttributes) {
			attributeState.used = false;
		}

		// Bind geometry vertex buffers to the attribute locations
		this.bindVertexBuffersToProgramAttributes(geometry, programAttributes);

		// Add extra buffer data from overrider geometry for custom render pass
		if (overrider != null && overrider.geometry != null && overrider.geometryBlend == GeometryBlendType.GeometryBlendTypeMix) {
			this.bindVertexBuffersToProgramAttributes(overrider.geometry, programAttributes);
		}

		// Disable unused attributes
		attributeManager.disableUnusedAttributes();

		// Verify that all attributes are used
		for (attributeState in programAttributes) {
			if (attributeState.location >= 0 && !attributeState.used) {
				throw new XTException("UnusedVertexAttribute", "The vertex attribute \"" + attributeState.name + "\" is unused for the program \"" + program.name + "\"");
			}
		}


		if (isIndexed) {
			var indices = geometry.indices;

			// Bind the indices
			indices.bind(bufferManager);

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

	public function bindVertexBuffersToProgramAttributes(geometry:Geometry, programAttributes:Map<String, ProgramAttributeState>):Void {
		var renderer = Director.current.renderer;
		var attributeManager = renderer.attributeManager;
		var bufferManager = renderer.bufferManager;

		// Make sure the geometry data is up to date and is written to opengl buffers
		geometry.updateGeometry(bufferManager);

		// Iterate over program attributes
		for (programAttributeState in programAttributes) {
			var attributeName = programAttributeState.name;
			var attributeLocation = programAttributeState.location;

			// Verify that the attribute is used by the program AND contained by the geometry
			if (attributeLocation >= 0) {

				// Attach buffer to attribute pointer
				if (geometry.bindVertexBufferToAttribute(attributeName, attributeLocation, bufferManager)) {

					// Enable the attribute
					attributeManager.enableAttribute(attributeLocation);

					// Set the state as used
					programAttributeState.used = true;
				}
			}
		}
	}


	public function calculateRenderZ(screenProjectionMatrix:Matrix4):Void {
		var position:Vector4 = this.worldPosition;
		VectorHelper.applyProjection(position, screenProjectionMatrix);

		this._renderZ = position.z;
	}


	/* --------- Scene graph --------- */

	override public function prepareObjectForRender(scene:Scene, overrider:RendererOverrider = null):Void {
		super.prepareObjectForRender(scene, overrider);

		if (this._visible) {
			var material = this._material;
			if (overrider != null && overrider.material != null) {
				material = overrider.material;
			}

			// Add object to opaque or transparent list
			if (material.transparent || material.opacity < 1.0) {
				scene.addObjectToTransparentRenderList(this);

			} else {
				scene.addObjectToOpaqueRenderList(this);
			}
		}
	}

}
