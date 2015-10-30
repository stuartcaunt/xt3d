package xt3d.utils.image;

import sys.FileSystem;
import lime.system.System;
#if !js
import sys.io.File;
import sys.io.FileOutput;
#end
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.graphics.opengl.GL;
import lime.utils.UInt8Array;
import xt3d.core.Director;
import xt3d.textures.RenderTexture;

class ScreenCapture {

	// properties

	// members
	private var _renderTexture:RenderTexture = null;
	private var _pixels:UInt8Array = null;
	private var _flippedPixels:UInt8Array = null;

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
#if js
		XT.Warn("ScreenCapture.save is not available for the HTML5 target");
#else
		var width = this._renderTexture.contentSize.width;
		var height = this._renderTexture.contentSize.height;
		var nPixels = width * height * 4;
		if (this._pixels == null || this._pixels.length != nPixels) {
			this._pixels = new UInt8Array(nPixels);
			this._flippedPixels = new UInt8Array(nPixels);
		}

		// Read pixels from texture
		GL.readPixels(0, 0, width, height, GL.RGBA, GL.UNSIGNED_BYTE, this._pixels);

		// Flip vertically
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
