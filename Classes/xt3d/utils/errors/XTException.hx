package xt3d.utils.errors;

class XTException extends XTError {

	public function new(exceptionName:String = "XTException", message:String = null, id:Int = 0, ?info:haxe.PosInfos) {

		message = (message != null) ? message : "";
		message = "[" + exceptionName + " from " + info.className + "::" + info.methodName + " line " + info.lineNumber + "]\n\t" + message;

		super(message, id);
	}
	

}