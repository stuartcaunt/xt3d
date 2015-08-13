package xt3d.node;

import xt3d.utils.math.VectorHelper;
import xt3d.utils.XTObject;
import xt3d.utils.XT;
import xt3d.utils.errors.XTException;
import xt3d.utils.math.MatrixHelper;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;

class Node3D extends XTObject {

	// properties
	public var id(get, null):UInt;
	public var visible(get, set):Bool;
	public var excluded(get, set):Bool;
	public var parent(get, set):Node3D;
	public var position(get, set):Vector3D;
	public var worldPosition(get, null):Vector3D;
	public var matrix(get, set):Matrix3D;
	public var worldMatrix(get, set):Matrix3D;
	public var worldMatrixDirty(get, set):Bool;

	public var rotationX(get, set):Float;
	public var rotationY(get, set):Float;
	public var rotationZ(get, set):Float;


	// members
	private static var ID_COUNTER = 0;
	private var _id:Int = ID_COUNTER++;

	// scene graph
	private var _children:Array<Node3D> = new Array<Node3D>();
	private var _parent:Node3D = null;

	// transformations
	private var _matrix:Matrix3D = new Matrix3D();
	private var _position:Vector3D = new Vector3D();
	private var _matrixDirty:Bool = false;
	private var _worldMatrix:Matrix3D = new Matrix3D();
	private var _worldPosition:Vector3D = new Vector3D();
	private var _worldMatrixDirty:Bool = false;
	private var _rotationMatrixDirty:Bool = false;
	private var _eulerAnglesDirty:Bool = false;

	private var _rotationX:Float = 0.0;
	private var _rotationY:Float = 0.0;
	private var _rotationZ:Float = 0.0;
	private var _scaleX:Float = 1.0;
	private var _scaleY:Float = 1.0;
	private var _scaleZ:Float = 1.0;

	// Visibility
	private var _visible:Bool = true;
	private var _excluded:Bool = false;

	public static function create():Node3D {
		var object = new Node3D();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}


	public function init():Bool {
		var retval = true;

		this._worldMatrixDirty = false;
		this._matrixDirty = false;
		this._rotationMatrixDirty = false;

		return retval;
	}

	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	public inline function get_id():Int {
		return this._id;
	}

	public inline function get_excluded():Bool {
		return this._excluded;
	}

	public inline function set_excluded(excluded:Bool):Bool {
		this.setExcluded(excluded);
		return excluded;
	}

	public inline function get_visible():Bool {
		return this._visible;
	}

	public inline function set_visible(visible:Bool):Bool {
		this.setVisible(visible);
		return visible;
	}

	private inline function get_parent():Node3D {
		return this._parent;
	}

	private inline function set_parent(value:Node3D):Node3D {
		// Should only be used internally
		return this._parent = value;
	}

	public inline function get_position():Vector3D {
		return this.getPosition();
	}

	public inline function set_position(position:Vector3D):Vector3D {
		this.setPosition(position);
		return position;
	}

	public inline function get_worldPosition():Vector3D {
		return this.getWorldPosition();
	}

	public inline function get_worldMatrixDirty():Bool {
		return this._worldMatrixDirty;
	}

	public inline function set_worldMatrixDirty(isDirty:Bool):Bool {
		this.setWorldMatrixDirty(isDirty);
		return this._worldMatrixDirty;
	}

	public inline function get_worldMatrix():Matrix3D {
		return this._worldMatrix;
	}

	public inline function set_worldMatrix(matrix:Matrix3D):Matrix3D {
		this.setWorldMatrix(matrix);
		return this._worldMatrix;
	}

	public inline function get_matrix():Matrix3D {
		return this._matrix;
	}

	public inline function set_matrix(matrix:Matrix3D):Matrix3D {
		this.setMatrix(matrix);
		return this._matrix;
	}

	inline public function get_rotationX():Float {
		return this.getRotationX();
	}

	inline public function set_rotationX(rotationX:Float):Float {
		this.setRotationX(rotationX);
		return this._rotationX;
	}

	inline public function get_rotationY():Float {
		return this.getRotationY();
	}

	inline public function set_rotationY(rotationY:Float):Float {
		this.setRotationY(rotationY);
		return this._rotationY;
	}

	inline public function get_rotationZ():Float {
		return this.getRotationZ();
	}

	inline public function set_rotationZ(rotationZ:Float):Float {
		this.setRotationZ(rotationZ);
		return this._rotationZ;
	}


/* --------- Implementation --------- */

	public inline function getExcluded():Bool {
		return this._excluded;
	}

	public inline function setExcluded(excluded:Bool):Void {
		this._excluded = excluded;
	}

	public inline function getVisible():Bool {
		return this._visible;
	}

	public inline function setVisible(visible:Bool):Void {
		this._visible = visible;
	}

	/* --------- Scene graph --------- */

	public function addChild(child:Node3D):Void {
		if (child.parent != null) {
			throw new XTException("NodeCannotBeAddedTwice", "The node with id \"" + this._id + "\" cannot be added twice");
		}
		if (child == null) {
			throw new XTException("NodeCannotBeNull", "Cannot add a null node");
		}

		this._children.push(child);
		child._parent = this;

	}

	public inline function removeChild(child:Node3D):Void {
		this._children.remove(child);
		child._parent = null;
	}


	inline public function getParent():Node3D {
		return this._parent;
	}

	public function updateObjects(scene:Scene):Void {
		// If excluded then ignore all children too
		if (this._excluded) {
			return;
		}

		// Individual update
		this.updateObject(scene);

		for (child in this._children) {
			child.updateObjects(scene);
		}

	}


	public function updateObject(scene:Scene):Void {
		// Override me
	}

	/**
	 * User-defined traversal function: call function recursively through the scene
	 */
	public function traverse(callback:Node3D->Void):Void {
		callback(this);

		for (child in this._children) {
			child.traverse(callback);
		}
	}


	/* --------- Transformation manipulation --------- */


	inline public function getPosition():Vector3D {
		var raw = this._matrix.rawData;
		VectorHelper.set(this._position, raw[12], raw[13], raw[14], raw[15]);
		return this._position;
	}

	inline public function setPosition(position:Vector3D):Void {
		this._matrix.position = position;
		this._worldMatrixDirty = true;
	}

	inline public function getRotationX():Float {
		if (this._eulerAnglesDirty) {
			this.updateEulerAngles();
		}
		return this._rotationX;
	}

	inline public function setRotationX(rotationX:Float):Void {
		this._rotationX = rotationX;

		this._rotationMatrixDirty = true;
		this._matrixDirty = true;
	}

	inline public function getRotationY():Float {
		if (this._eulerAnglesDirty) {
			this.updateEulerAngles();
		}
		return this._rotationY;
	}

	inline public function setRotationY(rotationY:Float):Void {
		this._rotationY = rotationY;

		this._rotationMatrixDirty = true;
		this._matrixDirty = true;
	}

	inline public function getRotationZ():Float {
		if (this._eulerAnglesDirty) {
			this.updateEulerAngles();
		}
		return this._rotationZ;
	}

	inline public function setRotationZ(rotationZ:Float):Void {
		this._rotationZ = rotationZ;

		this._rotationMatrixDirty = true;
		this._matrixDirty = true;
	}

	private function updateEulerAngles():Void {
		var r:Vector3D = MatrixHelper.getEulerRotationFromMatrix(this._matrix);
		this._rotationX = r.x;
		this._rotationY = r.y;
		this._rotationZ = r.z;

		this._eulerAnglesDirty = false;
	}


/* --------- Matrix Transformations --------- */

	inline public function getWorldPosition() {
		var raw = this._worldMatrix.rawData;
		VectorHelper.set(this._worldPosition, raw[12], raw[13], raw[14], raw[15]);
		return this._worldPosition;
	}

	public inline function getWorldMatrix():Matrix3D {
		return this._worldMatrix;
	}

	public inline function setWorldMatrix(matrix:Matrix3D):Void {
		this._worldMatrix = matrix;

		this._matrixDirty = false; // ??? Do we force the object NOT to update the matrix, which will override this new world matrix
		this._worldMatrixDirty = false;
		this._eulerAnglesDirty = true;
	}

	public inline function getMatrix():Matrix3D {
		return this._matrix;
	}

	public inline function setMatrix(matrix:Matrix3D):Void {
		this._matrix = matrix;

		this._matrixDirty = false;
		this._worldMatrixDirty = true;
		this._eulerAnglesDirty = true;
	}



	// --------- Transformation matrix calculations ---------

	public function updateRotationMatrix():Void {
		MatrixHelper.setRotationFromEuler(this._matrix, this._rotationX, this._rotationY, this._rotationZ);
		this._rotationMatrixDirty = false;
	}

	public function updateMatrix():Void {
		if (this._matrixDirty) {
			// Translation already set...

			// Convert rotation matrix into euler angles if necessary
			if (_rotationMatrixDirty) {
				this.updateRotationMatrix();
			}

			// Scale transformation (no effect on translation)
			this._matrix.prependScale(this._scaleX, this._scaleY, this._scaleZ);

			this._matrixDirty = false;
			this._worldMatrixDirty = true;
		}
	}


	/*
	 * Indicates to the object that its transformation needs to be recalculated.
	 * Note that this intended to be called internally by iSGL3D.
	 * @param isDirty Indicates whether the transformation needs to be recalculated or not.
	 */
	public inline function setWorldMatrixDirty(isDirty:Bool):Void {
		this._worldMatrixDirty = isDirty;
	}

	/*
	 * Updates the world transformation of the object given the parent's world transformation.
	 * Note that this intended to be called internally.
	 */
	public function updateWorldMatrix():Void {

		// Recalculate local transformation if necessary
		if (this._matrixDirty) {
			this.updateMatrix();
		}

		// Update transformation matrices if needed
		if (this._worldMatrixDirty) {

			// Let all children know that they must update their world transformation,
			//   even if they themselves have not locally changed
			for (child in this._children) {
				child.worldMatrixDirty = true;
			}

			// Calculate world transformation
			if (this._parent != null) {
				this._worldMatrix.copyFrom(_parent.worldMatrix);
				this._worldMatrix.prepend(_matrix);

			} else {
				this._worldMatrix.copyFrom(_matrix);
			}

			this._worldMatrixDirty = false;
		}

		// Update all children transformations
		for (child in this._children) {
			child.updateWorldMatrix();
		}
	}

	// --------- Scheduling ---------


}
