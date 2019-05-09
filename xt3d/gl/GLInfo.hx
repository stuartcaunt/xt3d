package xt3d.gl;

import lime.graphics.opengl.GLShaderPrecisionFormat;
import xt3d.gl.GLCurrentContext.GL;

class GLInfo {

	// properties
	public var version(get, null):String;
	public var vendor(get, null):String;
	public var renderer(get, null):String;
	public var shadingLanguageVersion(get, null):String;

	public var alphaBits(get, null):Int;
	public var redBits(get, null):Int;
	public var greenBits(get, null):Int;
	public var blueBits(get, null):Int;
	public var depthBits(get, null):Int;
	public var stencilBits(get, null):Int;

	public var maxTextureImageUnits(get, null):Int;
	public var maxVertexTexturesImageUnits(get, null):Int;
	public var maxCombinedTextureImageUnits(get, null):Int;
	public var maxTextureSize(get, null):Int;
	public var maxCubemapTextureSize(get, null):Int;

	public var maxVertexAttribs(get, null):Int;
	public var maxVaryingVectors(get, null):Int;
	public var maxVertexUniformVectors(get, null):Int;
	public var maxFragmentUniformVectors(get, null):Int;

	public var maxRenderbufferSize(get, null):Int;
	public var maxViewportDims(get, null):Array<Int>;
	public var aliasedLineWidthRange(get, null):Array<Int>;
	public var aliasedPointSizeRange(get, null):Array<Int>;

	public var vertexShaderPrecisionHighpFloat(get, null):GLShaderPrecisionFormat;
	public var vertexShaderPrecisionMediumpFloat(get, null):GLShaderPrecisionFormat;
	public var fragmentShaderPrecisionHighpFloat(get, null):GLShaderPrecisionFormat;
	public var fragmentShaderPrecisionMediumpFloat(get, null):GLShaderPrecisionFormat;

	// members
	private var _version:String;
	private var _vendor:String;
	private var _renderer:String;
	private var _shadingLanguageVersion:String;

	private var _alphaBits:Int;
	private var _redBits:Int;
	private var _greenBits:Int;
	private var _blueBits:Int;
	private var _depthBits:Int;
	private var _stencilBits:Int;

	private var _maxTextureImageUnits:Int;
	private var _maxVertexTexturesImageUnits:Int;
	private var _maxCombinedTextureImageUnits:Int;
	private var _maxTextureSize:Int;
	private var _maxCubemapTextureSize:Int;

	private var _maxVertexAttribs:Int;
	private var _maxVaryingVectors:Int;
	private var _maxVertexUniformVectors:Int;
	private var _maxFragmentUniformVectors:Int;

	private var _maxRenderbufferSize:Int;
	private var _maxViewportDims:Array<Int>;
	private var _aliasedLineWidthRange:Array<Int>;
	private var _aliasedPointSizeRange:Array<Int>;

	private var _vertexShaderPrecisionHighpFloat:GLShaderPrecisionFormat;
	private var _vertexShaderPrecisionMediumpFloat:GLShaderPrecisionFormat;
	private var _fragmentShaderPrecisionHighpFloat:GLShaderPrecisionFormat;
	private var _fragmentShaderPrecisionMediumpFloat:GLShaderPrecisionFormat;


	public static function create():GLInfo {
		var object = new GLInfo();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		this._version = GL.getParameter(GL.VERSION);
		this._vendor = GL.getParameter(GL.VENDOR);
		this._renderer = GL.getParameter(GL.RENDERER);
		this._shadingLanguageVersion = GL.getParameter(GL.SHADING_LANGUAGE_VERSION);

		this._alphaBits = GL.getParameter(GL.ALPHA_BITS);
		this._redBits = GL.getParameter(GL.RED_BITS);
		this._greenBits = GL.getParameter(GL.GREEN_BITS);
		this._blueBits = GL.getParameter(GL.BLUE_BITS);
		this._depthBits = GL.getParameter(GL.DEPTH_BITS);
		this._stencilBits = GL.getParameter(GL.STENCIL_BITS);

		this._maxTextureImageUnits = GL.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
		this._maxVertexTexturesImageUnits = GL.getParameter(GL.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
		this._maxCombinedTextureImageUnits = GL.getParameter(GL.MAX_COMBINED_TEXTURE_IMAGE_UNITS);
		this._maxTextureSize = GL.getParameter(GL.MAX_TEXTURE_SIZE);
		this._maxCubemapTextureSize = GL.getParameter(GL.MAX_CUBE_MAP_TEXTURE_SIZE);

		this._maxVertexAttribs = GL.getParameter(GL.MAX_VERTEX_ATTRIBS);
		this._maxVaryingVectors = GL.getParameter(GL.MAX_VARYING_VECTORS);
		this._maxVertexUniformVectors = GL.getParameter(GL.MAX_VERTEX_UNIFORM_VECTORS);
		this._maxFragmentUniformVectors = GL.getParameter(GL.MAX_FRAGMENT_UNIFORM_VECTORS);

		this._maxRenderbufferSize = GL.getParameter(GL.MAX_RENDERBUFFER_SIZE);
		this._maxViewportDims = GL.getParameter(GL.MAX_VIEWPORT_DIMS);
		this._aliasedLineWidthRange = GL.getParameter(GL.ALIASED_LINE_WIDTH_RANGE);
		this._aliasedPointSizeRange = GL.getParameter(GL.ALIASED_POINT_SIZE_RANGE);

		this._vertexShaderPrecisionHighpFloat = GL.getShaderPrecisionFormat(GL.VERTEX_SHADER, GL.HIGH_FLOAT);
		this._vertexShaderPrecisionMediumpFloat = GL.getShaderPrecisionFormat(GL.VERTEX_SHADER, GL.MEDIUM_FLOAT);
		this._fragmentShaderPrecisionHighpFloat = GL.getShaderPrecisionFormat(GL.FRAGMENT_SHADER, GL.HIGH_FLOAT);
		this._fragmentShaderPrecisionMediumpFloat = GL.getShaderPrecisionFormat(GL.FRAGMENT_SHADER, GL.MEDIUM_FLOAT);

		return true;
	}

	public function new() {
	}

	/* ----------- Properties ----------- */



	inline function get_version():String {
		return this._version;
	}

	inline function get_vendor():String {
		return this._vendor;
	}

	inline function get_renderer():String {
		return this._renderer;
	}

	inline function get_shadingLanguageVersion():String {
		return this._shadingLanguageVersion;
	}

	inline function get_alphaBits():Int {
		return this._alphaBits;
	}

	inline function get_redBits():Int {
		return this._redBits;
	}

	inline function get_greenBits():Int {
		return this._greenBits;
	}

	inline function get_blueBits():Int {
		return this._blueBits;
	}

	inline function get_depthBits():Int {
		return this._depthBits;
	}

	inline function get_stencilBits():Int {
		return this._stencilBits;
	}

	inline function get_maxTextureImageUnits():Int {
		return this._maxTextureImageUnits;
	}

	inline function get_maxVertexTexturesImageUnits():Int {
		return this._maxVertexTexturesImageUnits;
	}

	inline function get_maxCombinedTextureImageUnits():Int {
		return this._maxCombinedTextureImageUnits;
	}

	inline function get_maxTextureSize():Int {
		return this._maxTextureSize;
	}

	inline function get_maxCubemapTextureSize():Int {
		return this._maxCubemapTextureSize;
	}

	inline function get_maxVertexAttribs():Int {
		return this._maxVertexAttribs;
	}

	inline function get_maxVaryingVectors():Int {
		return this._maxVaryingVectors;
	}

	inline function get_maxVertexUniformVectors():Int {
		return this._maxVertexUniformVectors;
	}

	inline function get_maxFragmentUniformVectors():Int {
		return this._maxFragmentUniformVectors;
	}

	inline function get_maxRenderbufferSize():Int {
		return this._maxRenderbufferSize;
	}

	inline function get_maxViewportDims():Array<Int> {
		return this._maxViewportDims;
	}

	inline function get_aliasedLineWidthRange():Array<Int> {
		return this._aliasedLineWidthRange;
	}

	inline function get_aliasedPointSizeRange():Array<Int> {
		return this._aliasedPointSizeRange;
	}

	inline function get_vertexShaderPrecisionHighpFloat():GLShaderPrecisionFormat {
		return this._vertexShaderPrecisionHighpFloat;
	}

	inline function get_vertexShaderPrecisionMediumpFloat():GLShaderPrecisionFormat {
		return this._vertexShaderPrecisionMediumpFloat;
	}

	inline function get_fragmentShaderPrecisionHighpFloat():GLShaderPrecisionFormat {
		return this._fragmentShaderPrecisionHighpFloat;
	}

	inline function get_fragmentShaderPrecisionMediumpFloat():GLShaderPrecisionFormat {
		return this._fragmentShaderPrecisionMediumpFloat;
	}


/* --------- Implementation --------- */

}
