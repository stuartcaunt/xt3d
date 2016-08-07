package xt3d.node;

import xt3d.math.Vector2;
import xt3d.utils.Types;
import xt3d.gl.shaders.UniformLib;
import xt3d.utils.errors.XTException;
import xt3d.utils.XT;
import xt3d.math.MatrixHelper;
import xt3d.math.VectorHelper;
import xt3d.math.Vector4;
import xt3d.view.View;
import xt3d.math.Matrix4;

import xt3d.node.Node3D;

class Camera extends Node3D {

	// properties

	/**
	 * The initial position of the camera as defined during its initialisation or set afterwards.
	 * A call to reset on the camera will place the camera at this position.
	 */
	public var initialPosition(get_initialPosition, set_initialPosition):Vector4;

	/**
	 * The initial look-at position of the camera as defined during its initialistion or set afterwards.
	 * A call to reset on the camera will make the camera look-at this position.
	 */
	public var initialLookAt(get_initialLookAt, set_initialLookAt):Vector4;

	/**
	 * The up vector of the camera.
	 * A call to reset on the camera will make the camera have this up vector.
	 */
	public var up(get_up, set_up):Vector4;

	/**
	 * The current view matrix.
	 */
	public var viewMatrix(get_viewMatrix, null):Matrix4;

	/**
	 * The current inverse view matrix.
	 */
	public var inverseViewMatrix(get_inverseViewMatrix, null):Matrix4;

	/**
	 * The current projection matrix.
	 */
	public var projectionMatrix(get_projectionMatrix, set_projectionMatrix):Matrix4;

	/**
	 * The combined view and projection matrices.
	 */
	public var viewProjectionMatrix(get_viewProjectionMatrix, null):Matrix4;

	/**
	 * Indicates whether the camera is in perspective mode.
	 */
	public var isPerspective(get_isPerspective, set_isPerspective):Bool;

	/**
	 * The field of view of the camera in degrees (in perspective mode).
	 * This is the angle between the z-axis of the camera and the maximum vertical angle visible.
	 */
	public var fov(get_fov, set_fov):Float;

	/**
	 * The width of the viewport.
	 * Used in conjunction with height to obtain the aspect ratio of the camera (in perspective mode).
	 */
	public var width(get_width, set_width):Float;

		/**
	 * The height of the viewport.
	 * Used in conjunction with width to obtain the aspect ratio of the camera (in perspective mode).
	 */
	public var height(get_height, set_height):Float;

	/**
	 * The aspect ratio of the camera (in perspective mode).
	 * This defines the ratio between the maximum horizontal angle and the maximum vertical angle.
	 */
	public var aspect(get_aspect, set_aspect):Float;

	/**
	 * The near value of the camera.
	 * Objects closer than this value will not be rendered.
	 */
	public var near(get_near, set_near):Float;

	/**
 	* The far value of the camera.
	 * Objects further than this value will not be rendered.
	 */
	public var far(get_far, set_far):Float;

	/**
	 * The left value of the camera (in orthographic mode).
	 * Objects further to the left (along the x-axis) than this value will not be rendered.
	 */
	public var left(get_left, set_left):Float;

	/**
	 * The right value of the camera (in orthographic mode).
	 * Objects further to the right (along the x-axis) than this value will not be rendered.
	 */
	public var right(get_right, set_right):Float;

	/**
	 * The bottom value of the camera (in orthographic mode).
	 * Objects below this (along the y-axis) than this value will not be rendered.
	 */
	public var bottom(get_bottom, set_bottom):Float;

	/**
	 * The top value of the camera (in orthographic mode).
	 * Objects above this (along the y-axis) than this value will not be rendered.
	 */
	public var top(get_top, set_top):Float;

	/**
	 * The focus of the camera (in perspective mode).
	 * This represents the distance to an object with the same dimensions as the view (in terms of pixel width and height) would
	 * be if it fully occupied the display.
	 */
	public var focus(get_focus, set_focus):Float;

	/**
	 * The zoom of the camera (in perspective mode).
	 * This represents the amount of zooming of the camera so that objects appear closer or further away.
	 */
	public var zoom(get_zoom, set_zoom):Float;

	/**
	 * Specified whether the camera is targetted on a specific world position or not.
	 * A target camera will always point towards a specific world position. A non-target camera always looks along the z-axis
	 * as defined by its local frame of reference. In this case the rotation and translation (as for any Isgl3dNode) of the camera
	 * are taken into account when calculating the view matrix.
	 */
	public var isTargetCamera:Bool;



	// members
	private var _projectionMatrix:Matrix4;
	private var _viewMatrix:Matrix4 = new Matrix4();
	private var _inverseViewMatrix:Matrix4 = new Matrix4();
	private var _viewProjectionMatrix:Matrix4 = new Matrix4();
	private var _isViewProjectionMatrixDirty:Bool;

	private var _view:View;
	private var _up:Vector4 = new Vector4();
	private var _lookAt:Vector4 = new Vector4();
	private var _initialPosition:Vector4 = new Vector4();
	private var _initialLookAt:Vector4 = new Vector4();

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

	private var _orientation:XTOrientation = XTOrientation.Orientation0;

	private var _width:Float;
	private var _height:Float;
	private var _zoom:Float;
	private var _focus:Float;


	public static function create(view:View, position:Vector4 = null, up:Vector4 = null, lookAt:Vector4 = null):Camera {
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
	public function initWithView(view:View, position:Vector4 = null, up:Vector4 = null, lookAt:Vector4 = null):Bool {

		var retval;
		if ((retval = super.init())) {

			if (position == null) {
				position = new Vector4(0.0, 0.0, 10.0);
			}
			if (up == null) {
				up = new Vector4(0.0, 1.0, 0.0);
			}
			if (lookAt == null) {
				lookAt = new Vector4(0.0, 0.0, 0.0);
			}

			// add event listener to view
			view.on('viewport_changed', this.onViewportChanged);
			view.on('orientation_changed', this.onOrientationChanged);

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

			this._orientation = view.orientation;

			// Set perspective projection with default values
			setPerspectiveProjection(45.0, 1.0, 10000, this._orientation);

			// Initialise view matrix
			this._matrixDirty = true;
			var identityMatrix = new Matrix4();
			this.updateWorldMatrix();

		}

		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public inline function get_initialPosition():Vector4 {
		return this._initialPosition;
	}

	public inline function set_initialPosition(value:Vector4) {
		this._initialPosition.copyFrom(value);
		return this._initialPosition;
	}

	public inline function get_initialLookAt():Vector4 {
		return this._initialLookAt;
	}

	public inline function set_initialLookAt(value:Vector4) {
		this._initialLookAt.copyFrom(value);
		return this._initialLookAt;
	}

	public inline function get_up():Vector4 {
		return this._up;
	}

	public inline function set_up(value:Vector4) {
		setUp(value);
		return this._up;
	}

	public inline function get_viewMatrix():Matrix4 {
		return this._viewMatrix;
	}

	public inline function get_inverseViewMatrix():Matrix4 {
		return this._inverseViewMatrix;
	}

	public inline function get_projectionMatrix():Matrix4 {
		return this._projectionMatrix;
	}

	public inline function set_projectionMatrix(value:Matrix4) {
		this._projectionMatrix.copyFrom(value);
		return this._projectionMatrix;
	}

	public inline function get_viewProjectionMatrix():Matrix4 {
		return this.getViewProjectionMatrix();
	}

	public inline function get_isPerspective():Bool {
		return this._isPerspective;
	}

	public inline function set_isPerspective(value):Bool {
		return this._isPerspective = value;
	}

	public inline function get_fov():Float {
		return getFov();
	}

	public inline function set_fov(value:Float) {
		setFov(value);
		return this._fov;
	}

	public inline function get_zoom():Float {
		return this._zoom;
	}

	public inline function set_zoom(value:Float) {
		setZoom(value);
		return this._zoom;
	}

	public inline function get_focus():Float {
		return this._focus;
	}

	public inline function set_focus(value:Float) {
		setFocus(value);
		return this._focus;
	}

	public inline function get_aspect():Float {
		return this._aspect;
	}

	public inline function set_aspect(value:Float) {
		return this._aspect = value;
	}

	public inline function get_near():Float {
		return this._near;
	}

	public inline function set_near(value:Float) {
		this.setNear(value);
		return this._near;
	}

	public inline function get_far():Float {
		return this._far;
	}

	public inline function set_far(value:Float) {
		this.setFar(value);
		return this._far;
	}

	public inline function get_left():Float {
		return this._left;
	}

	public inline function set_left(value:Float) {
		return this._left = value;
	}

	public inline function get_right():Float {
		return this._right;
	}

	public inline function set_right(value:Float) {
		return this._right = value;
	}

	public inline function get_top():Float {
		return this._top;
	}

	public inline function set_top(value:Float) {
		return this._top = value;
	}

	public inline function get_bottom():Float {
		return this._bottom;
	}

	public inline function set_bottom(value:Float) {
		return this._bottom = value;
	}

	public inline function get_width():Float {
		return _width;
	}

	public inline function set_width(value:Float) {
		return this._width = value;
	}

	public inline function get_height():Float {
		return _height;
	}

	public inline function set_height(value:Float) {
		return this._height = value;
	}


	/* --------- Implementation --------- */

	/**
	 * Callback when viewport changes
	 */
	private function onViewportChanged():Void {
		var viewportSize = this._view.viewport;
		//XT.Log("changing viewport from " + this._width + " x " + this._height + " to " + viewportSize.width + " x " + viewportSize.height);
		this._width = viewportSize.width;
		this._height = viewportSize.height;

		// Reset the perspective projection if we're using one
		if (this._isPerspective) {
			this.setPerspectiveProjection(_fov, _near, _far, _orientation);
		}
	}

	/**
	 * Callback when orientation changes
	 */
	private function onOrientationChanged():Void {
		this.setOrientation(this._view.orientation);
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
	public function setPerspectiveProjection(fovy:Float, near:Float, far:Float, orientation:XTOrientation):Void {
		if (this._view == null) {
			throw new XTException("NoViewForPerspectiveProjection", "Perspective projection requires a view object");
		}

		_aspect = _width / _height;

		_projectionMatrix = MatrixHelper.perspectiveMatrix(fovy, _aspect, near, far, _zoom, orientation);

		_fov = fovy;
		_near = near;
		_far = far;

		_orientation = orientation;

		_top = Math.tan(_fov * Math.PI / 360.0) * _near;
		_bottom = -_top;
		_left = _aspect * _bottom;
		_right = _aspect * _top;

		if (_orientation == XTOrientation.Orientation90CounterClockwise || _orientation == XTOrientation.Orientation90Clockwise) {
			_focus = 0.5 * _width / (_zoom * Math.tan(_fov * Math.PI / 360.0));
		} else {
			_focus = 0.5 * _height / (_zoom * Math.tan(_fov * Math.PI / 360.0));
		}

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
	public function setOrthoProjection(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float, orientation:XTOrientation = null):Void {

		orientation = (orientation == null) ? XTOrientation.Orientation0 : orientation;

		_projectionMatrix = MatrixHelper.orthoMatrix(left, right, bottom, top, near, far, _zoom, orientation);

		_left = left;
		_right = right;
		_bottom = bottom;
		_top = top;
		_near = near;
		_far = far;

		_orientation = orientation;

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
	public function setOrientation(orientation:XTOrientation):Void {
		_orientation = orientation;
		if (_isPerspective) {
			this.setPerspectiveProjection(_fov, _near, _far, _orientation);

		} else {
			this.setOrthoProjection(_left, _right, _bottom, _top, _near, _far, _orientation);
		}
	}


	public function setFov(fov:Float):Void {
		_fov = fov;
		if (_isPerspective) {
			this.setPerspectiveProjection(_fov, _near, _far, _orientation);
		}
	}

	public inline function getFov():Float {
		return _fov;
	}

	public function setFocus(focus:Float):Void {
		if (focus > 0) {
			_focus = focus;

			if (_isPerspective) {
				var fov:Float;

				if (_orientation == XTOrientation.Orientation90CounterClockwise || _orientation == XTOrientation.Orientation90Clockwise) {
					fov = (360.0 / Math.PI) * Math.atan2(_width, 2.0 * _zoom * _focus);
				} else {
					fov = (360.0 / Math.PI) * Math.atan2(_height, 2.0 * _zoom * _focus);
				}
				this.setPerspectiveProjection(_fov, _near, _far, _orientation);
			}
		}
	}

	public inline function getFocus():Float {
		return _focus;
	}

	public function setZoom(zoom:Float) {
		if (zoom > 0) {
			_zoom = zoom;

			if (_isPerspective) {
				var fov:Float;

				if (_orientation == XTOrientation.Orientation90CounterClockwise || _orientation == XTOrientation.Orientation90Clockwise) {
					fov = (360.0 / Math.PI) * Math.atan2(_width, 2.0 * _zoom * _focus);
				} else {
					fov = (360.0 / Math.PI) * Math.atan2(_height, 2.0 * _zoom * _focus);
				}
				this.setPerspectiveProjection(_fov, _near, _far, _orientation);
			}
		}
	}

	public inline function getZoom():Float {
		return _zoom;
	}

	public function setNear(near:Float):Void {
		this._near = near;
		if (_isPerspective) {
			this.setPerspectiveProjection(_fov, _near, _far, _orientation);
		}
	}

	public function setFar(far:Float):Void {
		this._far = far;
		if (_isPerspective) {
			this.setPerspectiveProjection(_fov, _near, _far, _orientation);
		}
	}

	/**
	 * Specifies the postion in space as a vector where the camera should look at.
	 * @param lookAt The vector containing the look-at position.
	 */
	public function setLookAt(lookAt:Vector4):Void {
		_lookAt.copyFrom(lookAt);
		_matrixDirty = true;

		if (!_isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting lookAt has no effect");
		}
	}

	/**
	 * Specifies the postion in space as separated components where the camera should look at.
	 * param x The x position of the look-at position.
	 * param y The y position of the look-at position.
	 * param z The z position of the look-at position.
	 */
	public function setLookAtValues(x:Float, y:Float, z:Float) {
		_lookAt.setTo(x, y, z);
		_matrixDirty = true;

		if (!_isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting lookAt has no effect");
		}
	}

	/**
	 * Used to obtain the look-at position as a vector.
	 * @return The look-at position as a vector
	 */
	public inline function getLookAt():Vector4 {
		return this._lookAt;
	}

	/**
	 * Used to obtain the vector along the direction of view from the observer's position (in essence the
	 * current look-at position minus the camera position).
	 * @return the vector along the direction of view from the observer's position.
	 */
	public function getEyeNormal():Vector4 {
		var eyeNormal:Vector4 = _lookAt.clone();
		var position:Vector4 = this.getWorldPosition();
		eyeNormal.decrementBy(position);

		return eyeNormal;
	}

	/**
	 * Returns the x component of the look-at position.
	 * @return the x component of the look-at position.
	 */
	public inline function getLookAtX():Float {
		return this._lookAt.x;
	}

	/**
	 * Returns the y component of the look-at position.
	 * @return the y component of the look-at position.
	 */
	public inline function getLookAtY():Float {
		return this._lookAt.y;
	}

	/**
	 * Returns the z component of the look-at position.
	 * @return the z component of the look-at position.
	 */
	public inline function getLookAtZ():Float {
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

		this._matrixDirty = true;
		if (!this._isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting lookAt has no effect");
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

		this._matrixDirty = true;
		if (!this._isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting lookAt has no effect");
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

		this._matrixDirty = true;
		if (!this._isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting lookAt has no effect");
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

		this._matrixDirty = true;
		if (!this._isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting lookAt has no effect");
		}

	}

	/**
	 * Returns the distance from the camera's location to the look-at position.
	 * @return The distance from the camera's location to the look-at position.
	 */
	public inline function getDistanceToLookAt():Float {
		return Vector4.distance(this.getWorldPosition(), this._lookAt);
	}

	/**
	 * Sets the distance between the look-at position and the camera's location.
	 * The look-at position remains fixed and the camera's position changes accordingly. This
	 * can be useful for example if the look-at is set to the position of another object on the
	 * scene and you wish to move the camera further away or closer to the object.
	 * @param distance The desired distance between the look at and the camera.
	 */
	public function setDistanceToLookAt(distance:Float):Void {
		var position:Vector4 = this.getWorldPosition();

		position.decrementBy(this._lookAt);
		position.normalize();
		position.scaleBy(distance);
		position.incrementBy(this._lookAt);

		this.setPosition(position);

		if (!this._isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting position has no effect");
		}

	}

	/**
	 * Sets he up vector.
	 * @param x The x component of the up vector.
	 * @param y The y component of the up vector.
	 * @param z The z component of the up vector.
	 */
	public function setUp(up:Vector4) {
		this._up.copyFrom(up);
		this._matrixDirty = true;

		if (!this._isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting \"up\" has no effect");
		}

	}

	/**
	 * Sets the components of the up vector.
	 * @param x The x component of the up vector.
	 * @param y The y component of the up vector.
	 * @param z The z component of the up vector.
	 */
	public function setUpValues(x:Float, y:Float, z:Float) {
		this._up.setTo(x, y, z);
		this._matrixDirty = true;

		if (!this._isTargetCamera) {
			XT.Warn("Camera : not a target camera, setting \"up\" has no effect");
		}

	}

	override public function updateWorldMatrix():Bool {

		var calculateViewMatrix:Bool = (this._matrixDirty || this._worldMatrixDirty);
		var isNodeUpdated = super.updateWorldMatrix();

		if (calculateViewMatrix) {
			this.calculateViewMatrix();
		}

		return isNodeUpdated;
	}


	private function calculateViewMatrix():Void {

		var cameraPosition:Vector4 = this.worldPosition;

		if (this._isTargetCamera) {
			// Calculate view matrix from lookat position
			this._viewMatrix = MatrixHelper.lookAt(cameraPosition, this._lookAt, this._up);

			this._inverseViewMatrix.copyFrom(this._viewMatrix);
			this._inverseViewMatrix.invert();

		} else {
			// Calculate view matrix as the inverse of the current world transformation
			this._viewMatrix.copyFrom(this._worldMatrix);
			this._viewMatrix.invert();

			this._inverseViewMatrix.copyFrom(this._worldMatrix);
		}

		this._isViewProjectionMatrixDirty = true;
	}

	public function getViewProjectionMatrix():Matrix4 {
		if (this._isViewProjectionMatrixDirty) {
			this._viewProjectionMatrix.copyFrom(this._projectionMatrix);
			this._viewProjectionMatrix.prepend(this._viewMatrix);

			this._isViewProjectionMatrixDirty = false;
		}
		return this._viewProjectionMatrix;
	}

	public function prepareCommonRenderUniforms(uniformLib:UniformLib):Void {
		uniformLib.uniform("viewMatrix").matrixValue = this._viewMatrix;
		uniformLib.uniform("viewProjectionMatrix").matrixValue = this._viewProjectionMatrix;
		uniformLib.uniform("projectionMatrix").matrixValue = this._projectionMatrix;
		uniformLib.uniform("near").floatValue = this._near;
		uniformLib.uniform("far").floatValue = this._far;
		uniformLib.uniform("nearFarFactor").floatValue = 2.0 / Math.log(this._far / this._near);
	}

	public function getProjectedPosition(worldPosition:Vector4):Vector2 {
		var viewProjectionMatrix = this.viewProjectionMatrix;
		var projectedPosition = MatrixHelper.transformVector3(viewProjectionMatrix, worldPosition);

		var x = 0.5 + (0.5 * projectedPosition.x);
		var y = 0.5 + (0.5 * projectedPosition.y);

		return new Vector2(x, y);
	}

}
