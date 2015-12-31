package xt3d.view;

class VerticalConstraint extends Constraint {

	public static inline var CONSTRAINT_TYPE_BOTTOM_AND_HEIGHT:Int = 0;
	public static inline var CONSTRAINT_TYPE_TOP_AND_HEIGHT:Int = 1;
	public static inline var CONSTRAINT_TYPE_BOTTOM_AND_TOP:Int = 2;

	// properties

	// members


	public static function create(constraintType:Int = CONSTRAINT_TYPE_BOTTOM_AND_HEIGHT, value1:String = "0pt", value2:String = "100%"):VerticalConstraint {
		var object = new VerticalConstraint();

		if (object != null && !(object.init(constraintType, value1, value2))) {
			object = null;
		}

		return object;
	}

	public function init(constraintType:Int = CONSTRAINT_TYPE_BOTTOM_AND_HEIGHT, value1:String = "0pt", value2:String = "100%"):Bool {
		var isOk;
		if ((isOk = super.initConstraint(constraintType, value1, value2))) {

		}
		return isOk;
	}




	/* ----------- Properties ----------- */


	/* --------- Implementation --------- */

	public function getTopInPoints(fullLengthInPoints:Int, contentScaleFactor:Float):Int {
		return this.getOriginInPoints(fullLengthInPoints, contentScaleFactor);
	}

	public function getHeightInPoints(fullLengthInPoints:Int, contentScaleFactor:Float):Int {
		return this.getLengthInPoints(fullLengthInPoints, contentScaleFactor);
	}
}