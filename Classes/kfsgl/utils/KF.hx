package kfsgl.utils;

import haxe.Timer;

class KF  {

	public static inline var MAX_LIGHTS:String = "MAX_LIGHTS";
	public static inline var SHADER_PRECISION:String = "SHADER_PRECISION";
	public static inline var DEFAULT_FPS:String = "DEFAULT_FPS";


	private static var timer:Float = Timer.stamp();

	public static function Log(v:Dynamic, ?info:haxe.PosInfos):Void {
#if KF_DEBUG
		var ms = (Std.int)((Timer.stamp() - timer) * 1000) % 1000;
		haxe.Log.trace(DateTools.format(Date.now(), "%d/%m/%Y %H:%M:%S") + "." + ms + ": " + v, info);
#else
		// Do nothing
#end		
	}

	public static function Warn(v:Dynamic, ?info:haxe.PosInfos):Void {
		#if KF_DEBUG
		var ms = (Std.int)((Timer.stamp() - timer) * 1000) % 1000;
		haxe.Log.trace(DateTools.format(Date.now(), "%d/%m/%Y %H:%M:%S") + "." + ms + ": " + v, info);
#else
		// Do nothing
		#end
	}

	public static function Error(v:Dynamic, ?info:haxe.PosInfos):Void {
		#if KF_DEBUG
		var ms = (Std.int)((Timer.stamp() - timer) * 1000) % 1000;
		haxe.Log.trace(DateTools.format(Date.now(), "%d/%m/%Y %H:%M:%S") + "." + ms + ": " + v, info);
#else
		// Do nothing
		#end
	}


	public static function jsonToMap(jsonData:Dynamic):Map<String, String> {
		var result = new Map<String, String>();

		for (key in Reflect.fields(jsonData)) {
			var value = Reflect.getProperty(jsonData, key);
			result.set(key, value);
		}

		return result;
	}

	public static inline var RepeatForever:UInt = 0xFFFFFFFF;

}

