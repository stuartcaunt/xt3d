package xt3d.utils.image;

import lime.app.Future;
import haxe.io.Bytes;
import haxe.io.Error;
import lime.net.HTTPRequest;
import lime.graphics.Image;
class ImageLoader {

	// properties

	// members
	private var _url:String;
	private var _successCbk:Image -> Void;
	private var _errorCbk:String -> Void;
	private var _progress:Float = 0.0;

	public static function create(url:String, successCbk:Image -> Void, errorCbk:String -> Void = null):ImageLoader {
		var object = new ImageLoader();

		if (object != null && !(object.init(url, successCbk, errorCbk))) {
			object = null;
		}

		return object;
	}

	public function init(url:String, successCbk:Image -> Void, errorCbk:String -> Void = null):Bool {
		this._url = url;
		this._successCbk = successCbk;
		this._errorCbk = errorCbk;

		var loader:HTTPRequest<Bytes> = new HTTPRequest<Bytes>();
		var future = loader.load(url);

		future.onComplete(this.onComplete);
		future.onError(this.onError);
		future.onProgress(this.onProgress);

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


	private function onComplete(data):Void {
		XT.Log("Got image");

		Image.loadFromBytes(data).then (function (image: Image) {
			if (image != null) {
				this._successCbk(image);
				return Future.withValue(image);
			} else {
				handleError("invalid response data");
				return Future.withValue(null);
			}
		});
	}

	private inline function onProgress(progress:Int, total:Int):Void {
		// Progress between 0 and 1 ?
		this._progress = progress / total;

		XT.Log("loading " + Math.round(this._progress * 100) + "%");
	}

	private inline function onError(error:String):Void {
		handleError("ioErrorHandler: " + error);
	}

	private inline function handleError(error:String) {
		var errorString:String = "Error loading \"" + this._url + "\" : " + error;
		if (this._errorCbk == null) {
			XT.Error(errorString);

		} else {
			this._errorCbk(errorString);
		}
	}
}
