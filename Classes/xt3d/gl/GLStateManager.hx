package xt3d.gl;

import xt3d.utils.color.Color;
import xt3d.gl.XTGL;
import lime.graphics.opengl.GL;

class GLStateManager {


	// States
	// Blending
	private var _oldBlending:Int = -1;
	private var _oldBlendEquation:Int = -1;
	private var _oldBlendSrc:Int = -1;
	private var _oldBlendDst:Int = -1;
	private var _oldBlendingEnabled:Int = -1;

	private var _clearColor:Color = null;
	private var _colorMask:UInt = 0;

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

		this.setColorMask(true, true, true, false);

		// Culling
		this._oldCullFaceEnabled = false;
		this.setCullFace(XTGL.CullFaceBack);

		// Set front face
		this.setFrontFaceDirection(XTGL.GL_CCW);

		// Set blending
		this.setBlending(XTGL.NormalBlending);

		// Set polygon offset
		this._oldPolygonOffset = true;
		this.setPolygonOffset(false);
	}


	public function setBlending(blending:Int, blendEquation:Int = XTGL.GL_FUNC_ADD, blendSrc:Int = XTGL.GL_SRC_ALPHA, blendDst:Int = XTGL.GL_ONE_MINUS_SRC_ALPHA) {
		if (blending != this._oldBlending || blending == XTGL.CustomBlending) {

			if (blending == XTGL.NoBlending) {
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
				if (blending == XTGL.AdditiveBlending) {
					blendEquation = XTGL.GL_FUNC_ADD;
					blendSrc = XTGL.GL_SRC_ALPHA;
					blendDst = XTGL.GL_ONE;

				} else if (blending == XTGL.SubtractiveBlending) {
					blendEquation = XTGL.GL_FUNC_ADD;
					blendSrc = XTGL.GL_ZERO;
					blendDst = XTGL.GL_ONE_MINUS_SRC_COLOR;

				} else if (blending == XTGL.MultiplyBlending) {
					blendEquation = XTGL.GL_FUNC_ADD;
					blendSrc = XTGL.GL_ZERO;
					blendDst = XTGL.GL_SRC_COLOR;

				} else if (blending == XTGL.CustomBlending) {
//					blendEquation = blendEquation;
//					blendSrc = blendSrc;
//					blendDst = blendDst;

				} else /* XTGL.NormalBlending */ {
					blendEquation = XTGL.GL_FUNC_ADD;
					blendSrc = XTGL.GL_SRC_ALPHA;
					blendDst = XTGL.GL_ONE_MINUS_SRC_ALPHA;
				}

				// Update blend equation
				if (blendEquation != this._oldBlendEquation) {
					GL.blendEquation(XTGL.toGLParam(blendEquation));
					this._oldBlendEquation = blendEquation;
				}

				// Update blend parameters
				if (blendSrc != this._oldBlendSrc || blendDst != this._oldBlendDst) {
					GL.blendFunc(XTGL.toGLParam(blendSrc), XTGL.toGLParam(blendDst));
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

		var doubleSided = (materialSide == XTGL.DoubleSide);
		var flipSided = (materialSide == XTGL.BackSide);

		if (this._oldDoubleSided != doubleSided) {
			if (doubleSided) {
				this.setCullFaceEnabled(false);

			} else {
				this.setCullFaceEnabled(true);
			}

			this._oldDoubleSided = doubleSided;

		}

		if (this._oldFlipSided != flipSided) {
			this.setFrontFaceDirection(flipSided ? XTGL.GL_CW : XTGL.GL_CCW);

			this._oldFlipSided = flipSided;
		}
	}

	public inline function setClearColor(color:Color) {
		// Note: HAVE to set clearColor every frame because opengfl GLRenderer sets this to another value
		// TODO: remove openfl OpenglView
		//if (!color.equals(this._clearColor)) {
			GL.clearColor(color.red, color.green, color.blue, color.alpha);
			this._clearColor = color;
		//}
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

	public inline function setColorMask(red:Bool, green:Bool, blue:Bool, alpha:Bool) {
		var colorMask = 0;
		colorMask |= red ? XTGL.RedBit : 0;
		colorMask |= green ? XTGL.GreenBit : 0;
		colorMask |= blue ? XTGL.BlueBit : 0;
		colorMask |= alpha ? XTGL.AlphaBit : 0;
		if (this._colorMask != colorMask) {
			GL.colorMask(red, green, blue, alpha);

			this._colorMask = colorMask;
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
		this.setCullFaceEnabled(cullFace != XTGL.CullFaceNone);

		if (cullFace != this._oldCullFace) {
			// Set appropriate face(s)
			if (cullFace == XTGL.CullFaceNone) {
				// Do nothing

			} else if (cullFace == XTGL.CullFaceBack) {
				GL.cullFace(GL.BACK);

			} else if (cullFace == XTGL.CullFaceFront) {
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
			GL.frontFace(XTGL.toGLParam(direction));

			this._oldFrontFaceDirection = direction;
		}
	}



}
