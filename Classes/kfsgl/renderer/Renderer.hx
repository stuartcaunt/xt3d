package kfsgl.renderer;

import kfsgl.utils.Color;
import kfsgl.utils.KF;
import kfsgl.renderer.shaders.ShaderManager;
import kfsgl.camera.Camera;
import kfsgl.node.Scene;
import kfsgl.node.RenderObject;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;
import flash.geom.Rectangle;



class Renderer {

	// State
	private var _currentVertexBuffer:GLBuffer;
	private var _currentElementBuffer:GLBuffer;

	private var _viewport:Rectangle;

	public function new() {
	}

	public function init() {
		// Build all shaders
		ShaderManager.instance().loadDefaultShaders();
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


	public function renderScene(scene:Scene, camera:Camera) {

	}

	/**
	 * Render list of objects
	 **/
	public function renderObjects(objects:Array<RenderObject>) {

	}


	private function setVertexBuffer(vertexBuffer:GLBuffer):Void {
		if (this._currentVertexBuffer != vertexBuffer) {
			this._currentVertexBuffer = vertexBuffer;

			GL.bindBuffer(GL.ARRAY_BUFFER, this._currentVertexBuffer);
		}
	}

	private function setElementBuffer(elementBuffer:GLBuffer):Void {
		if (this._currentElementBuffer != elementBuffer) {
			this._currentElementBuffer = elementBuffer;

			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this._currentElementBuffer);
		}
	}

}