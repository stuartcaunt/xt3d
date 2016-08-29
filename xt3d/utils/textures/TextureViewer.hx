package xt3d.utils.textures;

import xt3d.gl.XTGL;
import xt3d.geometry.primitives.Plane;
import xt3d.material.Material;
import lime.math.Rectangle;
import xt3d.textures.Texture2D;
import xt3d.node.MeshNode;
import xt3d.core.Director;
import xt3d.view.View;

typedef MaterialConfig = {
	materialName:String,
	textureUniformName:String,
};

class TextureViewer extends View {

	// properties

	// members
	private var _textureViews:Map<String, MeshNode> = new Map<String, MeshNode>();

	public static function createTextureViewer():TextureViewer {
		var object = new TextureViewer();

		if (object != null && !(object.initTextureViewer())) {
			object = null;
		}

		return object;
	}

	public function initTextureViewer():Bool {

		var retval;
		if ((retval = super.initBasic2D())) {
			this.scene.zSortingStrategy = XTGL.ZSortingNone;

			// Add listeners
			Director.current.on("resize", this.resizeTextureViewer);
			Director.current.on("post_render", this.renderTextureViewer);
		}

		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function dispose():Void {
		// Delete all texture Views
		var textureNames = this._textureViews.keys();
		for (textureName in textureNames) {
			this.removeTexture(textureName);
		}

		// Remove listeners
		Director.current.removeListener("resize", this.resizeTextureViewer);
		Director.current.removeListener("post_render", this.renderTextureViewer);
	}

	public function addTexture(textureName:String, texture:Texture2D, rect:Rectangle, materialConfig:MaterialConfig = null):Void {
		if (materialConfig == null) {
			materialConfig = {
				materialName: "generic+texture",
				textureUniformName: "texture"
			};
		}

		// Create the material
		var material = Material.createMaterial(materialConfig.materialName);
		material.depthTest = false;
		material.depthWrite = false;

		// Create or modify the mesh node
		var textureView:MeshNode = this._textureViews.get(textureName);
		if (textureView != null) {
			textureView.material.dispose();

			textureView.material = material;

		} else {
			var geometry = Plane.create(1.0, 1.0, 2, 2);
			textureView = MeshNode.create(geometry, material);

			this._textureViews.set(textureName, textureView);

			// Add to the scene
			this.scene.addChild(textureView);
		}

		// Set the texture
		material.uniform(materialConfig.textureUniformName).texture = texture;

		// Set the size and position of the mesh node
		textureView.setPositionValues(rect.x + 0.5 * rect.width, rect.y + 0.5 * rect.height, 0.0);
		textureView.scaleX = rect.width;
		textureView.scaleY = rect.height;
		textureView.updateWorldMatrix();
	}

	public function removeTexture(textureName:String):Void {
		var textureView:MeshNode = this._textureViews.get(textureName);
		if (textureView != null) {
			// Dispose of opengl objects
			textureView.material.dispose();
			textureView.geometry.dispose();

			// remove from the map
			this._textureViews.remove(textureName);

			// Remove from the scene
			this.scene.removeChild(textureView);
		}
	}

	public function resizeTextureViewer():Void {
		var width = Director.current.displaySize.width;
		var height = Director.current.displaySize.height;

		this.setDisplaySize(Director.current.displaySize);

		// Update camera ortho matrix
		this._camera.setOrthoProjection(0, width, 0, height, 1.0, 10.0);
	}

	public function renderTextureViewer():Void {
		this.updateView();
		this.clearAndRender();
	}
}
