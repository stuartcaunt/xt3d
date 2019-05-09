package xt3d.gl;

import xt3d.utils.XT;
import xt3d.gl.GLCurrentContext.GL;


class GLExtensionManager {

	public static inline var TEXTURE_FLOAT_DISABLED:Int = 0;
	public static inline var TEXTURE_FLOAT_FULL:Int = 1 << 0;
	public static inline var TEXTURE_FLOAT_HALF:Int = 1 << 1;
	public static inline var TEXTURE_FLOAT_LINEAR:Int = 1 << 2;

	private static inline var instanced_arrays = "instanced_arrays";
	private static inline var blend_minmax = "blend_minmax";
	private static inline var color_buffer_half_float = "color_buffer_half_float";
	private static inline var disjoint_timer_query = "disjoint_timer_query";
	private static inline var frag_depth = "frag_depth";
	private static inline var sRGB = "sRGB";
	private static inline var shader_texture_lod = "shader_texture_lod";
	private static inline var texture_filter_anisotropic = "texture_filter_anisotropic";
	private static inline var element_index_uint = "element_index_uint";
	private static inline var standard_derivatives = "standard_derivatives";
	private static inline var texture_float = "texture_float";
	private static inline var texture_float_linear = "texture_float_linear";
	private static inline var texture_half_float = "texture_half_float";
	private static inline var texture_half_float_linear = "texture_half_float_linear";
	private static inline var vertex_array_object = "vertex_array_object";
	private static inline var color_buffer_float = "color_buffer_float";
	private static inline var compressed_texture_atc = "compressed_texture_atc";
	private static inline var compressed_texture_etc1 = "compressed_texture_etc1";
	private static inline var compressed_texture_pvrtc = "compressed_texture_pvrtc";
	private static inline var compressed_texture_s3tc = "compressed_texture_s3tc";
	private static inline var debug_renderer_info = "debug_renderer_info";
	private static inline var debug_shaders = "debug_shaders";
	private static inline var depth_texture = "depth_texture";
	private static inline var draw_buffers = "draw_buffers";
	private static inline var lose_context = "lose_context";

	// properties
	public var textureFloatState(get, null):Int;

	// members
	private var _allExtensions:Map<String, Dynamic> = new Map<String, Dynamic>();
	private var _textureFloatState:Int = 0;

	public static function create():GLExtensionManager {
		var object = new GLExtensionManager();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {
		var extensions = GL.getSupportedExtensions();
		for (extension in extensions) {
			//XT.Log(extension);
			this._allExtensions.set(extension, null);
		}

		return true;
	}

	public function new() {
	}

	/* ----------- Properties ----------- */

	function get_textureFloatState():Int {
		return this._textureFloatState;
	}

	/* --------- Implementation --------- */

	public function isAvailable(extensionName:String):Bool {
		for (fullExtensionName in this._allExtensions.keys()) {
			if (fullExtensionName.indexOf(extensionName) > -1) {
				return true;
			}
		}

		return false;
	}

	public function getFullExtensionName(extensionName:String):String {
		for (fullExtensionName in this._allExtensions.keys()) {
			if (fullExtensionName.indexOf(extensionName) > -1) {
				return fullExtensionName;
			}
		}

		return null;
	}

	public function enableExtension(extensionName:String):Bool {
		if (this.isAvailable(extensionName)) {
			var fullExtensionName = this.getFullExtensionName(extensionName);
			if (this._allExtensions.get(fullExtensionName) == null) {
				var extension = GL.getExtension(fullExtensionName);

				// gl.getExtension only returns something with webGL
				#if (js && html5 && !display)
				var extension = GL.getExtension(fullExtensionName);
				#elseif ((cpp || neko || nodejs) && lime_opengl && !macro)
				GL.getExtension(fullExtensionName);
				var extension = "ok";
				#else
				var extension = null;
				#end

				if (extension != null) {
					this._allExtensions.set(fullExtensionName, extension);
					XT.Log("Enabled GL Extension " + extensionName + " (" + fullExtensionName + ")");
					return true;

				} else {
					XT.Warn("Unable to activate GL Extension " + extensionName + " (" + fullExtensionName + ")");
				}
			}
		} else {
			XT.Warn("GL Extension " + extensionName + " does not exist for this device");
		}
		return false;
	}

	public function isEnabled(extensionName:String):Bool {
		var fullExtensionName = this.getFullExtensionName(extensionName);
		return (fullExtensionName != null) && (this._allExtensions.get(fullExtensionName) != null);
	}

	public function enableTextureFloat(linear:Bool = true):Int {
		if (this._textureFloatState == 0) {
			if (this.enableExtension(texture_float)) {
				this._textureFloatState = TEXTURE_FLOAT_FULL;

			} else if (this.enableExtension(texture_half_float)) {
				this._textureFloatState = TEXTURE_FLOAT_HALF;
			}
		}

		if (this._textureFloatState == TEXTURE_FLOAT_FULL && linear) {
			if (this.enableExtension(texture_float_linear)) {
				this._textureFloatState |= TEXTURE_FLOAT_LINEAR;
			}
		} else if (this._textureFloatState == TEXTURE_FLOAT_HALF && linear) {
			if (this.enableExtension(texture_half_float_linear)) {
				this._textureFloatState |= TEXTURE_FLOAT_LINEAR;
			}
		}

		return this._textureFloatState;
	}

}
