package kfsgl.camera;

import kfsgl.errors.KFException;
import kfsgl.utils.KF;
import kfsgl.utils.Types;
import kfsgl.math.MatrixHelper;
import kfsgl.math.VectorHelper;
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
	private var _isViewProjectionMatrixDirty:Bool;

	private var _view:View;
	private var _up:Vector3D = new Vector3D();
	private var _lookAt:Vector3D = new Vector3D();
	private var _initialPosition:Vector3D = new Vector3D();
	private var _initialLookAt:Vector3D = new Vector3D();

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

	// TODO
	//private var _orientation:DeviceOrientation;

	private var _width:Float;
	private var _height:Float;
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


	/**
	 * Initialises the camera with user-defined geometry.
	 * Perspective projection is used as default.
	 * @param view The view used in association with the camera.
	 * @param position The position of the camera. Defaults to (0.0, 0.0, 10.0)
	 * @param up The up vector. Defaults to (0.0, 1.0, 0.0)
	 * @param lookAt The position where the camera will look at. Defaults to (0.0, 0.0, 0.0)
	 */
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


			// TODO
			// add event listener to view
			//view.on('viewport_changed', this.onViewportChanged);
			KF.Log("TODO Camera.initWithView Add listener to view");

			this.setPosition(position);
			this._initialPosition = position.clone();

			this._up.copyFrom(up);
			this._lookAt.copyFrom(lookAt);
			this._initialLookAt.copyFrom(lookAt);

			this._isTargetCamera = true;
			this._zoom = 1.0;
			this._isPerspective = true;
			this._isViewProjectionMatrixDirty = true;

			this._view = view;
			var viewportSize = view.viewport;
			this._width = viewportSize.width;
			this._height = viewportSize.height;

			// Initialise view matrix
			this._localTransformationDirty = true;
			var identityMatrix = new Matrix3D();
			this.updateWorldTransformation(identityMatrix);

		}

		return retval;
	}

	/**
	 * Resets the camera position and look-at to their initial values.
	 */
	public function reset() {
		this._lookAt.copyFrom(this._initialLookAt);
		this.setPosition(this._initialPosition);
	}



	/**
	 * Sets the camera in projective projection mode with the given parameters.
	 * @param fovy The field of view in the y direction.
	 * @param near The near value (closer than this an objects won't be rendered).
	 * @param far The far value (further than this an objects won't be rendered).
	 * @param orientation indicates the rotation (about z) for the projection.
	 */
	public function setPerspectiveProjection(fovy:Float, near:Float, far:Float /*, orientation:DeviceOrientation = DeviceOrientation0 */):Void {
		if (this._view == null) {
			throw new KFException("NoViewForPerspectiveProjection", "Perspective projection requires a view object");
		}

		_aspect = _width / _height;

		_projectionMatrix = MatrixHelper.perspectiveMatrix(fovy, _aspect, near, far, _zoom /*, orientation */);

		_fov = fovy;
		_near = near;
		_far = far;

		// TODO
		//_orientation = orientation;

		_top = Math.tan(_fov * Math.PI / 360.0) * _near;
		_bottom = -_top;
		_left = _aspect * _bottom;
		_right = _aspect * _top;

		// TODO
//		if (_orientation == Isgl3dOrientation90CounterClockwise || _orientation == Isgl3dOrientation90Clockwise) {
//			_focus = 0.5 * _width / (_zoom * tan(_fov * M_PI / 360.0));
//		} else {
			_focus = 0.5 * _height / (_zoom * Math.tan(_fov * Math.PI / 360.0));
//		}

		_isPerspective = true;
		_isViewProjectionMatrixDirty = true;
	}

	/**
	 * Sets the camera in orthographics projection mode.
	 * @param left The left value (Objects to the left of this won't be rendered).
	 * @param right The right value (Objects to the right of this won't be rendered).
	 * @param bottom The bottom value (Objects below this won't be rendered).
	 * @param top The top value (Objects above this won't be rendered).
	 * @param near The near value (closer than this an objects won't be rendered).
	 * @param far The far value (further than this an objects won't be rendered).
	 * @param orientation indicates the rotation (about z) for the projection.
	 */
	public function setOrthoProjection(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float /*, orientation:DeviceOrientation = DeviceOrientation0 */):Void {

		_projectionMatrix = MatrixHelper.orthoMatrix(left, right, bottom, top, near, far, _zoom /*, orientation */);

		_left = left;
		_right = right;
		_bottom = bottom;
		_top = top;
		_near = near;
		_far = far;

		// TODO
		//_orientation = orientation;

		_isPerspective = false;

		_isViewProjectionMatrixDirty = true;

	}

	/**
	 * Sets the width and height of the viewport.
	 * If the camera is in perspective mode then the projection matrix is recalculated.
	 * @param width The width of the view.
	 * @param height The height of the view.
	 */
	public function setView(view:View):Void {
		this._view = view;
		var viewportSize = view.viewport;
		this._width = viewportSize.width;
		this._height = viewportSize.height;
	}

	/**
	 * Sets the orientation (rotation about z) for the projection.
	 * @param orientation indicates the rotation (about z) for the projection.
	 */
	public function setOrientation(orientation:DeviceOrientation):Void {
//		_orientation = orientation;
//		if (_isPerspective) {
//			[self setPerspectiveProjection:_fov near:_near far:_far orientation:_orientation];
//
//		} else {
//			[self setOrthoProjection:_left right:_right bottom:_bottom top:_top near:_near far:_far orientation:_orientation];
//		}
	}


	public function setFov(fov:Float):Void {
		_fov = fov;
		if (_isPerspective) {
			this.setPerspectiveProjection(_fov, _near, _far /*, _orientation*/);
		}
	}

	public function getFov():Float {
		return _fov;
	}

	public function setFocus(focus:Float):Void {
		if (focus > 0) {
			_focus = focus;

			if (_isPerspective) {
				var fov:Float;

//				if (_orientation == Isgl3dOrientation90CounterClockwise) {
//					fov = (360.0 / Math.PI) * Math.atan2(_width, 2.0 * _zoom * _focus);
//				} else {
					fov = (360.0 / Math.PI) * Math.atan2(_height, 2.0 * _zoom * _focus);
//				}
				this.setPerspectiveProjection(_fov, _near, _far /*, _orientation*/);
			}
		}
	}

	public function getFocus():Float {
		return _focus;
	}

	public function setZoom(zoom:Float) {
		if (zoom > 0) {
			_zoom = zoom;

			if (_isPerspective) {
				var fov:Float;

//				if (_orientation == Isgl3dOrientation90CounterClockwise) {
//				fov = (360.0 / Math.PI) * Math.atan2(_width, 2.0 * _zoom * _focus);
//				} else {
					fov = (360.0 / Math.PI) * Math.atan2(_height, 2.0 * _zoom * _focus);
//				}
				this.setPerspectiveProjection(_fov, _near, _far /*, _orientation*/);
			}
		}
	}

	public function getZoom():Float {
		return _zoom;
	}

	/**
	 * Specifies the postion in space as a vector where the camera should look at.
	 * @param lookAt The vector containing the look-at position.
	 */
	public function setLookAt(lookAt:Vector3D):Void {
		_lookAt.copyFrom(lookAt);
		_localTransformationDirty = true;

		if (!_isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting lookAt has no effect");
		}
	}

	/**
	 * Specifies the postion in space as separated components where the camera should look at.
	 * param x The x position of the look-at position.
	 * param y The y position of the look-at position.
	 * param z The z position of the look-at position.
	 */
	public function setLookAtPosition(x:Float, y:Float, z:Float) {
		_lookAt.setTo(x, y, z);
		_localTransformationDirty = true;

		if (!_isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting lookAt has no effect");
		}
	}

	/**
	 * Used to obtain the look-at position as a vector.
	 * @return The look-at position as a vector
	 */
	public function getLookAt():Vector3D {
		return this._lookAt;
	}

	/**
	 * Used to obtain the vector along the direction of view from the observer's position (in essence the
	 * current look-at position minus the camera position).
	 * @return the vector along the direction of view from the observer's position.
	 */
	public function getEyeNormal():Vector3D {
		var eyeNormal:Vector3D = _lookAt.clone();
		var position:Vector3D = this.getWorldPosition();
		eyeNormal.decrementBy(position);

		return eyeNormal;
	}

	/**
	 * Returns the x component of the look-at position.
	 * @return the x component of the look-at position.
	 */
	public function getLookAtX():Float {
		return this._lookAt.x;
	}

	/**
	 * Returns the y component of the look-at position.
	 * @return the y component of the look-at position.
	 */
	public function getLookAtY():Float {
		return this._lookAt.y;
	}

	/**
	 * Returns the z component of the look-at position.
	 * @return the z component of the look-at position.
	 */
	public function getLookAtZ():Float {
		return this._lookAt.z;
	}

	/**
	 * Translates the current look at.
	 * @param x The distance along the x-axis to move the look-at
	 * @param y The distance along the y-axis to move the look-at
	 * @param z The distance along the z-axis to move the look-at
	 */
	public function translateLookAt(x:Float, y:Float, z:Float) {
		VectorHelper.translate(this._lookAt, x, y, z);

		this._localTransformationDirty = true;
		if (!this._isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting lookAt has no effect");
		}
	}

	/**
	 * Performs a rotation of the look-at position about the x-axis centered on a specific point on the y-z plane.
	 * @param angle The angle of rotation in degrees.
	 * @param centerY The position y on the y-z plane.
	 * @param centerZ The position z on the y-z plane.
	 */
	public function rotateLookAtOnX(angle:Float, centerY:Float, centerZ:Float) {
		VectorHelper.rotateX(this._lookAt, angle, centerY, centerZ);

		this._localTransformationDirty = true;
		if (!this._isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting lookAt has no effect");
		}

	}

	/**
	 * Performs a rotation of the look-at position about the y-axis centered on a specific point on the x-z plane.
	 * @param angle The angle of rotation in degrees.
	 * @param centerX The position x on the x-z plane.
	 * @param centerZ The position z on the x-z plane.
	 */
	public function rotateLookAtOnY(angle:Float, centerX:Float, centerZ:Float) {
		VectorHelper.rotateY(_lookAt, angle, centerX, centerZ);

		this._localTransformationDirty = true;
		if (!this._isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting lookAt has no effect");
		}

	}

	/**
	 * Performs a rotation of the look-at position about the z-axis centered on a specific point on the x-y plane.
	 * @param angle The angle of rotation in degrees.
	 * @param centerX The position x on the x-z plane.
	 * @param centerY The position y on the y-z plane.
	 */
	public function rotateLookAtOnZ(angle:Float, centerX:Float, centerY:Float) {
		VectorHelper.rotateZ(_lookAt, angle, centerX, centerY);

		this._localTransformationDirty = true;
		if (!this._isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting lookAt has no effect");
		}

	}

	/**
	 * Returns the distance from the camera's location to the look-at position.
	 * @return The distance from the camera's location to the look-at position.
	 */
	public function getDistanceToLookAt():Float {
		return Vector3D.distance(this.getWorldPosition(), this._lookAt);
	}

	/**
	 * Sets the distance between the look-at position and the camera's location.
	 * The look-at position remains fixed and the camera's position changes accordingly. This
	 * can be useful for example if the look-at is set to the position of another object on the
	 * scene and you wish to move the camera further away or closer to the object.
	 * @param distance The desired distance between the look at and the camera.
	 */
	public function setDistanceToLookAt(distance:Float):Void {
		var position:Vector3D = this.getWorldPosition();

		position.decrementBy(this._lookAt);
		position.normalize();
		position.scaleBy(distance);
		position.incrementBy(this._lookAt);

		this.setPosition(position);

		if (!this._isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting position has no effect");
		}

	}

	/**
	 * Sets the components of the up vector.
	 * @param x The x component of the up vector.
	 * @param y The y component of the up vector.
	 * @param z The z component of the up vector.
	 */
	public function setUpX(x:Float, y:Float, z:Float) {
		this._up.setTo(x, y, z);
		this._localTransformationDirty = true;

		if (!this._isTargetCamera) {
			KF.Warn("Camera : not a target camera, setting \"up\" has no effect");
		}

	}

	override public function updateWorldTransformation(parentTransformation:Matrix3D):Void {

		var calculateViewMatrix:Bool = (this._localTransformationDirty || this._transformationDirty);
		super.updateWorldTransformation(parentTransformation);

		if (calculateViewMatrix) {
			this.calculateViewMatrix();
		}
	}


	private function calculateViewMatrix():Void {

		var cameraPosition:Vector3D = this.worldPosition;

		if (this._isTargetCamera) {
			// Calculate view matrix from lookat position
			this._viewMatrix = MatrixHelper.lookAt(cameraPosition, this._lookAt, this._up);

		} else {
			// Calculate view matrix as the inverse of the current world transformation
			this._viewMatrix.copyFrom(this._worldTransformation);
			this._viewMatrix.invert();
		}

		this._isViewProjectionMatrixDirty = true;
	}

	public function getViewProjectionMatrix():Matrix3D {
		if (this._isViewProjectionMatrixDirty) {
			this._viewProjectionMatrix.copyFrom(this._projectionMatrix);
			this._viewProjectionMatrix.prepend(this._viewMatrix);

			this._isViewProjectionMatrixDirty = false;
		}
		return _viewProjectionMatrix;
	}


}
