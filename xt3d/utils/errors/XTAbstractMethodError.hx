package xt3d.utils.errors;

class XTAbstractMethodError extends XTException {

	public function new() {
		super("AbstractMethodError", "An abstract method has been called - the implementing class is incomplete");
	}

}
