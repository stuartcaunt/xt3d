package;


class RunScript {

	private static var TEST_DIR:String = "Test";

	public static function main() {

		var args = Sys.args();

		if (args.length == 3) {
			if (args[0] == "test") {
				var target = args[1];
				var testName = args[2];

				try {

					var testDir:String = TEST_DIR + "/" + testName;
					trace("-> cd " + testDir);
					Sys.setCwd(testDir);

					trace("-> lime test " + target);
					Sys.command ("lime", ["test", target]);

				} catch (e:Dynamic) {

					trace ("Cannot set current working directory to \"" + TEST_DIR + "\"");

				}
			}


		} else {
			trace("usage: xt3d test <target> <test_name>");
			Sys.exit(1);
		}

		Sys.exit (0);
	}
}