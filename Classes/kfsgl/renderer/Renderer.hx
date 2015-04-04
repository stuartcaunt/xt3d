package kfsgl.renderer;

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

	private var _currentProgram = null;

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
			KF.Log("Setting viewport to " + Std.int (_viewport.x) + ", " + Std.int (_viewport.y) + ", " + Std.int (_viewport.width) + ", " + Std.int (_viewport.height));
		}

		// Clear color
		GL.clearColor(color.red, color.green, color.blue, 1.0);

		// clear buffer bits
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}


	public function render(scene:Scene, camera:Camera) {
		if (scene != null && camera != null) {

			// send pre-render event (custom updates before rendering)

			// Update world matrices of scene graph
			scene.updateWorldMatrix();

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

			// Send post-render event

		}
	}

	/**
	 * Render list of objects
	 **/
	public function renderObjects(renderObjects:Array<RenderObject>, camera:Camera/*, lights:Array<Light>*/, useBlending:Bool/*, overrideMaterial:Material*/) {

		// Set up camera
		this._viewProjectionMatrix.copyFrom(camera.viewProjectionMatrix);

		for (renderObject in renderObjects) {

			// Update model matrices
			renderObject.updateRenderMatrices(camera);

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



}