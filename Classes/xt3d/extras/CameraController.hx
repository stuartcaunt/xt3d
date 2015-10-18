package xt3d.extras;

import xt3d.events.gestures.PinchGestureRecognizer;
import xt3d.node.Node3D;
import lime.math.Vector4;
import xt3d.utils.XTObject;
import xt3d.core.Director;
import xt3d.events.gestures.PanGestureRecognizer;
import xt3d.node.Camera;

class CameraController extends Node3D implements PanGestureDelegate implements PinchGestureDelegate {

	// properties
	public var orbit(get, set):Float;
	public var xOrbitFactor(get, set):Float;
	public var yOrbitFactor(get, set):Float;
	public var zOrbitFactor(get, set):Float;
	public var damping(get, set):Float;

	public var camera(get, set):Camera;
	public var target(get, set):Node3D;

	// members
	private var _orbit:Float;
	private var _orbitMin:Float;
	private var _xOrbitFactor:Float = 1.0;
	private var _yOrbitFactor:Float = 1.0;
	private var _zOrbitFactor:Float = 1.0;
	private var _damping:Float = 0.8;

	private var _camera:Camera;
	private var _target:Node3D = null;

	private var _theta:Float = 0.0;
	private var _phi:Float = 0.0;
	private var _vTheta:Float = 0.0;
	private var _vPhi:Float = 0.0;

	public static function create(camera:Camera, orbit:Float = 10.0):CameraController {
		var object = new CameraController();

		if (object != null && !(object.initWithCamera(camera, orbit))) {
			object = null;
		}

		return object;
	}

	public function initWithCamera(camera:Camera, orbit:Float = 10.0):Bool {
		this._camera = camera;
		this._orbit = orbit;
		this._orbitMin = 0.3 * orbit;

		var panGestureRecognizer = PanGestureRecognizer.create(this);
		this.addChild(panGestureRecognizer);

		var pinchGestureRecognizer = PinchGestureRecognizer.create(this);
		this.addChild(pinchGestureRecognizer);

		this.update(0.0);
		this.scheduleUpdate();

		return true;
	}


	public function new() {
		super();
	}



	/* ----------- Properties ----------- */

	inline function get_orbit():Float {
		return this._orbit;
	}

	inline function set_orbit(value:Float) {
		return this._orbit = value;
	}

	inline function get_xOrbitFactor():Float {
		return this._xOrbitFactor;
	}

	inline function set_xOrbitFactor(value:Float) {
		return this._xOrbitFactor = value;
	}

	inline function get_yOrbitFactor():Float {
		return this._yOrbitFactor;
	}

	inline function set_yOrbitFactor(value:Float) {
		return this._yOrbitFactor = value;
	}

	inline function get_zOrbitFactor():Float {
		return this._zOrbitFactor;
	}

	inline function set_zOrbitFactor(value:Float) {
		return this._zOrbitFactor = value;
	}

	inline function get_damping():Float {
		return this._damping;
	}

	inline function set_damping(value:Float) {
		return this._damping = value;
	}

	inline function get_camera():Camera {
		return this._camera;
	}

	inline function set_camera(value:Camera) {
		return this._camera = value;
	}

	function get_target():Node3D {
		return this._target;
	}

	function set_target(value:Node3D) {
		return this._target = value;
	}

	/* --------- Implementation --------- */

	override public function update(dt:Float):Void {
		// Update and limit the camera angles
		this._theta -= this._vTheta;
		this._phi -= this._vPhi;
		if (this._phi >= 90.0) {
			this._phi = 89.9;
		}
		if (this._phi <= -90.0) {
			this._phi = -89.9;
		}

		if (this._orbit < this._orbitMin) {
			this._orbit = this._orbitMin;
		}

		// Convert camera angles to positions
		var y = this._orbit * Math.sin(this._phi * Math.PI / 180.0) * this._yOrbitFactor;
		var l = this._orbit * Math.cos(this._phi * Math.PI / 180.0);
		var x = l * Math.sin(this._theta * Math.PI / 180.0) * this._xOrbitFactor;
		var z = l * Math.cos(this._theta * Math.PI / 180.0) * this._zOrbitFactor;

		// Take target into account if it exists
		if (this._target != null) {
			var targetPosition = this._target.worldPosition;

			x += targetPosition.x;
			y += targetPosition.y;
			z += targetPosition.z;

			this._camera.setLookAt(targetPosition);
		}

		// Translate camera
		this._camera.position = new Vector4(x, y, z);

		// Add damping to camera velocities
		var dvTheta = 5.0 * this._vTheta * this._damping * dt;
		var dvPhi = 5.0 * this._vPhi * this._damping * dt;
		this._vTheta -= dvTheta;
		this._vPhi -= dvPhi;
	}

	public function onPan(panEvent:PanEvent):Bool {
		this._vPhi = -panEvent.delta.y / 4.0;
		this._vTheta = panEvent.delta.x / 4.0;

		return false;
	}

	public function onPinch(pinchEvent:PinchEvent):Bool {
		this._orbit += pinchEvent.deltaDistance * 0.1;

		return false;
	}

}
