package xt3d.utils.errors;

class KFAbstractMethodError extends KFException {

	public function new() {
		super("AbstractMethodError", "An abstract method has been called - the implementing class is incomplete");
	}

}
