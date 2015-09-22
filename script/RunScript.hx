package;


import sys.FileSystem;

class RunScript {

	private static var TEST_DIR:String = "Test";
	private static var PROJECT_TEMPLATE_FILE:String = "project_tl.xml";

	public static function main() {

		var args = Sys.args();

		if (args.length >= 3) {
			if (args[0] == "test") {
				var target = args[1];
				var testName = args[2];

				var moduleName = null;
				if (args.length == 4) {
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
				}

				var runDir = TEST_DIR;

				// See if we have a project template file in the test directory
				var projectTemplateFile = testDir + "/" + PROJECT_TEMPLATE_FILE;
				if (FileSystem.exists(projectTemplateFile)) {
					runDir = testDir;
					trace("Using project template file in \"" + testDir + "\"");
				} else {

					// Verify we have a main project template file
					var projectTemplateFile = TEST_DIR + "/" + PROJECT_TEMPLATE_FILE;
					if (!FileSystem.exists(projectTemplateFile)) {
						trace("Error: could not find project template file in test directory \"" + TEST_DIR + "\"");
						Sys.exit(1);
					}
				}

				// Go to test directory
				trace("-> cd " + runDir);
				Sys.setCwd(runDir);


				// Convert project template to include test and module names
				trace("Generating project.xml");
				Sys.command("sh", ["-c", "sed -e s/##MODULE_NAME##/" + moduleName + "/g -e s/##TEST_NAME##/" + testName + "/g " + PROJECT_TEMPLATE_FILE + " > project.xml"]);

				// build and run for the specified the target
				trace("-> lime test " + target);
				Sys.command ("lime", ["test", target]);

				trace("finished");
			}


		} else {
			trace("usage: xt3d test <target> <test_name> <module_name>");
			Sys.exit(1);
		}

		Sys.exit (0);
	}
}