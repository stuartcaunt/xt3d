package xt3d.utils.string;

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

	public static function hasSuffix(input:String, suffix:String):Bool {
		suffix = "." + suffix;
		var lastIndex = input.lastIndexOf(suffix);
		if (lastIndex > 0) {
			// Verify that it is the last part of the string
			if (lastIndex + suffix.length == input.length) {
				return true;
			}
		}
		return false;
	}

	public static function fileFromPath(path:String):String {
		// TODO : this is unix based
		var lastIndex = path.lastIndexOf("/");
		if (lastIndex > 0 && lastIndex != path.length - 1) {
			return path.substring(lastIndex + 1);
		}
		return path;
	}

	public static function fileWithoutPathAndSuffix(path:String):String {
		var filename = fileFromPath(path);

		var lastIndex = filename.lastIndexOf(".");
		if (lastIndex > 0) {
			return filename.substring(0, lastIndex);
		}
		return filename;
	}



}
