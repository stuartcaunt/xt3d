package xt3d.view.filters;

import lime.math.Matrix3;
import xt3d.textures.RenderTexture;
import xt3d.textures.TextureOptions;
import xt3d.gl.GLCurrentContext.GL;
import xt3d.gl.XTGL;
import xt3d.material.Material;
import xt3d.utils.Types;
import xt3d.core.RendererOverrider;
import lime.math.Rectangle;
import xt3d.utils.color.Color;
import xt3d.utils.geometry.Size;
import xt3d.geometry.primitives.Plane;
import xt3d.node.MeshNode;
import xt3d.node.Camera;
import xt3d.node.Scene;

class ViewFilter extends View {

	// properties
	private var renderTargetStore(get, null):RenderTargetStore;

	// members
	private var _filteredView:View;
	private var _planeNode:MeshNode;
	private var _material:Material;

	private var _renderTargetStore:RenderTargetStore;


	public function initViewFilter(filteredView:View):Bool {
		// Store filtered view
		this._filteredView = filteredView;

		// Initialise temporary viewport
		this._viewport = new Rectangle(0.0, 0.0, 1, 1);

		// add event listener to view
		this._filteredView.on('viewport_changed', this.onFilteredViewSizeChanged);

		// Create scene
		this._scene = Scene.create();
		this._scene.zSortingStrategy = XTGL.ZSortingNone;

		// Create camera and use an orthographic projection
		this._camera = Camera.create(this);

		// Plane unit geometry
		var plane = Plane.create(1.0, 1.0, 2, 2);

		// Create a material that we set the render texture in
		this._material = this.createRenderNodeMaterial();

		// Create the plance mesh node that we'll fix the render texture to
		this._planeNode = MeshNode.create(plane, this._material);

		// Add plane node to scene centered at 0
		this._scene.addChild(this._planeNode);

		// Set up render texture and viewport
		this.onFilteredViewSizeChanged();

		return true;
	}

	function get_renderTargetStore():RenderTargetStore {
		if (this._renderTargetStore != null) {
			return this._renderTargetStore;

		} else {
			var viewFilter = cast(this._filteredView, ViewFilter);
			return viewFilter.renderTargetStore;
		}
	}


	/* ----------- Properties ----------- */

	override function get_viewTransform():Matrix3 {
		return this._filteredView.viewTransform;
	}

	override function set_viewTransform(value:Matrix3):Matrix3 {
		return this._filteredView.viewTransform = value;
	}

	/* --------- Implementation --------- */

	override public function onEnter():Void {
		super.onEnter();

		// Create render texture store if filteredView is not a ViewFilter
		if (!Std.is(this._filteredView, ViewFilter)) {
			this._renderTargetStore = RenderTargetStore.create();
		}

		this._filteredView.onEnter();
	}

	override public function onExit():Void {
		super.onExit();

		// Create render texture store if filteredView is not a ViewFilter
		if (this._renderTargetStore != null) {
			this._renderTargetStore.dispose();

			this._renderTargetStore = null;
		}

		this._filteredView.onExit();
	}

	override public function setDisplaySize(displaySize:Size<Int>):Void {
		this._filteredView.setDisplaySize(displaySize);
	}

	override public function containsScreenPosition(x:Float, y:Float):Bool {
		return this._filteredView.containsScreenPosition(x, y);
	}

	override public function isNodeInView(node):Bool {
		return this._filteredView.isNodeInView(node);
	}

	override public function updateView(rendererOverrider:RendererOverrider = null):Void {
		// The "render to texture" phase: update filtered view, update targets and materials and do the render
		// At the end our "_material" should be ready to render to the node

		// Update filtered view
		this._filteredView.updateView(rendererOverrider);

		// Verify render targets are coherent with view dimensions
		this.updateRenderTargets();

		// Update render material
		this.updateRenderMaterials();

		// Render shared render targets
		if (this._renderTargetStore != null) {
			_renderTargetStore.renderToRenderTargets();
		}

		// Render view to targets
		this.renderToRenderTargets();

		// Material transparent or not
		if (!this._filteredView.isOpaque || this._filteredView.backgroundColor.a < 1.0) {
			this._material.transparent = true;

		} else {
			this._material.transparent = false;
		}

		// Perform update of scene in view filter
		super.updateView(rendererOverrider);
	}

	private function updateRenderTargets():Void {
		// Override me
		// Make any changes to render target, taking into account potential changes to render texture size
	}

	private function renderToRenderTargets():Void {
		// Override me
	}

	private function createRenderNodeMaterial():Material {
		// Override me
		return null;
	}

	private function updateRenderMaterials():Void {
		// Override me
		// Make any changes to material uniforms
	}

	private function onFilteredViewSizeChanged():Void {
		// Copy all viewport characteristics from filtered viewport
		this._viewport = this._filteredView.viewport;
		this._viewportInPixels = this._filteredView.viewportInPixels;
		this._scissorEnabled = this._filteredView.scissorEnabled;

		this._backgroundColor = this._filteredView.backgroundColor;
		this._clearFlags = this._filteredView.clearFlags;

		// Setup node scale and camera for width and height
		var width = this._viewport.width;
		var height = this._viewport.height;

		// Scale the render node to be the same size as the render texure
		this._planeNode.scaleX = width;
		this._planeNode.scaleY = height;

		// Change the camera ortho projection to show all the texture
		this._camera.setOrthoProjection(-0.5 * width, 0.5 * width, -0.5 * height, 0.5 * height, 1.0, 10.0, XTOrientation.Orientation0);

		// Emit event
		this.emit("viewport_changed");

		// Update view/model matrices
		super.updateView();

		// Todo : handle orientation ?
	}


	private function registerSharedRenderTarget(targetName, targetRenderer:RenderTexture -> Void):Void {
		this.renderTargetStore.registerRenderTarget(targetName, targetRenderer);
	}

	private function unregisterSharedRenderTarget(targetName):Void {
		this.renderTargetStore.unregisterRenderTarget(targetName);
	}

	private function updateSharedRenderTarget(targetName:String, size:Size<Int>, textureOptions:TextureOptions = null, depthStencilFormat:Int = XTGL.DepthStencilFormatDepth):Void {
		this.renderTargetStore.updateRenderTarget(targetName, size, textureOptions, depthStencilFormat);
	}

	private function getSharedRenderTexture(targetName:String):RenderTexture {
		return this.renderTargetStore.getRenderTexture(targetName);
	}

}
