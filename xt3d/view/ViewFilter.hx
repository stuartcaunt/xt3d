package xt3d.view;

import xt3d.material.TextureMaterial;
import xt3d.core.RendererOverrider;
import xt3d.core.Director;
import lime.math.Rectangle;
import xt3d.utils.color.Color;
import xt3d.utils.geometry.Size;
import xt3d.textures.RenderTexture;
import xt3d.material.ColorMaterial;
import xt3d.primitives.Plane;
import xt3d.node.MeshNode;
import xt3d.node.Camera;
import xt3d.node.Scene;

class ViewFilter extends View {

	// properties

	// members
	private var _filteredView:View;
	private var _planeNode:MeshNode;
	private var _material:TextureMaterial;
	private var _renderTexture:RenderTexture;
	private var _renderTextureViewport:Rectangle;

	public static function create(filteredView:View):ViewFilter {
		var object = new ViewFilter();

		if (object != null && !(object.init(filteredView))) {
			object = null;
		}

		return object;
	}

	public function init(filteredView:View):Bool {
		// Store filtered view
		this._filteredView = filteredView;

		// Create a material that we set the render texture in
		this._material = TextureMaterial.createWithColor(Color.createWithRGBHex(0xff0000));

		// Set up render texture and viewport
		this.updateViewSize();

		// add event listener to view
		this._filteredView.on('viewport_changed', this.updateViewSize);

		// Create scene
		this._scene = Scene.create();

		// Create camera and use an orthographic projection
		this._camera = Camera.create(this);

		// Plane geometry
		var plane = Plane.create(2.0, 2.0, 2, 2);

		// Create the plance mesh node that we'll fix the render texture to
		this._planeNode = MeshNode.create(plane, this._material);

		// Add plane node to scene centered at 0
		this._scene.addChild(this._planeNode);

		return true;
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override public function onEnter():Void {
		this._filteredView.onEnter();
	}

	override public function onExit():Void {
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
		// Update self
		super.updateView(rendererOverrider);

		var renderer = Director.current.renderer;

		// Update filtered view
		this._filteredView.updateView();

		// clear render texture
		if (this._filteredView.isOpaque) {
			// Opaque fill
			this._renderTexture.beginWithClear(this._filteredView.backgroundColor);

		} else {
			// Transparent fill
			this._renderTexture.beginWithClear();
		}

		// Set the viewport for the texture
		renderer.setViewport(this._renderTextureViewport);

		// Render filtered view to render texture
		this._renderTexture.render(this._filteredView);

		// End render to texture
		this._renderTexture.end();
	}

	private function updateViewSize():Void {

		// Copy all viewport characteristics from filtered viewport
		this._viewport = this._filteredView.viewport;
		this._viewportInPixels = this._filteredView.viewportInPixels;

		this._scissorEnabled = (
			this._viewport.x != 0 ||
			this._viewport.width != displaySize.width ||
			this._viewport.y != 0 ||
			this._viewport.height != displaySize.height);

		// Emit event
		this.emit("viewport_changed");

		this._backgroundColor = this._filteredView.backgroundColor;
		this._clearFlags = this._filteredView.clearFlags;

		// Todo : handle orientation ?

		// TODO : check for clear color changes
		// Create render texture if necessary
		if (this._renderTexture == null || this._renderTexture.contentSize.width != this._viewportInPixels.width || this._renderTexture.contentSize.height != this._viewportInPixels.height) {
			if (this._renderTexture != null) {
				this._renderTexture.dispose();
				this._renderTexture = null;
			}

			// Create render texture
			// TODO : texture options + depthStencilFormat using View clearColor
			this._renderTexture = RenderTexture.create(Size.createIntSize(Std.int(this._viewportInPixels.width), Std.int(this._viewportInPixels.height)));
			this._renderTexture.clearColor = Color.createWithRGBAHex(0x00000000);

			// Set the texture in the material
			this._material.texture = this._renderTexture;

			// Store the viewport for the texture
			this._renderTextureViewport = new Rectangle(0.0, 0.0, this._viewport.width, this._viewport.height);

			// TODO : update material

		}
	}

}
