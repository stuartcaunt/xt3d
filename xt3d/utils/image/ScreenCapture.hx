package xt3d.utils.image;

import lime.system.System;
#if !js
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
#end
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import xt3d.gl.GLCurrentContext.GL;
import lime.utils.UInt8Array;
import xt3d.core.Director;
import xt3d.textures.RenderTexture;

class ScreenCapture {

	// properties

	// members
	private var _renderTexture:RenderTexture = null;
	private var _pixels:UInt8Array = null;
	private var _flippedPixels:UInt8Array = null;
#if js
	private var _canvas:Dynamic;
	private var _context:Dynamic;
	private var _contextPixels:Dynamic;
#end

	public static function create():ScreenCapture {
		var object = new ScreenCapture();

		if (object != null && !(object.init())) {
			object = null;
		}

		return object;
	}

	public function init():Bool {

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function captureScreen():Void {
		var director = Director.current;

		// Set up render texture
		var displaySize = director.displaySize;
		if (this._renderTexture == null || this._renderTexture.contentSize.width != displaySize.width || this._renderTexture.contentSize.height != displaySize.height) {
			this._renderTexture = RenderTexture.create(displaySize);
		}

		// Render everything in the director
		director.render(director.backgroundColor, this._renderTexture);
	}

	public function save(path:String = null, format:String = "png", quality:Int = 90):Void {
		var width = this._renderTexture.contentSize.width;
		var height = this._renderTexture.contentSize.height;
		var nPixels = width * height * 4;
		if (this._pixels == null || this._pixels.length != nPixels) {
			this._pixels = new UInt8Array(nPixels);

#if js
			// Create javascript canvas and 2d context with image data
			this._canvas = untyped __js__("document.createElement('canvas');");
			untyped __js__("this._canvas.width = {0};", width);
			untyped __js__("this._canvas.height = {0};", height);
			this._context = untyped __js__("this._canvas.getContext('2d');");
			this._contextPixels = untyped __js__("this._context.createImageData({0}, {1});", width, height);

#else
			// Additional data to invert texture
			this._flippedPixels = new UInt8Array(nPixels);
#end
		}

		// Read pixels from texture
		GL.readPixels(0, 0, width, height, GL.RGBA, GL.UNSIGNED_BYTE, this._pixels);

#if js
		// Flip pixels vertically and save in context image data
		for (i in 0 ... height) {
			var src = i * width * 4;
			var dest = (height - 1 - i) * width * 4;
			this._contextPixels.data.set(this._pixels.subarray(src, src + (width * 4)), dest);
		}

		// Put data into context
		untyped __js__("this._context.putImageData(this._contextPixels, 0, 0);");

		// Create a data uri from the image data
		var uri = untyped __js__("this._canvas.toDataURL();");

		// Open a new tab with the image
		//untyped __js__("window.open({0}, 'ScreenCapture');", uri);

		// Filename
		var filename = DateTools.format(Date.now(), "xTalk3d Screen Capture %Y-%m-%d at %H.%M.%S.png");

		// Force a download of the image
		var link = untyped __js__("document.createElement('a');");
		untyped __js__("link.download = {0};", filename);
		untyped __js__("link.href = {0};", uri);
		untyped __js__("link.click();");
#else

		// Flip pixels vertically
		for (i in 0 ... height) {
			var src = i * width * 4;
			var dest = (height - 1 - i) * width * 4;
			this._flippedPixels.set(this._pixels.subarray(src, src + (width * 4)), null, dest);
		}

		// Convert to byte data
		var imageBuffer = new ImageBuffer(this._flippedPixels, width, height);
		var image = new Image(imageBuffer, 0, 0, width, height);

		// Convert to encoded image data
		var imageByteData = image.encode(format, quality);

		// Get file path
		if (path == null) {
			path = DateTools.format(Date.now(), "xTalk3d Screen Capture %Y-%m-%d at %H.%M.%S");
		}
		var desktopDirectory = System.desktopDirectory;
		var fullPath = desktopDirectory + "/" + path;

		// Save the image
		var counter:Int = 0;
		var verifiedPath = fullPath + "." + format;
		while (FileSystem.exists(verifiedPath)) {
			counter++;
			verifiedPath = fullPath + " (" + counter + ")." + format;
		}
		File.saveBytes(verifiedPath, imageByteData);

		XT.Log("ScreepCapture saved to " + verifiedPath);
#end
	}

}
