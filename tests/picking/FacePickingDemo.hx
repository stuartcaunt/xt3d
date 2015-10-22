package ;

import xt3d.gl.XTGL;
import xt3d.gl.XTGL;
import xt3d.gl.view.Xt3dGLView;
import xt3d.core.Geometry;
import xt3d.core.Geometry;
import xt3d.events.picking.FacePicker;
import xt3d.extras.CameraController;
import xt3d.utils.XT;
import xt3d.events.gestures.TapGestureRecognizer;
import xt3d.core.Director;
import xt3d.node.Light;
import lime.math.Vector4;
import xt3d.node.MeshNode;
import xt3d.core.Material;
import xt3d.textures.Texture2D;
import xt3d.primitives.Sphere;
import xt3d.node.Node3D;
import xt3d.core.View;
import xt3d.utils.color.Color;


class FacePickingDemo extends MainApplication {
	public function new () {
		super();
	}

	override public function createViews():Void {
		var view = FacePickingDemoView.create();
		this._director.addView(view);
	}


}


class FacePickingDemoView extends View implements TapGestureDelegate {

	// properties

	// members
	private var _containerNode:Node3D;
	private var _facePicker:FacePicker;
	private var _containerAngle:Float = 0.0;
	private var _whiteLight:Light;
	private var _meshNode:MeshNode;

	public static function create():FacePickingDemoView {
		var object = new FacePickingDemoView();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var retval;
		if ((retval = super.initBasic3D())) {

			var director:Director = Director.current;
			this.backgroundColor = director.backgroundColor;

			// Create scene
			this.createScene();

			// Create lights
			this.createLights();

			this._facePicker = FacePicker.create(FacePickerGeometryType.FacePickerGeometryTypeQuad);

			// Recognizers
			var tapGestureRecognizer = TapGestureRecognizer.create(this);
			this.scene.addChild(tapGestureRecognizer);

			var cameraController = CameraController.create(this._camera, 20.0);
			cameraController.xOrbitFactor = 1.5;
			this.scene.addChild(cameraController);

			// Schedule update
			this.scheduleUpdate();
		}

		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	override public function update(dt:Float):Void {

	}


	private function createScene():Void {
		var director:Director = Director.current;

		this._containerNode = Node3D.create();
		this.scene.addChild(this._containerNode);

		// Create material
		var texture:Texture2D = director.textureCache.addTextureFromImageAsset("assets/images/marsmap2k.jpg");
		texture.retain();
		var material:Material = Material.create("generic+texture+phong");
		material.uniform("texture").texture = texture;
		material.uniform("uvScaleOffset").floatArrayValue = texture.uvScaleOffset;

		// create geometriy
		var geometry = this.createGeometry(10.0, 0.4);

		this._meshNode = MeshNode.create(geometry, material);
		material.side = XTGL.DoubleSide;
		this._containerNode.addChild(this._meshNode);
	}


	private function createLights():Void {

		this._whiteLight = Light.createPointLight();
		this._whiteLight.position = new Vector4(10.0, 10.0, 20.0);
		this._scene.addChild(this._whiteLight);
		this._whiteLight.renderLight = true;

		// Set the scene ambient color
		this._scene.ambientLight = Color.createWithRGBHex(0x444444);
	}

	public function onTap(tapEvent:TapEvent):Bool {
		if (tapEvent.tapType == TapType.TapTypeDown) {
			var pickingResult = this._facePicker.findPicked(this.scene, this.camera, tapEvent.location);
			if (pickingResult.renderObject != null) {
				XT.Log("Got object " + pickingResult.renderObject.renderId + ", face Id " + pickingResult.faceId);

				// Hide quad
				if (pickingResult.renderObject == this._meshNode) {
					var index = pickingResult.faceId * 6;
					var vertexIndex = pickingResult.faceId * 4;
					if (this._meshNode.geometry.indexCount > index) {
						var vertexData = this._meshNode.geometry.interleavedVertexData;

						var numberOfQuads = (this._meshNode.geometry.indexCount / 6);

						// Iterate over 4 vertices
						for (i in 0 ... 4) {
							var fromVertexPosition = 4 * (numberOfQuads - 1) + i;
							var toVertexPosition = 4 * pickingResult.faceId + i;

							// Copy position data
							for (p in 0 ... 3) {
								var fromDataPosition = Std.int(fromVertexPosition * 8) + p;
								var toDataPosition = Std.int(toVertexPosition * 8) + p;
								vertexData.set(toDataPosition, vertexData.get(fromDataPosition));
							}
						}

						// Reduce number of indices
						this._meshNode.geometry.indexCount -= 6;
					}
				}

			}

		} else if (tapEvent.tapType == TapType.TapTypeUp) {
		}

		return false;
	}

	private function createGeometry(maxDistance:Float, quadSize:Float):Geometry {
		var nQuads = 1024;
		var nVertices = 4 * nQuads * 8;
		var nIndices = 6 * nQuads;

		var geometry = Geometry.create();
		var vertexData = geometry.createInterleavedVertexData(8, null, nVertices);
		vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

		var indices = geometry.createIndexData(nIndices);

		for (i in 0 ... nQuads) {
			var index = i * 4;
			var x = (Math.random() - 0.5) * maxDistance;
			var y = (Math.random() - 0.5) * maxDistance;
			var z = (Math.random() - 0.5) * maxDistance;

			vertexData.push(x - quadSize);
			vertexData.push(y - quadSize);
			vertexData.push(z);
			vertexData.push(0.0);
			vertexData.push(0.0);
			vertexData.push(1.0);
			vertexData.push(0.0);
			vertexData.push(1.0);

			vertexData.push(x + quadSize);
			vertexData.push(y - quadSize);
			vertexData.push(z);
			vertexData.push(0.0);
			vertexData.push(0.0);
			vertexData.push(1.0);
			vertexData.push(1.0);
			vertexData.push(1.0);

			vertexData.push(x - quadSize);
			vertexData.push(y + quadSize);
			vertexData.push(z);
			vertexData.push(0.0);
			vertexData.push(0.0);
			vertexData.push(1.0);
			vertexData.push(0.0);
			vertexData.push(0.0);

			vertexData.push(x + quadSize);
			vertexData.push(y + quadSize);
			vertexData.push(z);
			vertexData.push(0.0);
			vertexData.push(0.0);
			vertexData.push(1.0);
			vertexData.push(1.0);
			vertexData.push(0.0);

			var first = index;
			var second = index + 1;
			var third = index + 2;
			var fourth = index + 3;

			indices.push(first);
			indices.push(second);
			indices.push(third);

			indices.push(third);
			indices.push(second);
			indices.push(fourth);
		}

		return geometry;
	}

}


