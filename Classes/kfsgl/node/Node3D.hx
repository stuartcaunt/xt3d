package kfsgl.node;

import kfsgl.math.MatrixHelper;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
class Node3D {

	// properties
	public var position(get, set):Vector3D;
	public var worldPosition(get, null):Vector3D;
	public var transformationDirty(get, set):Bool;

	// members
	private var _children:Array<Node3D> = new Array<Node3D>();
	private var _localTransformation:Matrix3D = new Matrix3D();
	private var _worldTransformation:Matrix3D = new Matrix3D();
	private var _localTransformationDirty:Bool = false;
	private var _transformationDirty:Bool = false;
	private var _rotationMatrixDirty:Bool = false;
	private var _hasChildren:Bool = false;

	private var _rotationX:Float = 0.0;
	private var _rotationY:Float = 0.0;
	private var _rotationZ:Float = 0.0;
	private var _scaleX:Float = 1.0;
	private var _scaleY:Float = 1.0;
	private var _scaleZ:Float = 1.0;

	public function new() {
	}


	/* ----------- Properties ----------- */

	public inline function get_position():Vector3D {
		return this._localTransformation.position;
	}

	public inline function set_position(position:Vector3D):Vector3D {
		this.setPosition(position);
		return position;
	}

	public inline function get_worldPosition():Vector3D {
		return this.getWorldPosition();
	}


	public inline function get_transformationDirty():Bool {
		return this._transformationDirty;
	}


	public inline function set_transformationDirty(isDirty:Bool):Bool {
		this.setTransformationDirty(isDirty);
		return this.transformationDirty;
	}




	/* --------- Implementation --------- */


	public static function create():Node3D {
		var object = new Node3D();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}


	public function init():Bool {
		var retval = true;

		this._transformationDirty = false;
		this._localTransformationDirty = false;
		this._rotationMatrixDirty = false;
		this._hasChildren = false;

		return retval;
	}

	inline public function getPosition() {
		return this._localTransformation.position;
	}

	inline public function setPosition(position:Vector3D) {
		this._localTransformation.position = position;
	}

	inline public function getWorldPosition() {
		return this._worldTransformation.position;
	}




	// --------- Transformation matrix calculations ---------

	public function updateRotationMatrix():Void {
		MatrixHelper.setRotationFromEuler(this._localTransformation, this._rotationX, this._rotationY, this._rotationZ);
		this._rotationMatrixDirty = false;
	}

	public function updateLocalTransformation():Void {
		// Translation already set...

		// Convert rotation matrix into euler angles if necessary
		if (_rotationMatrixDirty) {
			this.updateRotationMatrix();
		}

		// Scale transformation (no effect on translation)
		this._localTransformation.prependScale(this._scaleX, this._scaleY, this._scaleZ);

		this._localTransformationDirty = false;
		this._transformationDirty = true;
	}


	/*
	 * Indicates to the object that its transformation needs to be recalculated.
	 * Note that this intended to be called internally by iSGL3D.
	 * @param isDirty Indicates whether the transformation needs to be recalculated or not.
	 */
	public inline function setTransformationDirty(isDirty:Bool):Void {
		this._transformationDirty = isDirty;
	}

	/*
	 * Updates the world transformation of the object given the parent's world transformation.
	 * Note that this intended to be called internally.
	 * @param parentTransformation The parent's world transformation matrix.
	 */
	public function updateWorldTransformation(parentTransformation:Matrix3D):Void {

		// Recalculate local transformation if necessary
		if (this._localTransformationDirty) {
			this.updateLocalTransformation();
		}

		// Update transformation matrices if needed
		if (_transformationDirty) {

			// Let all children know that they must update their world transformation,
			//   even if they themselves have not locally changed
			if (this._hasChildren) {
				for (child in this._children) {
					child.transformationDirty = true;
				}
			}

			// Calculate world transformation
			if (parentTransformation != null) {
				this._worldTransformation.copyFrom(parentTransformation);
				this._worldTransformation.prepend(_localTransformation);

			} else {
				this._worldTransformation.copyFrom(_localTransformation);
			}

			this._transformationDirty = false;
		}

		// Update all children transformations
		if (this._hasChildren) {
			for (child in this._children) {
				child.updateWorldTransformation(this._worldTransformation);
			}
		}
	}

}
