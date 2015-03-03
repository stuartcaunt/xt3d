package kfsgl.camera;

import flash.geom.Vector3D;
import kfsgl.view.View;
import flash.geom.Matrix3D;

import kfsgl.node.Node3D;

class Camera extends Node3D {

	// properties

	// members
	private var _projectionMatrix:Matrix3D;
	private var _viewMatrix:Matrix3D;
	private var _viewProjectionMatrix:Matrix3D;
	private var _isMatrixDirty:Bool;

	private var _view:View;
	private var _up:Vector3D;
	private var _lookAt:Vector3D;
	private var _initialPosition:Vector3D;
	private var _initialLookAt:Vector3D;

	// Target camera looks at specific world coordinate (lookAt and up ignored).
	// Non-target camera uses transformation matrix of parent node
	private var _isTargetCamera:Bool = true;

	private var _fov:Float;
	private var _aspect:Float;
	private var _near:Float;
	private var _far:Float;
	private var _isPerspective:Bool;
	private var _left:Float;
	private var _right:Float;
	private var _top:Float;
	private var _bottom:Float;

	private var _widthInPixels:Float;
	private var _heightInPixels:Float;
	private var _zoom:Float;
	private var _focus:Float;

	public function new() {
		super();
	}

	/* ----------- Properties ----------- */



	/* --------- Implementation --------- */


	public static function create(view:View, position:Vector3D = null, up:Vector3D = null, lookAt:Vector3D = null):Camera {
		var object = new Camera();

		if (object != null && !(object.initWithView(view, position, up, lookAt))) {
			object = null;
		}

		return object;
	}

	public function initWithView(view:View, position:Vector3D = null, up:Vector3D = null, lookAt:Vector3D = null):Bool {

		var retval;
		if ((retval = super.init())) {

			if (position == null) {
				position = new Vector3D(0.0, 0.0, 10.0);
			}
			if (up == null) {
				up = new Vector3D(0.0, 1.0, 0.0);
			}
			if (lookAt == null) {
				lookAt = new Vector3D(0.0, 0.0, 0.0);
			}

			this._view = view;

			// TODO
			// add event listener to view
			//view.on('viewport_changed', this.onViewportChanged);

			this.setPosition(position);
			this._initialPosition = position.clone();

			this._up = up.clone();
			this._lookAt = lookAt.clone();
			this._initialLookAt = lookAt.clone();

			this._isTargetCamera = true;
			this._zoom = 1.0;
			this._isPerspective = true;
			this._isMatrixDirty = true;

			var viewportSizeInPixels = view.viewportInPixels;
			this._widthInPixels = viewportSizeInPixels.width;
			this._heightInPixels = viewportSizeInPixels.height;

			// Initialise view matrix
			this._localTransformationDirty = true;
			var identityMatrix = new Matrix3D();
			this.updateWorldTransformation(identityMatrix);

		}

		return retval;
	}



}
