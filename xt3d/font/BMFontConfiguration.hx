package xt3d.font;

import haxe.io.Path;
import lime.math.Rectangle;
import xt3d.utils.errors.XTException;
import xt3d.utils.XT;
import lime.Assets;

typedef BMFontCharacterDefinition = {
	var charId:Int;
	var rect:Rectangle;
	var xOffset:Int;
	var yOffset:Int;
	var xAdvance:Int;
	var letter:String;
};

typedef BMFontKerningDefinition = {
	var id:Int; // key for the hash. 16-bit for 1st element, 16-bit for 2nd element
	var first:Int;
	var second:Int;
	var amount:Int;
};

class BMFontConfiguration {

	// properties
	public var lineHeight(get, null):Int;

	public var imageFileName(get, null):String;

	// members
	private var _fntFile:String;
	private var _face:String;
	private var _size:Int;
	private var _bold:Bool;
	private var _italic:Bool;
	private var _charset:String;
	private var _unicode:Bool;
	private var _stretchH:Int;
	private var _smooth:Bool;
	private var _aa:Bool;
	private var _padding:Array<Int> = new Array<Int>();
	private var _spacing:Array<Int> = new Array<Int>();

	private var _lineHeight:Int;
	private var _base:Int;
	private var _scaleW:Int;
	private var _scaleH:Int;
	private var _pages:Int;
	private var _packed:Bool;

	private var _imageFileName:String;

	private var _characters:Map<Int, BMFontCharacterDefinition> = new Map<Int, BMFontCharacterDefinition>();
	private var _kernings:Map<Int, BMFontKerningDefinition> = new Map<Int, BMFontKerningDefinition>();

	private static var _fntConfigurationStore:Map<String, BMFontConfiguration> = new Map<String, BMFontConfiguration>();

	public static function createFromFNTFile(fntFileName:String):BMFontConfiguration {
		var object:BMFontConfiguration = null;

		// Get fnt configuration from a store if it exists rather than recreate each time
		if (_fntConfigurationStore.exists(fntFileName)) {
			object = _fntConfigurationStore.get(fntFileName);

		} else {

			object = new BMFontConfiguration();

			if (object != null && !(object.initFromFNTFile(fntFileName))) {
				object = null;
				
			} else {
				_fntConfigurationStore.set(fntFileName, object);
			}
		}

		return object;
	}

	public function initFromFNTFile(fntFileName:String):Bool {
		this._fntFile = fntFileName;

		// Get asset / throw exception
		var fntFile = Assets.getText(fntFileName);

		if (fntFile == null) {
			throw new XTException("NoSuchFNTFile", "Could not find FNT file \"" + fntFileName + "\" in assets");
		}

		// Parse file data
		this.parseFNTFile(fntFile);

		return true;
	}


	public function new() {

	}


	/* ----------- Properties ----------- */

	inline function get_imageFileName():String {
		return this._imageFileName;
	}

	inline function get_lineHeight():Int {
		return this._lineHeight;
	}


	/* --------- Implementation --------- */

	public function getCharacterDefintionWithCharCode(charCode:Int):BMFontCharacterDefinition {
		return this._characters.get(charCode);
	}

	public function getKerningAmountForFirstAndSecond(first:Int, second:Int):Int {
		var kerningAmount:Int = 0;
		var key = ((first & 0xffff) << 16) | (second & 0xffff);

		var kerningDefinition = this._kernings.get(key);
		if (kerningDefinition != null) {
			kerningAmount = kerningDefinition.amount;
		}

		return kerningAmount;
	}

	private function parseFNTFile(fntFile):Void {

		var lines:Array<String> = fntFile.split("\n");
		for (line in lines) {
			line = StringTools.trim(line);

			if (line.length > 0) {
				var key = line.substr(0, line.indexOf(" "));
				var valueString = line.substr(key.length + 1);

				var config = new Map<String, String>();
				var valueDatas:Array<String> = valueString.split(" ");
				for (valueData in valueDatas) {
					var configKey = valueData.substr(0, valueData.indexOf("="));
					var configValue = valueData.substr(configKey.length + 1);
					config.set(configKey, configValue);
				}

				if (key == "info") {
					this.parseInfo(config);

				} else if (key == "common") {
					this.parseCommon(config);

				} else if (key == "page") {
					this.parseImageFileInfo(config);

				} else if (key == "chars") {
					// ignore

				} else if (key == "char") {
					this.parseCharacterDefinition(config);

				} else if (key == "kernings") {
					// ignore

				} else if (key == "kerning") {
					this.parseKerningDefinition(config);
				}
			}
		}
	}

	private function parseInfo(config:Map<String, String>):Void {
		this._face = StringTools.replace(config.get("face"), "\"", "");
		this._size = Std.parseInt(config.get("size"));
		this._bold = Std.parseInt(config.get("bold")) == 1;
		this._italic = Std.parseInt(config.get("italic")) == 1;
		this._charset = StringTools.replace(config.get("charset"), "\"", "");
		this._unicode = Std.parseInt(config.get("unicode")) == 1;
		this._stretchH = Std.parseInt(config.get("stretchH"));
		this._smooth = Std.parseInt(config.get("smooth")) == 1;
		this._aa = Std.parseInt(config.get("aa")) == 1;
		var paddingStrings:Array<String> = config.get("padding").split(",");
		for (paddingString in paddingStrings) {
			this._padding.push(Std.parseInt(paddingString));
		}
		var spacingStrings:Array<String> = config.get("spacing").split(",");
		for (spacingString in spacingStrings) {
			this._spacing.push(Std.parseInt(spacingString));
		}
	}

	private function parseCommon(config:Map<String, String>):Void {
		this._lineHeight = Std.parseInt(config.get("lineHeight"));
		this._base = Std.parseInt(config.get("base"));
		this._scaleW = Std.parseInt(config.get("scaleW"));
		this._scaleH = Std.parseInt(config.get("scaleH"));
		this._pages = Std.parseInt(config.get("pages"));
		this._packed = Std.parseInt(config.get("packed")) == 1;
	}

	private function parseImageFileInfo(config:Map<String, String>):Void {
		var path:Path = new Path(this._fntFile);
		var dir = path.dir;

		var imgFile = StringTools.replace(config.get("file"), "\"", "");
		this._imageFileName = dir + "/" + imgFile;
	}

	private function parseCharacterDefinition(config:Map<String, String>):Void {
		var id = Std.parseInt(config.get("id"));
		var x = Std.parseInt(config.get("x"));
		var y = Std.parseInt(config.get("y"));
		var width = Std.parseInt(config.get("width"));
		var height = Std.parseInt(config.get("height"));
		var xOffset = Std.parseInt(config.get("xoffset"));
		var yOffset = Std.parseInt(config.get("yoffset"));
		var xAdvance = Std.parseInt(config.get("xadvance"));
		var letter = StringTools.replace(config.get("letter"), "\"", "");

		var characterDefinition:BMFontCharacterDefinition = {
			charId:id,
			rect:new Rectangle(x, y, width, height),
			xOffset: xOffset,
			yOffset: yOffset,
			xAdvance: xAdvance,
			letter: letter
		};

		this._characters.set(id, characterDefinition);
	}

	private function parseKerningDefinition(config:Map<String, String>):Void {
		var first = Std.parseInt(config.get("first"));
		var second = Std.parseInt(config.get("second"));
		var amount = Std.parseInt(config.get("amount"));

		var key = ((first & 0xffff) << 16) | (second & 0xffff);
		var kerningDefinition:BMFontKerningDefinition = {
			id: key,
			first: first,
			second: second,
			amount: amount
		};
		this._kernings.set(key, kerningDefinition);
	}

}
