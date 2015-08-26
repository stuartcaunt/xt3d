package xt3d.utils;

import haxe.io.Error;
import lime.net.URLLoaderDataFormat;
import lime.net.URLLoader;
import lime.net.URLRequest;
import lime.graphics.Image;
class ImageLoader {

	// properties

	// members
	private var _url:String;
	private var _successCbk:Image -> Void;
	private var _errorCbk:String -> Void;
	private var _loading:Bool = false;
	private var _progress:Float = 0.0;
	private var _status:Int;

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

		var request:URLRequest = new URLRequest(url);
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;

		loader.onComplete.add(this.onComplete);
		loader.onOpen.add(this.onOpen);
		loader.onProgress.add(this.onProgress);
		loader.onHTTPStatus.add(this.onHTTPStatus);
		loader.onSecurityError.add(this.onSecurity);
		loader.onIOError.add(this.onIOError);

		loader.load(request);


		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


	private function onComplete(loader:URLLoader):Void {

		// Loading process is now complete
		this._loading = false;
		if (this._status == 200 || loader.data != null) {  // 200 is a successful HTTP status

			XT.Log("Got image");

			try {
				Image.fromBytes(loader.data, function (image) {
					// Call callback with bitmap data
					this._successCbk(image);
				});

			} catch (error:Dynamic) {
				handleError("invalid response data: " + error);
			}
		} else {
			handleError("bad response status: " + this._status);
		}
	}


	private inline function onOpen(loader:URLLoader):Void {
		this._loading = true;
	}

	private inline function onProgress(loader:URLLoader, bytesLoaded:Int, bytesTotal:Int):Void {
		// Progress between 0 and 1
		this._progress = (1.0 * bytesLoaded) / bytesTotal;

		XT.Log("loading " + Math.round(this._progress * 100) + "%");
	}

	private inline function onSecurity(loader:URLLoader, error:String):Void {
		handleError("securityErrorHandler: " + error);
		this._loading = false;
	}

	private inline function onHTTPStatus(loader:URLLoader, status:Int):Void {
		this._status = status;
	}

	private inline function onIOError(loader:URLLoader, error:String):Void {
		handleError("ioErrorHandler: " + error);
		this._loading = false;
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
