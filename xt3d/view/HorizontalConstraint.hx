package xt3d.view;

class HorizontalConstraint extends Constraint {

	public static inline var CONSTRAINT_TYPE_LEFT_AND_WIDTH:Int = 0;
	public static inline var CONSTRAINT_TYPE_RIGHT_AND_WIDTH:Int = 1;
	public static inline var CONSTRAINT_TYPE_LEFT_AND_RIGHT:Int = 2;

	// properties

	// members


	public static function create(constraintType:Int = CONSTRAINT_TYPE_LEFT_AND_WIDTH, value1:String = "0pt", value2:String = "100%"):HorizontalConstraint {
		var object = new HorizontalConstraint();

		if (object != null && !(object.init(constraintType, value1, value2))) {
			object = null;
		}

		return object;
	}

	public function init(constraintType:Int = CONSTRAINT_TYPE_LEFT_AND_WIDTH, value1:String = "0pt", value2:String = "100%"):Bool {
		var isOk;
		if ((isOk = super.initConstraint(constraintType, value1, value2))) {

		}
		return isOk;
	}




	/* ----------- Properties ----------- */

	/* --------- Implementation --------- */

	public function getLeftInPoints(fullLengthInPoints:Int, contentScaleFactor:Float):Int {
		return this.getOriginInPoints(fullLengthInPoints, contentScaleFactor);
	}

	public function getWidthInPoints(fullLengthInPoints:Int, contentScaleFactor:Float):Int {
		return this.getLengthInPoints(fullLengthInPoints, contentScaleFactor);
	}
}