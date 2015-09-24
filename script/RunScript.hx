package;


import sys.FileSystem;

class RunScript {

	private static var TEST_DIR:String = "tests";
	private static var PROJECT_TEMPLATE_FILE:String = "project_tl.xml";

	public static function main() {

		var args = Sys.args();


		if (args.length >= 3) {
			if (args[0] == "test") {
				var target = args[1];
				var testName = args[2];
				var targetFramework = "lime";
				var limeArgs = [];

				for (i in 3 ... args.length) {
					if (args[i] == "-openfl") {
						targetFramework = "openfl";
					} else if (args[i].indexOf("-") == 0) {
						limeArgs.push(args[i]);
					}
				}

				var moduleName = null;
				if (args.length >= 4 && !(args[3].indexOf("-") == 0)) {
					moduleName = args[3];
				}

				var testDir:String = TEST_DIR + "/" + testName;

				// Test if directory exists
				if (!FileSystem.exists(testDir)) {
					trace("Error: test directory \"" + testDir + "\" does not exist");
					Sys.exit(1);
				}

				// See if we have a module name, otherwise find first haxe file
				if (moduleName == null) {
					var files = FileSystem.readDirectory(testDir);
					for (file in files) {
						var index = file.indexOf(".hx");
						if (moduleName == null && index > 1) {
							moduleName = file.substring(0, index);
							trace("Found module " + moduleName);
						}
					}
				} else {
					// Verify module exists
					if (!FileSystem.exists(testDir + "/" + moduleName + ".hx")) {
						trace("Error: module \"" + moduleName + "\" does not exist in \"" + testDir + "\"");
						Sys.exit(1);
					}
				}


				// See if we have a project template file in the test directory
				var projectTemplateFile = testName + "/" + PROJECT_TEMPLATE_FILE;
				if (FileSystem.exists(TEST_DIR + "/" + projectTemplateFile)) {
					trace("Using project template file in \"" + testDir + "\"");
				} else {

					// Verify we have a main project template file
					projectTemplateFile = PROJECT_TEMPLATE_FILE;
					if (!FileSystem.exists(TEST_DIR + "/" + projectTemplateFile)) {
						trace("Error: could not find project template file in test directory \"" + TEST_DIR + "\"");
						Sys.exit(1);
					}
				}

				// Go to test directory
				trace("-> cd " + TEST_DIR);
				Sys.setCwd(TEST_DIR);

				// Convert project template to include test and module names
				trace("Generating " + TEST_DIR + "/project.xml");
				Sys.command("sh", ["-c", "sed -e s/##MODULE_NAME##/" + moduleName + "/g " +
					"-e s/##TEST_NAME##/" + testName + "/g " +
					"-e s/##TARGET_FRAMEWORK##/" + targetFramework + "/g "
					+ projectTemplateFile + " > project.xml"]);

				// build and run for the specified the target
				var allArgs = ["test", target];
				allArgs = allArgs.concat(limeArgs);
				trace("-> lime " + allArgs.join(" "));
				Sys.command ("lime", allArgs);

				trace("Test ended");
			}


		} else {
			trace("usage: xt3d test <target> <test_name> [<module_name>] [-openfl]");
			Sys.exit(1);
		}

		Sys.exit (0);
	}
}