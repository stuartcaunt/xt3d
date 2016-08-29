package xt3d.lights;

import lime.math.Rectangle;
import xt3d.utils.textures.TextureViewer;
import xt3d.material.Material;
import xt3d.node.RenderObject;
import xt3d.math.VectorHelper;
import xt3d.math.MatrixHelper;
import xt3d.math.Vector4;
import xt3d.core.Director;
import lime.utils.Float32Array;
import xt3d.math.Matrix4;
import xt3d.utils.color.Color;
import xt3d.gl.XTGL;
import xt3d.textures.TextureOptions;
import xt3d.utils.geometry.Size;
import xt3d.textures.RenderTexture;
import xt3d.material.DepthMaterial;
import xt3d.view.View;
import xt3d.node.Scene;
import xt3d.node.Camera;
import xt3d.core.RendererOverrider;

class BasicShadowEngine extends ShadowEngine implements RendererOverriderMaterialDelegate {

	// properties

	// members
	private static var BIAS_MATRIX = new Matrix4(new Float32Array([0.5, 0.0, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0, 1.0]));
	private static var NDC_POINTS = [
		new Vector4(-1, -1, -1),
		new Vector4(-1,  1, -1),
		new Vector4( 1,  1, -1),
		new Vector4( 1, -1, -1),
		new Vector4(-1, -1,  1),
		new Vector4(-1,  1,  1),
		new Vector4( 1,  1,  1),
		new Vector4( 1, -1,  1),
	];

	private var _shadowMapSize:Int;
	private var _rendererOverrider:RendererOverrider;
	private var _shadowView:View;
	private var _depthMaterial:DepthMaterial;
	private var _shadowCamera:Camera;
	private var _renderTexture:RenderTexture;

	private var _shadowMatrix:Matrix4 = new Matrix4();
	private var _inverseViewProjectionMatrix:Matrix4 = new Matrix4();
	private var _frustumPoints:Array<Vector4> = new Array<Vector4>();
	private var _shadowBias:Float = 0.0005;
	private var _shadowColor:Color = Color.createWithComponents(0.6, 0.6, 0.6);
	private var _frustumCenter:Vector4 = new Vector4();
	private var _nearExtend:Float = 100.0;

	private var _debug:Bool = false;
	private var _textureViewer:TextureViewer = null;

	public static function createBasicShadowEngine(shadowMapSize:Int = 2048, debug:Bool = false):BasicShadowEngine {
		var object = new BasicShadowEngine();

		if (object != null && !(object.initBasicShadowEngine(shadowMapSize, debug))) {
			object = null;
		}

		return object;
	}

	public function initBasicShadowEngine(shadowMapSize:Int = 2048, debug:Bool = false):Bool {
		var retval;
		if ((retval = super.init())) {
			this._shadowMapSize = shadowMapSize;
			this._debug = debug;

			// Create render texture
			this.createRenderTarget();

			// Create depth render material
			this._depthMaterial = DepthMaterial.create();

			// Create renderer overrider with depth material
			this._rendererOverrider = RendererOverrider.create(this);

			// Create a view object that we'll use to render the scene from a camera reprensenting the light
			this._shadowView = View.createBasic2D();

			// Get the camera from the view
			this._shadowCamera = this._shadowView.camera;

			// Create frustum points
			for (i in 0 ... 8) {
				this._frustumPoints.push(new Vector4());
			}
		}

		return retval;
	}

	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public override function getDebug():Bool {
		return this._debug;
	}

	public override function setDebug(value:Bool) {
		if (value && !this._debug) {
			// Create texture viewer
			this._textureViewer = TextureViewer.createTextureViewer();

			var rect:Rectangle = new Rectangle(32, 32, 256, 256);
			var materialConfig:MaterialConfig = {
				materialName: "depthDebug",
				textureUniformName: "texture"
			};
			this._textureViewer.addTexture("shadowMap", this._renderTexture, rect, materialConfig);

		} else if (!value && this._debug) {
			this._textureViewer.dispose();
			this._textureViewer = null;
		}

		return this._debug = value;
	}

	public override function dispose():Void {
		// Dispose of render texture
		this._renderTexture.dispose();

		// Dispose of depth material
		this._depthMaterial.dispose();

	}

	public override function updateShadows(view:View, light:Light):Void {
		// Verify light is directional
		if (light.lightType != XTGL.DirectionalLight) {
			return;
		}

		var scene = view.scene;
		var camera = view.camera;

		// calculate the frustum points of the scene camera
		this.calculateFrustumPoints(camera);

		// Update shadow camera
		this.updateShadowCamera(camera, light);

		// Update shadow matrix
		this.updateShadowMatrix(camera);

		// Update all uniforms
		this.updateUniforms();

		// Set the scene in the view
		this._shadowView.scene = scene;

		// Update view of render texture
		this._renderTexture.updateView(this._shadowView, this._rendererOverrider);

		// Render scene to render texture
		this._renderTexture.renderWithClear(this._shadowView, this._rendererOverrider);

	}

	public function createRenderTarget():Void {
		this._renderTexture = RenderTexture.create(Size.createIntSize(this._shadowMapSize, this._shadowMapSize), TextureOptions.LINEAR_CLAMP , XTGL.DepthStencilFormatNone);
		this._renderTexture.clearColor = Color.white;
	}

	private function calculateFrustumPoints(camera:Camera):Void {

		// Calculate inverse view projection matrix
		this._inverseViewProjectionMatrix.copyFrom(camera.projectionMatrix);
		this._inverseViewProjectionMatrix.prepend(camera.viewMatrix);
		this._inverseViewProjectionMatrix.invert();

		var minX:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;
		var minZ:Float = Math.POSITIVE_INFINITY;
		var maxZ:Float = Math.NEGATIVE_INFINITY;

		// Transform ndc points into world positions using inverse view-projection matrix of the camera
		for (i in 0 ... 8) {
			var frustumPoint = this._frustumPoints[i];
			MatrixHelper.transformVector3Inline(this._inverseViewProjectionMatrix, NDC_POINTS[i], frustumPoint);

			minX = Math.min(minX, frustumPoint.x);
			maxX = Math.max(maxX, frustumPoint.x);
			minY = Math.min(minY, frustumPoint.y);
			maxY = Math.max(maxY, frustumPoint.y);
			minZ = Math.min(minZ, frustumPoint.z);
			maxZ = Math.max(maxZ, frustumPoint.z);
		}

		// Calculate the frustum center
		this._frustumCenter.setTo(0.5 * (minX + maxX), 0.5 * (minY + maxY), 0.5 * (minZ + maxZ));
	}

	private function updateShadowCamera(camera:Camera, light:Light):Void {

		// Update shadow camera to view full frustum

		// Get the light direction
		var lightDirection = light.direction;

		// Set frustum camera position to center of frustum bounding box and calculate the look at with the light direction
		this._shadowCamera.position.copyFrom(this._frustumCenter);

		// Set view matrix to look in direction of the light
		this._shadowCamera.setUpValues(-lightDirection.x, -lightDirection.y, 0.0);
		this._shadowCamera.up.normalize();
		VectorHelper.add(this._frustumCenter, lightDirection);
		this._shadowCamera.setLookAt(this._frustumCenter);

		// Calculate the orthographic projection by projecting the frustum points with a dummy ortho projection
		this._shadowCamera.setOrthoProjection(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);

		this._shadowCamera.updateWorldMatrix();

		// Get transformed extents
		var minX:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;
		var minZ:Float = Math.POSITIVE_INFINITY;
		var maxZ:Float = Math.NEGATIVE_INFINITY;

		// Project all frustum points to get projected bounding box.
		var cameraViewProjectionMatrix = this._shadowCamera.viewProjectionMatrix;
		for (i in 0 ... 8) {
			var frustumPoint = this._frustumPoints[i];
			MatrixHelper.transformVector3Inline(cameraViewProjectionMatrix, frustumPoint, frustumPoint);
			minX = Math.min(minX, frustumPoint.x);
			maxX = Math.max(maxX, frustumPoint.x);
			minY = Math.min(minY, frustumPoint.y);
			maxY = Math.max(maxY, frustumPoint.y);
			minZ = Math.min(minZ, frustumPoint.z);
			maxZ = Math.max(maxZ, frustumPoint.z);
		}

		// Set the ortho matrix to fit correctly the bounding box of the frustum split
		this._shadowCamera.setOrthoProjection(minX, maxX, minY, maxY, minZ - this._nearExtend, maxZ);
	}


	private function updateShadowMatrix(camera:Camera):Void {
		// Initialise with the bias matrix
		this._shadowMatrix.copyFrom(BIAS_MATRIX);

		// prepend with view camera view projection matrix
		this._shadowMatrix.prepend(this._shadowCamera.viewProjectionMatrix);

		// prepend with camera world matrix
		this._shadowMatrix.prepend(camera.worldMatrix);
	}

	private function updateUniforms():Void {
		var renderer = Director.current.renderer;
		var uniformLib = renderer.uniformLib;

		uniformLib.uniform("shadowTexture").texture = this._renderTexture;
		uniformLib.uniform("shadowMatrix").matrixValue = this._shadowMatrix;
		uniformLib.uniform("shadowColor").floatArrayValue = this._shadowColor.rgbArray;
		uniformLib.uniform("shadowBias").floatValue = this._shadowBias;
	}


	/* --------- Delegate functions --------- */

	public function getMaterialOverride(renderObject:RenderObject, originalMaterial:Material):Material {
		// TODO : depth material should change according to original material/object (eg skinning)

		return this._depthMaterial;
	}

}
