package kfsgl.gl;

import kfsgl.utils.KF;
import kfsgl.gl.KFGL;
import openfl.gl.GL;

class GLStateManager {


	// States
	// Blending
	private var _oldBlending:Int = -1;
	private var _oldBlendEquation:Int = -1;
	private var _oldBlendSrc:Int = -1;
	private var _oldBlendDst:Int = -1;
	private var _oldBlendingEnabled:Int = -1;

	// Depth test
	private var _oldDepthTest = false;
	private var _oldDepthWrite = false;

	// Culling and face direction
	private var _oldCullFaceEnabled = false;
	private var _oldCullFace = -1;
	private var _oldFrontFaceDirection = -1;

	// Polygon offset
	private var _oldPolygonOffset:Bool = true;
	private var _oldPolygonOffsetFactor:Float = -1.0;
	private var _oldPolygonOffsetUnits:Float = -1.0;

	// Material sides
	private var _oldDoubleSided:Bool = false;
	private var _oldFlipSided:Bool = false;

	public static function create():GLStateManager {
		var object = new GLStateManager();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		this.setDefaultGLState();

		return true;
	}

	public function new() {

	}


	public function setDefaultGLState() {
		// Depth test
		this._oldDepthTest = false;
		this.setDepthTest(true);
		GL.depthFunc(GL.LEQUAL);

		// Depth write
		this._oldDepthWrite = false;
		this.setDepthWrite(true);
		GL.clearDepth(1.0);

		// Culling
		this._oldCullFaceEnabled = false;
		this.setCullFace(KFGL.CullFaceBack);

		// Set front face
		this.setFrontFaceDirection(KFGL.GL_CCW);

		// Set blending
		this.setBlending(KFGL.NormalBlending);

		// Set polygon offset
		this._oldPolygonOffset = true;
		this.setPolygonOffset(false);
	}


	public function setBlending(blending:Int, blendEquation:Int = KFGL.GL_FUNC_ADD, blendSrc:Int = KFGL.GL_SRC_ALPHA, blendDst:Int = KFGL.GL_ONE_MINUS_SRC_ALPHA) {
		if (blending != this._oldBlending || blending == KFGL.CustomBlending) {

			if (blending == KFGL.NoBlending) {
				// Disable blending
				if (this._oldBlendingEnabled != 0) {
					GL.disable(GL.BLEND);
					this._oldBlendingEnabled = 0;
				}

			} else {
				// Enable blending
				if (this._oldBlendingEnabled != 1) {
					GL.enable(GL.BLEND);
					this._oldBlendingEnabled = 1;

					// Reset blending
					this._oldBlendEquation = -1;
					this._oldBlendSrc = -1;
					this._oldBlendDst = -1;
				}

				// Determine blend equation and parameters
				if (blending == KFGL.AdditiveBlending) {
					blendEquation = KFGL.GL_FUNC_ADD;
					blendSrc = KFGL.GL_SRC_ALPHA;
					blendDst = KFGL.GL_ONE;

				} else if (blending == KFGL.SubtractiveBlending) {
					blendEquation = KFGL.GL_FUNC_ADD;
					blendSrc = KFGL.GL_ZERO;
					blendDst = KFGL.GL_ONE_MINUS_SRC_COLOR;

				} else if (blending == KFGL.MultiplyBlending) {
					blendEquation = KFGL.GL_FUNC_ADD;
					blendSrc = KFGL.GL_ZERO;
					blendDst = KFGL.GL_SRC_COLOR;

				} else if (blending == KFGL.CustomBlending) {
//					blendEquation = blendEquation;
//					blendSrc = blendSrc;
//					blendDst = blendDst;

				} else /* KFGL.NormalBlending */ {
					blendEquation = KFGL.GL_FUNC_ADD;
					blendSrc = KFGL.GL_SRC_ALPHA;
					blendDst = KFGL.GL_ONE_MINUS_SRC_ALPHA;
				}

				// Update blend equation
				if (blendEquation != this._oldBlendEquation) {
					GL.blendEquation(KFGL.toGLParam(blendEquation));
					this._oldBlendEquation = blendEquation;
				}

				// Update blend parameters
				if (blendSrc != this._oldBlendSrc || blendDst != this._oldBlendDst) {
					GL.blendFunc(KFGL.toGLParam(blendSrc), KFGL.toGLParam(blendDst));
					this._oldBlendSrc = blendSrc;
					this._oldBlendDst = blendDst;
				}

			}

			// Update blending type
			if (blending != this._oldBlending) {
				this._oldBlending = blending;
			}
		}
	}


	public function setMaterialSides(materialSide:Int):Void {

		var doubleSided = (materialSide == KFGL.DoubleSide);
		var flipSided = (materialSide == KFGL.BackSide);

		if (this._oldDoubleSided != doubleSided) {
			if (doubleSided) {
				this.setCullFaceEnabled(false);

			} else {
				this.setCullFaceEnabled(true);
			}

			this._oldDoubleSided = doubleSided;

		}

		if (this._oldFlipSided != flipSided) {
			this.setFrontFaceDirection(flipSided ? KFGL.GL_CW : KFGL.GL_CCW);

			this._oldFlipSided = flipSided;
		}
	}

	public inline function setDepthTest(depthTest) {
		if (this._oldDepthTest != depthTest) {
			if (depthTest) {
				GL.enable(GL.DEPTH_TEST);
			} else {
				GL.disable(GL.DEPTH_TEST);
			}

			this._oldDepthTest = depthTest;
		}
	}

	public inline function setDepthWrite(depthWrite) {
		if (this._oldDepthWrite != depthWrite) {
			GL.depthMask(depthWrite);

			this._oldDepthWrite = depthWrite;
		}
	}



	public function setPolygonOffset(polygonoffset:Bool, factor:Float = 0.0, units:Float = 0.0) {

		if (this._oldPolygonOffset != polygonoffset ) {
			if (polygonoffset) {
				GL.enable(GL.POLYGON_OFFSET_FILL);

			} else {
				GL.disable(GL.POLYGON_OFFSET_FILL);
			}

			this._oldPolygonOffset = polygonoffset;
		}

		if (polygonoffset && (this._oldPolygonOffsetFactor != factor || this._oldPolygonOffsetUnits != units)) {

			GL.polygonOffset(factor, units);

			this._oldPolygonOffsetFactor = factor;
			this._oldPolygonOffsetUnits = units;
		}
	}

	public function setCullFace(cullFace) {
		// Enable/disable face culling
		this.setCullFaceEnabled(cullFace != KFGL.CullFaceNone);

		if (cullFace != this._oldCullFace) {
			// Set appropriate face(s)
			if (cullFace == KFGL.CullFaceNone) {
				// Do nothing

			} else if (cullFace == KFGL.CullFaceBack) {
				GL.cullFace(GL.BACK);

			} else if (cullFace == KFGL.CullFaceFront) {
				GL.cullFace(GL.FRONT);

			} else {
				GL.cullFace(GL.FRONT_AND_BACK);
			}

		}
	}


	public inline function setCullFaceEnabled(cullFaceEnabled) {
		// Disable face culling
		if (this._oldCullFaceEnabled != cullFaceEnabled) {
			if (cullFaceEnabled) {
				GL.enable(GL.CULL_FACE);

			} else {
				GL.disable(GL.CULL_FACE);
			}
			this._oldCullFaceEnabled = cullFaceEnabled;
		}
	}


	public inline function setFrontFaceDirection(direction:Int) {
		if (this._oldFrontFaceDirection != direction) {
			GL.frontFace(KFGL.toGLParam(direction));

			this._oldFrontFaceDirection = direction;
		}
	}



}
