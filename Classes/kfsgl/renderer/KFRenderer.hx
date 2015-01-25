package kfsgl.renderer;

import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;
import flash.geom.Rectangle;

import kfsgl.utils.KFColor;
import kfsgl.utils.KF;
import kfsgl.renderer.shaders.KFShaderManager;


class KFRenderer {

	// State

	// shader manager
	private var _shaderManager:KFShaderManager;

	private var _viewport:Rectangle;

	public function new() {
		_shaderManager = new KFShaderManager();
	}

	public function init() {
		// Build all shaders
		_shaderManager.loadDefaultShaders();


	}

	public function clear(viewport:Rectangle, color:KFColor) {
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

}