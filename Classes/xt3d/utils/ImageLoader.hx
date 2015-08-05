package xt3d.utils;

import openfl.errors.Error;
import openfl.display.Bitmap;
import openfl.events.IOErrorEvent;
import openfl.events.HTTPStatusEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.Event;
import openfl.display.Loader;
import openfl.net.URLRequest;
import openfl.display.BitmapData;

class ImageLoader {

	// properties

	// members
	private var _url:String;
	private var _successCbk:BitmapData -> Void;
	private var _errorCbk:String -> Void;
	private var _loading:Bool = false;
	private var _progress:Float = 0.0;
	private var _status:Int;

	public static function create(url:String, successCbk:BitmapData -> Void, errorCbk:String -> Void = null):ImageLoader {
		var object = new ImageLoader();

		if (object != null && !(object.init(url, successCbk, errorCbk))) {
			object = null;
		}

		return object;
	}

	public function init(url:String, successCbk:BitmapData -> Void, errorCbk:String -> Void = null):Bool {
		this._url = url;
		this._successCbk = successCbk;
		this._errorCbk = errorCbk;

		var request:URLRequest = new URLRequest(url);
		var loader:Loader = new Loader();

		loader.load(request);

		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComplete);
		loader.contentLoaderInfo.addEventListener(Event.OPEN, this.onOpen);
		loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSecurity);
		loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onHTTPStatus);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);


		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */


	private function onComplete(event:Event):Void {

		// Loading process is now complete
		this._loading = false;
		if (this._status == 200 || event.target.content != null) {  // 200 is a successful HTTP status

			XT.Log("Got image");
			try {
				var bitmap:Bitmap = event.target.content;
				var bitmapData = bitmap.bitmapData;

				// Call callback with bitmap data
				this._successCbk(bitmapData);

			} catch (exception:Error) {
				handleError("invalid response data: " + exception);
			}
		} else {
			handleError("bad response status: " + this._status);
		}
	}


	private inline function onOpen(event:Event):Void {
		this._loading = true;
	}

	private inline function onProgress(event:ProgressEvent):Void {
		// Progress between 0 and 1
		this._progress = event.bytesLoaded / event.bytesTotal;

		XT.Log("loading " + Math.round(this._progress * 100) + "%");
	}

	private inline function onSecurity(event:SecurityErrorEvent):Void {
		handleError("securityErrorHandler: " + event);
		this._loading = false;
	}

	private inline function onHTTPStatus(event:HTTPStatusEvent):Void {
		this._status = event.status;
	}

	private inline function onIOError(event:IOErrorEvent):Void {
		handleError("ioErrorHandler: " + event);
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
