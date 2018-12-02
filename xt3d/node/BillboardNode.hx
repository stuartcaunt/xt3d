package xt3d.node;


import xt3d.math.Matrix4;
import xt3d.core.Director;
import xt3d.core.Director;
import lime.graphics.opengl.GL;
import xt3d.node.RenderObject;
import xt3d.geometry.Geometry;
import xt3d.material.Material;

class BillboardNode extends Node3D {

	// properties

	// members
	var _worldMatrixCopy:Matrix4 = new Matrix4();

	public static function create():BillboardNode {
		var object = new BillboardNode();

		if (object != null && !(object.initBillboardNode())) {
			object = null;
		}

		return object;
	}

	public function initBillboardNode():Bool {
		var retval;
		if ((retval = super.init())) {

		}

		return retval;
	}

	public function new() {
		super();
	}



	/* ----------- Properties ----------- */


	/* --------- Implementation --------- */

	public override function updateWorldMatrix():Bool {

		// Update transformation but don't update children yet
		super.updateMatrix();

		// Update transformation matrices if needed
		if (this._worldMatrixDirty) {
			// Calculate world transformation
			this._worldMatrix.copyFrom(_parent.worldMatrix);
			this._worldMatrix.prepend(_matrix);

			this._worldMatrixDirty = false;
		}

		// Modify the final world transformation so that the rotation
		// faces the camera : use inverted view matrix
		var camera = Director.current.activeCamera;
		var cameraInverseViewMatrix = camera.inverseViewMatrix;

		this._worldMatrix[0] = cameraInverseViewMatrix[0] * this._scaleX;
		this._worldMatrix[4] = cameraInverseViewMatrix[4] * this._scaleX;
		this._worldMatrix[8] = cameraInverseViewMatrix[8] * this._scaleX;
		this._worldMatrix[1] = cameraInverseViewMatrix[1] * this._scaleY;
		this._worldMatrix[5] = cameraInverseViewMatrix[5] * this._scaleY;
		this._worldMatrix[9] = cameraInverseViewMatrix[9] * this._scaleY;
		this._worldMatrix[2] = cameraInverseViewMatrix[2] * this._scaleZ;
		this._worldMatrix[6] = cameraInverseViewMatrix[6] * this._scaleZ;
		this._worldMatrix[10] = cameraInverseViewMatrix[10] * this._scaleZ;

		// Check for changes before updating children
		var changed:Bool = false;
		for (i in 0 ... 16) {
			if (this._worldMatrix[i] != this._worldMatrixCopy[i]) {
				changed = true;
			}
			this._worldMatrixCopy[i] = this._worldMatrix[i];
		}

		// Update all children transformations if a change has occurred
		if (changed) {
			for (child in this._children) {
				child.worldMatrixDirty = true;
				child.updateWorldMatrix();
			}
		}

		return changed;
	}

}