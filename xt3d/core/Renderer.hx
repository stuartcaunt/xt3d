package xt3d.core;

import xt3d.view.View;
import xt3d.gl.GLExtensionManager;
import lime.utils.ArrayBufferView;
import xt3d.gl.GLInfo;
import lime.math.Rectangle;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLFramebuffer;
import xt3d.utils.XTObject;
import xt3d.textures.RenderTexture;
import xt3d.gl.GLFrameBufferManager;
import xt3d.utils.XT;
import xt3d.gl.GLTextureManager;
import xt3d.gl.GLBufferManager;
import xt3d.gl.GLAttributeManager;
import xt3d.gl.GLStateManager;
import xt3d.gl.shaders.ShaderProgram;
import xt3d.gl.shaders.UniformLib;
import xt3d.math.Matrix4;
import xt3d.utils.color.Color;
import xt3d.gl.XTGL;
import xt3d.gl.shaders.ShaderManager;
import xt3d.node.Camera;
import xt3d.lights.Light;
import xt3d.material.Material;
import xt3d.node.Scene;
import xt3d.node.RenderObject;
import lime.graphics.opengl.GL;


class Renderer extends XTObject {

	// properties
	public var extensionManager(get, null):GLExtensionManager;
	public var stateManager(get, null):GLStateManager;
	public var bufferManager(get, null):GLBufferManager;
	public var attributeManager(get, null):GLAttributeManager;
	public var textureManager(get, null):GLTextureManager;
	public var frameBufferManager(get, null):GLFrameBufferManager;
	public var shaderManager(get, null):ShaderManager;

	public var renderTarget(get, set):RenderTexture;

	// members
	private var _gl:GLRenderContext;
	private var _glInfo:GLInfo;
	private var _extensionManager:GLExtensionManager;
	private var _stateManager:GLStateManager;
	private var _bufferManager:GLBufferManager;
	private var _attributeManager:GLAttributeManager;
	private var _textureManager:GLTextureManager;
	private var _frameBufferManager:GLFrameBufferManager;

	private var _uniformLib:UniformLib;
	private var _shaderManager:ShaderManager;

	private var _viewport:Rectangle;
	private var _scissor:Rectangle = null;
	private var _viewProjectionMatrix = new Matrix4();

	private var _currentProgram:ShaderProgram = null;
	private var _renderPassShaders:Map<String, ShaderProgram> = null;

	private var _screenFrameBuffer:GLFramebuffer = null;
	private var _renderTarget:RenderTexture = null;

	private var _globalTime:Float = 0.0;

	public static function create(gl:GLRenderContext):Renderer {
		var object = new Renderer();

		if (object != null && !(object.init(gl))) {
			object = null;
		}

		return object;
	}

	public function init(gl:GLRenderContext):Bool {
		this._gl = gl;

		this._glInfo = GLInfo.create();
		this._extensionManager = GLExtensionManager.create();
		this._stateManager = GLStateManager.create();
		this._bufferManager = GLBufferManager.create();
		this._attributeManager = GLAttributeManager.create(this._glInfo);
		this._textureManager = GLTextureManager.create(this._glInfo);
		this._frameBufferManager = GLFrameBufferManager.create();

		// Initialise uniform lib
		this._uniformLib = UniformLib.create();

		// Initialise shader manager and build default shaders
		this._shaderManager = ShaderManager.create(this._uniformLib, this._glInfo);
		this._shaderManager.loadDefaultShaders();

#if ios
		// Keep reference to screen frame and render buffers - these are not null for iOS
		this._screenFrameBuffer = new GLFramebuffer(GL.version, GL.getParameter(GL.FRAMEBUFFER_BINDING));
#end
		// Register with scheduler for time updates
		this.schedule(this.updateGlobalTime);


		this._stateManager.setDefaultGLState();

		return true;
	}


	public function new() {
		super();
	}

	// Properties

	public inline function get_extensionManager():GLExtensionManager {
		return this._extensionManager;
	}

	public inline function get_stateManager():GLStateManager {
		return this._stateManager;
	}

	public inline function get_bufferManager():GLBufferManager {
		return this._bufferManager;
	}

	public inline function get_attributeManager():GLAttributeManager {
		return this._attributeManager;
	}

	public inline function get_textureManager():GLTextureManager {
		return this._textureManager;
	}

	public inline function get_frameBufferManager():GLFrameBufferManager {
		return this._frameBufferManager;
	}

	public inline function get_shaderManager():ShaderManager {
		return this._shaderManager;
	}

	function get_renderTarget():RenderTexture {
		return this._renderTarget;
	}

	function set_renderTarget(value:RenderTexture) {
		this.setRenderTarget(value);
		return this._renderTarget;
	}

	// Implementation

	public inline function updateGlobalTime(deltaTime:Float):Void {
		this._globalTime += deltaTime;
		this._uniformLib.uniform("time").floatValue = this._globalTime;
	}

	public function setRenderTarget(renderTarget:RenderTexture = null):Void {

		if (renderTarget == null) {
			// Reset the color mask, by default alpha not renderered to screen
			this._stateManager.setColorMask(true, true, true, false);

			// Reset frame and render buffer
			this._frameBufferManager.setFrameBuffer(this._screenFrameBuffer);

		} else {
			// Set the color mask to correctly render alpha
			this._stateManager.setColorMask(true, true, true, true);
			this._frameBufferManager.setFrameBuffer(renderTarget.frameBuffer);
		}

		this._renderTarget = renderTarget;
	}

	public function setViewport(viewport:Rectangle):Void {
		// Set the viewport
		if (_viewport == null || !_viewport.equals(viewport)) {
			_viewport = viewport;
			GL.viewport(Std.int (_viewport.x), Std.int (_viewport.y), Std.int (_viewport.width), Std.int (_viewport.height));
			//XT.Log("Setting viewport to " + Std.int (_viewport.x) + ", " + Std.int (_viewport.y) + ", " + Std.int (_viewport.width) + ", " + Std.int (_viewport.height));
			this._uniformLib.uniform("viewport").floatArrayValue = [_viewport.x, _viewport.y, _viewport.width, _viewport.height];
		}
	}

	public function enableScissor(scissor:Rectangle):Void {
		// Set and enable the scissor
		if (_scissor == null || !_scissor.equals(scissor)) {
			_scissor = scissor;
			GL.scissor(Std.int (_scissor.x), Std.int (_scissor.y), Std.int (_scissor.width), Std.int (_scissor.height));
		}
		this._stateManager.setScissorTest(true);
	}

	public inline function disableScissor():Void {
		this._stateManager.setScissorTest(false);
	}

	public function clear(color:Color, clearFlags:Int = 0) {
		// Set clear flags
		if (clearFlags == 0) {
			clearFlags = GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT;
		}

		if ((clearFlags & GL.COLOR_BUFFER_BIT) != 0 && color != null) {
			// Set clear color
			this._stateManager.setClearColor(color);
		}

		// clear buffer bits
		GL.clear(clearFlags);
	}

	public function updateScene(scene:Scene, camera:Camera, rendererOverrider:RendererOverrider) {
		// Update world matrices of scene graph
		scene.updateWorldMatrix();

		// Make sure camera matrix is updated even if it has not been added to the scene
		if (camera.parent == null) {
			camera.updateWorldMatrix();
		}

		// Update objects - anything that needs to be done before rendering
		scene.prepareObjectsForRender(scene, rendererOverrider);
	}

	public function render(scene:Scene, camera:Camera, overrider:RendererOverrider = null) {

		// Get view projection matrix
		this._viewProjectionMatrix.copyFrom(camera.viewProjectionMatrix);

		// Set global uniforms for camera
		camera.prepareCommonRenderUniforms(this._uniformLib);

		// Set global uniforms for scene
		scene.prepareCommonRenderUniforms(camera, this._uniformLib);

		// Sort objects
		var sortingEnabled = (scene.zSortingStrategy != XTGL.ZSortingNone);
		if (overrider != null) {
			sortingEnabled = overrider.sortingEnabled;
		}
		if (sortingEnabled) {

			if (scene.zSortingStrategy & XTGL.ZSortingOpaque > 0) {
				// Project transparent objects if we want to sort them in z
				for (renderObject in scene.opaqueObjects) {
					renderObject.calculateRenderZ(this._viewProjectionMatrix);
				}

				// Sort opaque objects by z
				scene.opaqueObjects.sort(this.reversePainterSortStable);
			} else {
				// Sort opaque objects by material Id (avoid swapping shaders often)
				scene.opaqueObjects.sort(this.materialSortStable);
			}

			if (scene.zSortingStrategy & XTGL.ZSortingTransparent > 0) {
				// Project transparent objects if we want to sort them in z
				for (renderObject in scene.transparentObjects) {
					renderObject.calculateRenderZ(this._viewProjectionMatrix);
				}

				// Sort transparent objects by z
				scene.transparentObjects.sort(this.painterSortStable);
			} else {
				// Sort transparent obejcts by material/object id (group by shader)
				scene.transparentObjects.sort(this.materialSortStable);
			}

		}

		// Render opaque objects
		_stateManager.setBlending(XTGL.NoBlending);
		this.renderObjects(scene.opaqueObjects, camera, false, overrider);


		var blendingEnabled = true;
		if (overrider != null) {
			blendingEnabled = overrider.blendingEnabled;
		}

		// Render transparent objects (if overrider allows for blending)
		this.renderObjects(scene.transparentObjects, camera, blendingEnabled, overrider);

		// Prepare all common uniforms
		this._uniformLib.prepareUniforms();
	}

	/**
	 * Render list of objects
	 **/
	public function renderObjects(renderObjects:Array<RenderObject>, camera:Camera, useBlending:Bool, overrider:RendererOverrider) {

		// Initialise states of shader programs
		this._renderPassShaders = new Map<String, ShaderProgram>();
		this._currentProgram = null;

		for (renderObject in renderObjects) {
			//XT.Log("Rendering object " + renderObject.id);

			// Update model matrices
			renderObject.updateRenderMatrices(camera);

			// Set matrices in uniform lib
			this._uniformLib.uniform("modelMatrix").matrixValue = renderObject.modelMatrix;
			this._uniformLib.uniform("modelViewMatrix").matrixValue = renderObject.modelViewMatrix;
			this._uniformLib.uniform("modelViewProjectionMatrix").matrixValue = renderObject.modelViewProjectionMatrix;
			this._uniformLib.uniform("normalMatrix").matrixValue = renderObject.normalMatrix;

			// Update shader program (overrider if necessary)
			var material = renderObject.material;
			if (overrider != null) {
				// Customise material before rendering the object
				material = overrider.getMaterialOverride(renderObject, material);
			}

			// Set blending
			if (useBlending) {
				_stateManager.setBlending(material.blending, material.blendEquation, material.blendSrc, material.blendDst, material.blendEquationAlpha, material.blendSrcAlpha, material.blendDstAlpha);
			}

			// Depth
			_stateManager.setDepthTest(material.depthTest);
			_stateManager.setDepthWrite(material.depthWrite);

			// Polygon offset
			_stateManager.setPolygonOffset(material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits);

			// Set material face sides
			_stateManager.setMaterialSides(material.side);

			// Render the object buffers
			this.renderBuffer(material, renderObject, camera, overrider);
		}
	}

	private function renderBuffer(material:Material, renderObject:RenderObject, camera:Camera, overrider:RendererOverrider):Void {

		// Set program and uniforms
		this.setProgram(material, renderObject, camera);

		// Render the buffers
		renderObject.renderBuffer(material.program, overrider);
	}

	private function setProgram(material:Material, renderObject:RenderObject, camera:Camera):Void {

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
				program.updateGlobalUniforms(this._uniformLib);

				this._renderPassShaders.set(program.name, program);
			}
		}

		// Always update material - may be shared between different objects and require new uniform values (eg mvp matrices)
		// Send material uniform values to program
		material.updateProgramUniforms(this._uniformLib);
	}


	private function materialSortStable(a:RenderObject, b:RenderObject):Int {

		if (a.material.depthWrite != b.material.depthWrite) {
			return a.material.depthWrite ? 1 : -1;

		} else if (a.material.programId != b.material.programId) {
			return a.material.programId - b.material.programId;

		} else {
			// First added first rendered
			return a.id - b.id;
		}
	}

	private function reversePainterSortStable(a:RenderObject, b:RenderObject):Int {

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

	private function painterSortStable(a:RenderObject, b:RenderObject):Int {

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