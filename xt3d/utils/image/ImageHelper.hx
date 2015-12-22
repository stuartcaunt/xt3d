package xt3d.utils.image;

import lime.utils.Float32Array;
import xt3d.utils.color.Color;
import lime.utils.UInt8Array;
import lime.graphics.ImageBuffer;
import lime.graphics.Image;

class ImageHelper {

	public static function imageFromColor(width:Int, height:Int, color:Color):Image {

		var fillColor = color.intValue();

#if sys
		var buffer = new ImageBuffer(new UInt8Array(width * height * 4), width, height);

		var image = new Image(buffer, 0, 0, width, height);

		if (fillColor != 0) {
			image.fillRect(image.rect, fillColor);
		}
#else
		var image = new Image(null, 0, 0, width, height, fillColor);
#end

		return image;
	}


	public static function imageFromFloat32Array(width:Int, height:Int, float32Array:Float32Array):Image {

		var buffer = new ImageBuffer(new UInt8Array(float32Array.buffer), width, height);
		var image = new Image(buffer, 0, 0, width, height);

		return image;
	}
}
