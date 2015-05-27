package kfsgl.core;

import openfl.gl.GLRenderbuffer;
import openfl.gl.GLFramebuffer;
import kfsgl.gl.GLFrameBufferManager;
import kfsgl.utils.KF;
import kfsgl.gl.GLTextureManager;
import kfsgl.gl.GLBufferManager;
import kfsgl.gl.GLAttributeManager;
import kfsgl.gl.GLStateManager;
import kfsgl.gl.shaders.ShaderProgram;
import kfsgl.gl.shaders.UniformLib;
import openfl.geom.Matrix3D;
import kfsgl.utils.Color;
import kfsgl.gl.KFGL;
import kfsgl.gl.shaders.ShaderManager;
import kfsgl.core.Camera;
import kfsgl.core.Material;
import kfsgl.node.Scene;
import kfsgl.node.RenderObject;
import openfl.gl.GL;
import openfl.geom.Rectangle;



class Renderer {

	// properties
	public var textureManager(get, null):GLTextureManager;
	public var frameBufferManager(get, null):GLFrameBufferManager;
	public var sortingEnabled(get, set):Bool;


	// members
	private var _stateManager:GLStateManager;
	private var _bufferManager:GLBufferManager;
	private var _attributeManager:GLAttributeManager;
	private var _textureManager:GLTextureManager;
	private var _frameBufferManager:GLFrameBufferManager;
	private var _needsStateInit:Bool = true;

	private var _viewport:Rectangle;
	private var _viewProjectionMatrix = new Matrix3D();

	private var _currentProgram:ShaderProgram = null;
	private var _renderPassShaders:Map<String, ShaderProgram> = null;
	private var _sortingEnabled:Bool = true;

	var _screenFrameBuffer:GLFramebuffer = null;
	var _screenRenderBuffer:GLRenderbuffer = null;

	public static function create():Renderer {
		var object = new Renderer();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {

		this._stateManager = GLStateManager.create();
		this._bufferManager = GLBufferManager.create();
		this._attributeManager = GLAttributeManager.create();
		this._textureManager = GLTextureManager.create();
		this._frameBufferManager = GLFrameBufferManager.create();

		// Build all shaders
		ShaderManager.instance().loadDefaultShaders(this._textureManager);

#if ios
		// Keep reference to screen frame and render buffers - these are not null for iOS
		this._screenFrameBuffer = new GLFramebuffer(GL.version, GL.getParameter(GL.FRAMEBUFFER_BINDING));
		this._screenRenderBuffer = new GLRenderbuffer(GL.version, GL.getParameter(GL.RENDERBUFFER_BINDING));
#end
		return true;
	}


	public function new() {
	}


	// Properties

	public inline function get_textureManager():GLTextureManager {
		return this._textureManager;
	}

	public inline function get_frameBufferManager():GLFrameBufferManager {
		return this._frameBufferManager;
	}

	public inline function get_sortingEnabled():Bool {
		return this._sortingEnabled;
	}

	public inline function set_sortingEnabled(value:Bool) {
		return this._sortingEnabled = value;
	}


	// Implementation

	public function resetFrameBuffer():Void {

		// Reset frame and render buffer
		this._frameBufferManager.setFrameBuffer(this._screenFrameBuffer);
		this._frameBufferManager.setRenderBuffer(this._screenRenderBuffer);
	}

	public function clear(viewport:Rectangle, color:Color) {
		// Set the viewport
		if (_viewport == null || !_viewport.equals(viewport)) {
			_viewport = viewport;
			GL.viewport(Std.int (_viewport.x), Std.int (_viewport.y), Std.int (_viewport.width), Std.int (_viewport.height));
			//KF.Log("Setting viewport to " + Std.int (_viewport.x) + ", " + Std.int (_viewport.y) + ", " + Std.int (_viewport.width) + ", " + Std.int (_viewport.height));
		}

		// Clear color
		GL.clearColor(color.red, color.green, color.blue, color.alpha);

		// clear buffer bits
		// TODO : use state management on colors/depth values : see cocos2d
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT);
	}


	public function render(scene:Scene, camera:Camera) {

		// Not great... can only set the default here ? Not before the first render ?
		if (this._needsStateInit) {
			this._stateManager.setDefaultGLState();
			this._needsStateInit = false;
		}

		if (scene != null && camera != null) {

			// Update world matrices of scene graph
			scene.updateWorldMatrix();

			// Make sure camera matrix is updated even if it has not been added to the scene
			if (camera.parent == null) {
				camera.updateWorldMatrix();
			}

			// Get view projection matrix
			this._viewProjectionMatrix.copyFrom(camera.viewProjectionMatrix);

			// Update objects - anything that needs to be done before rendering
			scene.updateObjects(scene);

			// Sort objects
			if (this._sortingEnabled) {

				if (scene.zSortingStrategy & KFGL.ZSortingOpaque > 0) {
					// Project transparent objects if we want to sort them in z
					for (renderObject in scene.opaqueObjects) {
						renderObject.calculateRenderZ(this._viewProjectionMatrix);
					}

					// Sort opaque objects by z
					scene.opaqueObjects.sort(this.painterSortStable);
				} else {
					// Sort opaque objects by material Id (avoid swapping shaders often)
					scene.opaqueObjects.sort(this.materialSortStable);
				}

				if (scene.zSortingStrategy & KFGL.ZSortingTransparent > 0) {
					// Project transparent objects if we want to sort them in z
					for (renderObject in scene.transparentObjects) {
						renderObject.calculateRenderZ(this._viewProjectionMatrix);
					}

					// Sort transparent objects by z
					scene.transparentObjects.sort(this.reversePainterSortStable);
				} else {
					// Sort transparent obejcts by material/object id (group by shader)
					scene.transparentObjects.sort(this.materialSortStable);
				}

			}

			// Render opaque objects
			_stateManager.setBlending(KFGL.NoBlending);
			this.renderObjects(scene.opaqueObjects, camera/*, scene.lights*/, false/*, overrideMaterial*/);

			// Render transparent objects
			this.renderObjects(scene.transparentObjects, camera/*, scene.lights*/, true/*, overrideMaterial*/);

			// Prepare all common uniforms
			UniformLib.instance().prepareUniforms();
		}
	}

	/**
	 * Render list of objects
	 **/
	public function renderObjects(renderObjects:Array<RenderObject>, camera:Camera/*, lights:Array<Light>*/, useBlending:Bool/*, overrideMaterial:Material*/) {

		// Set global uniforms
		UniformLib.instance().uniform("viewMatrix").matrixValue = camera.viewMatrix;
		UniformLib.instance().uniform("projectionMatrix").matrixValue = camera.projectionMatrix;

		// lights
		//UniformLib.instance().uniform("lights", "...").matrixValue = ...;

		// Initialise states of shader programs
		this._renderPassShaders = new Map<String, ShaderProgram>();
		this._currentProgram = null;

		for (renderObject in renderObjects) {
			//KF.Log("Rendering object " + renderObject.id);

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

			// Render the object buffers
			this.renderBuffer(material, renderObject, camera/*, lights*/);
		}
	}

	private function renderBuffer(material:Material, renderObject:RenderObject, camera:Camera/*, lights:Array<Light>*/):Void {

		// Set program and uniforms
		this.setProgram(material, renderObject, camera/*, lights*/);

		// Render the buffers
		renderObject.renderBuffer(material.program, this._attributeManager, this._bufferManager);
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
				program.updateGlobalUniforms(this._textureManager);

				this._renderPassShaders.set(program.name, program);
			}
		}

		// Always update material - may be shared between different objects and require new uniform values (eg mvp matrices)
		// Send material uniform values to program
		material.updateProgramUniforms(this._textureManager);
	}


	function materialSortStable(a:RenderObject, b:RenderObject):Int {

		if (a.material.depthWrite != b.material.depthWrite) {
			return a.material.depthWrite ? 1 : -1;

		} else if (a.material.programId != b.material.programId) {
			return a.material.programId - b.material.programId;

		} else {
			// First added first rendered
			return a.id - b.id;
		}
	}

	function painterSortStable(a:RenderObject, b:RenderObject):Int {

		if (a.material.depthWrite != b.material.depthWrite) {
			return a.material.depthWrite ? 1 : -1;

		} else if (a.material.programId != b.material.programId) {
			return a.material.programId - b.material.programId;

		} else if (a.renderZ != b.renderZ) {
			// Front to back (improve render perf by not rendering hidden pixels)
			return (a.renderZ - b.renderZ) < 0.0 ? -1 : 1;

		} else {
			return b.id - a.id;
		}
	}

	function reversePainterSortStable(a:RenderObject, b:RenderObject):Int {

		if (a.material.depthWrite != b.material.depthWrite) {
			return a.material.depthWrite ? 1 : -1;

		} else if (a.renderZ != b.renderZ) {
			// Back to front
			return (b.renderZ - a.renderZ) < 0.0 ? -1 : 1;

		} else {
			// First added first rendered
			return a.id - b.id;
		}
	}


}