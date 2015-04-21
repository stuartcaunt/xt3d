package kfsgl.utils.gl;

import openfl.gl.GL;
class KFGL {


	public static inline var LOW_PRECISION:String = "lowp";
	public static inline var MEDIUM_PRECISION:String = "mediump";
	public static inline var HIGH_PRECISION:String = "highp";

// GL STATE CONSTANTS

	public static inline var CullFaceNone:Int = 0;
	public static inline var CullFaceBack:Int = 1;
	public static inline var CullFaceFront:Int = 2;
	public static inline var CullFaceFrontBack:Int = 3;

	public static inline var FrontFaceDirectionCW:Int = 0;
	public static inline var FrontFaceDirectionCCW:Int = 1;


	// MATERIAL CONSTANTS

	// Tells a material which side of a geometry is to be rendered
	public static inline var FrontSide:Int = 0;
	public static inline var BackSide:Int = 1;
	public static inline var DoubleSide:Int = 2;

	// shading
//	public static inline var NoShading:Int = 0;
//	public static inline var FlatShading:Int = 1;
//	public static inline var SmoothShading:Int = 2;

	// blending modes
	public static inline var NoBlending:Int = 0;
	public static inline var NormalBlending:Int = 1;
	public static inline var AdditiveBlending:Int = 2;
	public static inline var SubtractiveBlending:Int = 3;
	public static inline var MultiplyBlending:Int = 4;
	public static inline var CustomBlending:Int = 5;

	// Blend equations
	public static inline var GL_FUNC_ADD:Int = 0x0000;
	public static inline var GL_FUNC_SUBTRACT:Int = 0x0001;
	public static inline var GL_FUNC_REVERSE_SUBTRACT:Int = 0x0002;
	//public static inline var GL_MIN:Int = 0x0003;
	//public static inline var GL_MAX:Int = 0x0004;

	// Blending parameters
	public static inline var GL_ZERO:Int = 0x0100;
	public static inline var GL_ONE:Int = 0x0101;
	public static inline var GL_SRC_COLOR:Int = 0x0102;
	public static inline var GL_ONE_MINUS_SRC_COLOR:Int = 0x0103;
	public static inline var GL_DST_COLOR:Int = 0x0104;
	public static inline var GL_ONE_MINUS_DST_COLOR:Int = 0x0105;
	public static inline var GL_SRC_ALPHA:Int = 0x0106;
	public static inline var GL_ONE_MINUS_SRC_ALPHA:Int = 0x0107;
	public static inline var GL_DST_ALPHA:Int = 0x0108;
	public static inline var GL_ONE_MINUS_DST_ALPHA:Int = 0x0109;
	public static inline var GL_CONSTANT_COLOR:Int = 0x010A;
	public static inline var GL_ONE_MINUS_CONSTANT_COLOR:Int = 0x010B;
	public static inline var GL_CONSTANT_ALPHA:Int = 0x010C;
	public static inline var GL_ONE_MINUS_CONSTANT_ALPHA:Int = 0x010D;
	public static inline var GL_SRC_ALPHA_SATURATE:Int = 0x010E;


	public static inline var GL_CW:Int = 0x0200;
	public static inline var GL_CCW:Int = 0x0201;

	public static inline function toGLParam(param):Int {
		if (param == GL_FUNC_ADD) return GL.FUNC_ADD;
		if (param == GL_FUNC_SUBTRACT) return GL.FUNC_SUBTRACT;
		if (param == GL_FUNC_REVERSE_SUBTRACT) return GL.FUNC_REVERSE_SUBTRACT;
		//if (param == GL_MIN) return GL.MIN;
		//if (param == GL_MAX) return GL.MAX;

		if (param == GL_ZERO) return GL.ZERO;
		if (param == GL_ONE) return GL.ONE;
		if (param == GL_SRC_COLOR) return GL.SRC_COLOR;
		if (param == GL_ONE_MINUS_SRC_COLOR) return GL.ONE_MINUS_SRC_COLOR;
		if (param == GL_DST_COLOR) return GL.DST_COLOR;
		if (param == GL_ONE_MINUS_DST_COLOR) return GL.ONE_MINUS_DST_COLOR;
		if (param == GL_SRC_ALPHA) return GL.SRC_ALPHA;
		if (param == GL_ONE_MINUS_SRC_ALPHA) return GL.ONE_MINUS_SRC_ALPHA;
		if (param == GL_DST_ALPHA) return GL.DST_ALPHA;
		if (param == GL_ONE_MINUS_DST_ALPHA) return GL.ONE_MINUS_DST_ALPHA;
		if (param == GL_CONSTANT_COLOR) return GL.CONSTANT_COLOR;
		if (param == GL_ONE_MINUS_CONSTANT_COLOR) return GL.ONE_MINUS_CONSTANT_COLOR;
		if (param == GL_CONSTANT_ALPHA) return GL.CONSTANT_ALPHA;
		if (param == GL_ONE_MINUS_CONSTANT_ALPHA) return GL.ONE_MINUS_CONSTANT_ALPHA;
		if (param == GL_SRC_ALPHA_SATURATE) return GL.SRC_ALPHA_SATURATE;

		if (param == GL_CW) return GL.CW;
		if (param == GL_CCW) return GL.CCW;

		return 0;
	}

}
