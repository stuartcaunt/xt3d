package kfsgl.renderer;

import kfsgl.renderer.shaders.ShaderProgram;
import kfsgl.renderer.shaders.UniformLib;
import openfl.geom.Matrix3D;
import kfsgl.utils.Color;
import kfsgl.utils.KF;
import kfsgl.utils.gl.KFGL;
import kfsgl.renderer.shaders.ShaderManager;
import kfsgl.camera.Camera;
import kfsgl.material.Material;
import kfsgl.node.Scene;
import kfsgl.node.RenderObject;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;
import flash.geom.Rectangle;



class Renderer {

	private var _stateManager:GLStateManager;

	private var _viewport:Rectangle;
	private var _viewProjectionMatrix = new Matrix3D();

	private var _currentProgram:ShaderProgram = null;
	private var _currentMaterial:Material = null;
	private var _renderPassShaders:Map<String, ShaderProgram> = null;

	public function new() {
	}

	public function init() {
		// Build all shaders
		ShaderManager.instance().loadDefaultShaders();

		_stateManager = GLStateManager.create();
	}


	public function clear(viewport:Rectangle, color:Color) {
		// Set the viewport
		if (_viewport == null || !_viewport.equals(viewport)) {
			_viewport = viewport;
			GL.viewport(Std.int (_viewport.x), Std.int (_viewport.y), Std.int (_viewport.width), Std.int (_viewport.height));
			//KF.Log("Setting viewport to " + Std.int (_viewport.x) + ", " + Std.int (_viewport.y) + ", " + Std.int (_viewport.width) + ", " + Std.int (_viewport.height));
		}

		// Clear color
		GL.clearColor(color.red, color.green, color.blue, 1.0);

		// clear buffer bits
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}


	public function render(scene:Scene, camera:Camera) {
		if (scene != null && camera != null) {

			// Update world matrices of scene graph
			scene.updateWorldMatrix();

			// Make sure camera matrix is updated even if it has not been added to the scene
			if (camera.parent == null) {
				camera.updateWorldMatrix();
			}

			// Update objects - anything that needs to be done before rendering
			scene.updateObjects(scene);

			// Project objects if we want to sort them in z

			// Sort transparent objects


			// Send custom-pre-render-pass event

			// Render opaque objects
			_stateManager.setBlending(KFGL.NoBlending);
			this.renderObjects(scene.opaqueObjects, camera/*, scene.lights*/, false/*, overrideMaterial*/);

			// Render transparent objects
			this.renderObjects(scene.transparentObjects, camera/*, scene.lights*/, true/*, overrideMaterial*/);

			// Send custom-post-render-pass event
		}
	}

	/**
	 * Render list of objects
	 **/
	public function renderObjects(renderObjects:Array<RenderObject>, camera:Camera/*, lights:Array<Light>*/, useBlending:Bool/*, overrideMaterial:Material*/) {

		// Get view projection matrix
		this._viewProjectionMatrix.copyFrom(camera.viewProjectionMatrix);

		// Set global uniforms
		UniformLib.instance().uniform("viewMatrix").matrixValue = camera.viewMatrix;
		UniformLib.instance().uniform("projectionMatrix").matrixValue = camera.projectionMatrix;

		// lights
		//UniformLib.instance().uniform("lights", "...").matrixValue = ...;

		// Initialise states of shader programs
		this._renderPassShaders = new Map<String, ShaderProgram>();
		this._currentProgram = null;
		this._currentMaterial = null;

		for (renderObject in renderObjects) {

			// Update model matrices
			renderObject.updateRenderMatrices(camera);

			// Set matrices in uniform lib
			UniformLib.instance().uniform("modelMatrix").matrixValue = renderObject.modelMatrix;
			UniformLib.instance().uniform("modelViewMatrix").matrixValue = renderObject.modelViewMatrix;
			UniformLib.instance().uniform("modelViewProjectionMatrix").matrixValue = renderObject.modelViewProjectionMatrix;
			UniformLib.instance().uniform("normalMatrix").matrixValue = renderObject.normalMatrix;

			// Update shader program
			var material = renderObject.material;

			// Set blending
			if (useBlending) {
				_stateManager.setBlending(material.blending, material.blendEquation, material.blendSrc, material.blendDst);
			}

			// Depth
			_stateManager.setDepthTest(material.depthTest);
			_stateManager.setDepthWrite(material.depthWrite);

			// Polygon offset
			_stateManager.setPolygonOffset(material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits);

			// Set material face sides
			_stateManager.setMaterialSides(material.side);

			// Set program if it is not the same
			this.setProgram(material, renderObject, camera/*, lights*/);

		}
	}

	private function setProgram(material:Material, renderObject:RenderObject, camera:Camera/*, lights:Array<Light>*/):Void {
		var program = material.program;

		//var refreshLights:Bool = false;

		if (this._currentProgram != program) {
			this._currentProgram = program;

			// Use program
			program.use();

			// If the program has already been used in this render pass then don't update global uniforms
			// NB: this just stops the values been updated locally - all uniforms check for changed values before sending to the GPU
			if (!this._renderPassShaders.exists(program.name)) {
				// Update global uniforms in the shader
				program.updateGlobalUniforms();

				this._renderPassShaders.set(program.name, program);
			}
		}


		// If material has changed then update the program uniforms from the material uniforms
		if (this._currentMaterial != material) {
			this._currentMaterial = material;

			// Send material uniform values to program
			material.updateProgramUniforms();
		}

	}


}