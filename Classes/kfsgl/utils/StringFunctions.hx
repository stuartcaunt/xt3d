package kfsgl.utils;

class StringFunctions {

	public static function replace_all(input:String, find:String, replace:String):String {
		if (input.indexOf(find) != -1) {
			var parts = input.split(find);
			var output = "";
			for (i in 0 ... parts.length - 1) {
				output += parts[i] + replace;
			}
			output += parts[parts.length - 1];

			return output;

		} else {
			return input;
		}
	}

}
