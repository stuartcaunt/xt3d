package xt3d.gl;

import lime.graphics.opengl.GL;
class XTGL {


	public static inline var LOW_PRECISION:String = "lowp";
	public static inline var MEDIUM_PRECISION:String = "mediump";
	public static inline var HIGH_PRECISION:String = "highp";

// GL STATE CONSTANTS


	public static inline var RedBit:Int = 1 << 0;
	public static inline var GreenBit:Int = 1 << 1;
	public static inline var BlueBit:Int = 1 << 2;
	public static inline var AlphaBit:Int = 1 << 3;

	public static inline var CullFaceNone:Int = 0;
	public static inline var CullFaceBack:Int = 1;
	public static inline var CullFaceFront:Int = 2;
	public static inline var CullFaceFrontBack:Int = 3;

	public static inline var FrontFaceDirectionCW:Int = 0;
	public static inline var FrontFaceDirectionCCW:Int = 1;

	public static inline var ZSortingNone:Int = 0;
	public static inline var ZSortingTransparent:Int = 1;
	public static inline var ZSortingOpaque:Int = 2;
	public static inline var ZSortingAll:Int = ZSortingTransparent | ZSortingOpaque;


	// PIXEL FORMAT
	// 32-bit texture: RGBA8888
	public static inline var Texture2DPixelFormat_RGBA8888:Int = 0;
	// 24-bit texture: RGBA888
	public static inline var Texture2DPixelFormat_RGB888:Int = 1;
	// 16-bit textures: RGBA4444
	public static inline var Texture2DPixelFormat_RGBA4444:Int = 6;
	// 16-bit texture without Alpha channel
	public static inline var Texture2DPixelFormat_RGB565:Int = 2;
	// 16-bit textures: RGB5A1
	public static inline var Texture2DPixelFormat_RGB5A1:Int = 7;
	// 8-bit textures used as masks
	public static inline var Texture2DPixelFormat_A8:Int = 3;
	// 8-bit intensity texture
	public static inline var Texture2DPixelFormat_I8:Int = 4;
	// 16-bit textures used as masks
	public static inline var Texture2DPixelFormat_AI88:Int = 5;
	// 4-bit PVRTC-compressed texture: PVRTC4
	public static inline var Texture2DPixelFormat_PVRTC4:Int = 8;
	// 2-bit PVRTC-compressed texture: PVRTC2
	public static inline var Texture2DPixelFormat_PVRTC2:Int = 9;
	// 32-bit float
	public static inline var Texture2DPixelFormat_Float1:Int = 10;
	public static inline var Texture2DPixelFormat_Float2:Int = 11;
	public static inline var Texture2DPixelFormat_Float3:Int = 12;
	public static inline var Texture2DPixelFormat_Float4:Int = 13;


	public static inline var DepthStencilFormatNone:Int = 0;
	public static inline var DepthStencilFormatDepth:Int = 1;
	public static inline var DepthStencilFormatStencil:Int = 2;
	public static inline var DepthStencilFormatDepthAndStencil:Int = 3;

	public static inline var PointLight:Int = 1;
	public static inline var DirectionalLight:Int = 2;
	public static inline var SpotLight:Int = 3;


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

	// Winding
	public static inline var GL_CW:Int = 0x0200;
	public static inline var GL_CCW:Int = 0x0201;

	// Texture options
	// Wrapping modes

	public static inline var GL_REPEAT = 0x0300;
	public static inline var GL_CLAMP_TO_EDGE = 0x0301;
	public static inline var GL_MIRRORED_REPEAT = 0x0302;

	// Filters
	public static inline var GL_NEAREST = 0x0400;
	public static inline var GL_NEAREST_MIPMAP_NEAREST = 0x0401;
	public static inline var GL_NEAREST_MIPMAP_LINEAR = 0x0402;
	public static inline var GL_LINEAR = 0x0403;
	public static inline var GL_LINEAR_MIPMAP_NEAREST = 0x0404;
	public static inline var GL_LINEAR_MIPMAP_LINEAR = 0x0405;


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

		if (param == GL_REPEAT) return GL.REPEAT;
		if (param == GL_CLAMP_TO_EDGE) return GL.CLAMP_TO_EDGE;
		if (param == GL_NEAREST) return GL.NEAREST;
		if (param == GL_REPEAT) return GL.REPEAT;
		if (param == GL_NEAREST_MIPMAP_NEAREST) return GL.NEAREST_MIPMAP_NEAREST;
		if (param == GL_NEAREST_MIPMAP_LINEAR) return GL.NEAREST_MIPMAP_LINEAR;
		if (param == GL_LINEAR) return GL.LINEAR;
		if (param == GL_LINEAR_MIPMAP_NEAREST) return GL.LINEAR_MIPMAP_NEAREST;
		if (param == GL_LINEAR_MIPMAP_LINEAR) return GL.LINEAR_MIPMAP_LINEAR;

		return 0;
	}

}
