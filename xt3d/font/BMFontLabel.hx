package xt3d.font;

import xt3d.gl.vertexdata.IndexData;
import xt3d.utils.XT;
import xt3d.utils.geometry.Size;
import xt3d.math.Vector2;
import xt3d.gl.vertexdata.InterleavedVertexData;
import xt3d.textures.Texture2D;
import lime.math.Rectangle;
import xt3d.utils.errors.XTException;
import xt3d.geometry.Geometry;
import xt3d.material.TextureMaterial;
import xt3d.node.RenderObject;
import xt3d.textures.TextureOptions;

typedef BMFontLabelCharacter = {
	var charCode:Int;
	var posRect:Rectangle;
	var uvRect:Rectangle;
	var line:Int;
	var xOffset:Int;
	var yOffset:Int;
	var stringPosition:Int;
};

typedef BMFontLabelLine = {
	var length:Int;
	var chars:Array<BMFontLabelCharacter>;
};

enum TextAlignment {
	TextAlignmentLeft;
	TextAlignmentRight;
	TextAlignmentCenter;
}

class BMFontLabel extends RenderObject {

	// properties
	public var contentSize(get, null):Size<Int>;

	// members
	private var _text:String;
	private var _fntFileName:String;
	private var _bmFontConfiguration:BMFontConfiguration;
	private var _texture:Texture2D;
	private var _vertexData:InterleavedVertexData;
	private var _indexData:IndexData;
	private var _alignment:TextAlignment = TextAlignment.TextAlignmentLeft;

	private var _lines:Array<BMFontLabelLine> = new Array<BMFontLabelLine>();
	private var _contentSize:Size<Int> = Size.createIntSize(0, 0);

	public static function createWithText(text:String, fntFileName:String):BMFontLabel {
		var object = new BMFontLabel();

		if (object != null && !(object.initWithText(text, fntFileName))) {
			object = null;
		}

		return object;
	}

	public function initWithText(text:String, fntFileName:String):Bool {
		var retval;
		if ((retval = super.initRenderObject(null, null))) {
			this._text = text;
			this._fntFileName = fntFileName;

			this._bmFontConfiguration = BMFontConfiguration.createFromFNTFile(fntFileName);

			// Create texture
			var textureFileName = this._bmFontConfiguration.imageFileName;
			this._texture = Texture2D.createFromImageAsset(textureFileName, TextureOptions.createLINEAR_CLAMP_POT_MIPMAP_LINEAR());
			var textureMaterial = TextureMaterial.createWithTexture(this._texture, { alphaCullingEnabled: true} );
			textureMaterial.transparent = true;
			textureMaterial.alphaCullingValue = 0.1;
			this._material = textureMaterial;

			// Create the geometry
			this.createGeometry();

			// update the text
			this.updateText();
		}

		return retval;
	}


	public function new() {
		super();
	}


	/* ----------- Properties ----------- */

	function get_contentSize():Size<Int> {
		return this._contentSize;
	}

	/* --------- Implementation --------- */

	public function setText(text:String):Void {
		this._text = text;

		this.updateText();
	}

	public function setAlignment(alignment:TextAlignment):Void {
		this._alignment = alignment;

		// Update character positions
		this.updateCharacterPositions();

		// Update the geometry
		this.updateGeometry();
	}

	private function updateText():Void {
		// update the character data
		this.updateCharacterData();

		// Update the geometry
		this.updateGeometry();
	}

	private function createGeometry():Void {
		// Create geometry
		this._geometry = Geometry.create();

		// Create vertex data
		var stride = 8;
		this._vertexData = this._geometry.createInterleavedVertexData(stride, null);
		this._vertexData.setAttributeOffset(Geometry.bufferNames.position, 0);
		this._vertexData.setAttributeOffset(Geometry.bufferNames.normal, 3);
		this._vertexData.setAttributeOffset(Geometry.bufferNames.uv, 6);

		this._indexData = this._geometry.createIndexData();
	}

	private function updateGeometry():Void {

		var nChars = 0;
		var vertexOffset;
		var indexOffset;
		for (line in this._lines) {
			for (char in line.chars) {
				vertexOffset = nChars * 4;
				indexOffset = nChars * 6;

				// Create or reuse vertex data
				this.addQuad(vertexOffset, indexOffset, char.posRect, char.uvRect);

				nChars++;
			}
		}

		// Remove unused vertex values
		var vertexCount = nChars * 4 * this._vertexData.stride;
		if (this._vertexData.getLength() > vertexCount) {
			var rawVertexArray = this._vertexData.array;
			rawVertexArray.splice(vertexCount, rawVertexArray.length - vertexCount);
			this._vertexData.isDirty = true;
		}

		// Remove unused index values
		var indexCount = nChars * 6;
		if (this._indexData.getLength() > indexCount) {
			var rawIndexArray = this._indexData.array;
			rawIndexArray.splice(indexCount, rawIndexArray.length - indexCount);
			this._indexData.isDirty = true;
		}
	}

	private function addQuad(vertexOffset:Int, indexOffset:Int, posRect:Rectangle, uvRect:Rectangle):Void {
		var x0 = posRect.x;
		var y0 = posRect.y;
		var x1 = posRect.x + posRect.width;
		var y1 = posRect.y + posRect.height;

		var u0 = uvRect.x;
		var v0 = uvRect.y + uvRect.height;
		var u1 = uvRect.x + uvRect.width;
		var v1 = uvRect.y;

		var vertices = [
			[x0, y0, u0, v0],
			[x1, y0, u1, v0],
			[x0, y1, u0, v1],
			[x1, y1, u1, v1]
		];

		var stride = this._vertexData.stride;

		// Modify existing or create vertex data
		for (i in 0 ... 4) {
			var vertex = vertices[i];
			var vertexIndex = (vertexOffset + i) * stride;

			this._vertexData.set(vertexIndex + 0, vertex[0] * 1.0);
			this._vertexData.set(vertexIndex + 1, vertex[1] * 1.0);
			this._vertexData.set(vertexIndex + 2, 0.0);
			this._vertexData.set(vertexIndex + 3, 0.0);
			this._vertexData.set(vertexIndex + 4, 0.0);
			this._vertexData.set(vertexIndex + 5, 1.0);
			this._vertexData.set(vertexIndex + 6, vertex[2]);
			this._vertexData.set(vertexIndex + 7, vertex[3]);
		}

		if (this._indexData.length < indexOffset + 6) {
			// Create new indices
			var first = vertexOffset;
			var second = first + 1;
			var third = first + 2;
			var fourth = first + 3;

			this._indexData.push(first);
			this._indexData.push(second);
			this._indexData.push(third);

			this._indexData.push(third);
			this._indexData.push(second);
			this._indexData.push(fourth);
		}

	}

	private function updateCharacterData():Void {
		var nextFontPositionX:Int = 0;
		var nextFontPositionY:Int = 0;

		var kerningAmount:Int = 0;
		var longestLine:Int = 0;
		var quantityOfLines:Int = 1;
		var previousCharCode = -1;
		var lineNumber = 0;

		// Initialise lines
		this._lines = [];

		var stringLen = this._text.length;
		if (stringLen == 0) {
			return;
		}

		for (i in 0 ... stringLen) {
			var char = this._text.charAt(i);
			if (char == '\n') {
				quantityOfLines++;
			}
		}

		// origin of geometry is bottom left
		var totalHeight = this._bmFontConfiguration.lineHeight * quantityOfLines;
		nextFontPositionY = -(this._bmFontConfiguration.lineHeight - this._bmFontConfiguration.lineHeight * quantityOfLines);

		// Create new bm Font Label Line
		var currentLine:BMFontLabelLine = null;

		for (i in 0 ... stringLen) {
			var char = this._text.charAt(i);
			var charCode = this._text.charCodeAt(i);

			// Change lines on newline character
			if (char == '\n') {
				nextFontPositionX = 0;
				nextFontPositionY -= this._bmFontConfiguration.lineHeight;
				lineNumber++;
				currentLine = null;

				continue;
			}

			if (currentLine == null) {
				currentLine = {
					length:0,
					chars: new Array<BMFontLabelCharacter>()
				};
				this._lines.push(currentLine);
			}

			// get character definition from configuration
			var fontDef = this._bmFontConfiguration.getCharacterDefintionWithCharCode(charCode);
			if (fontDef == null) {
				throw new XTException("BMFontCharacterNotSupported", "The character \"" + char + "\" does not exist in the bitmap font set " + this._fntFileName);
			}

			kerningAmount = this._bmFontConfiguration.getKerningAmountForFirstAndSecond(previousCharCode, charCode);
			var rect:Rectangle = fontDef.rect;

			var xOffset = nextFontPositionX + fontDef.xOffset + kerningAmount;
			var yOffset = nextFontPositionY + this._bmFontConfiguration.lineHeight - fontDef.yOffset - Std.int(rect.height);
			var position = new Vector2(xOffset, yOffset);

			var textureWidth = this._texture.pixelsWidth;
			var textureHeight = this._texture.pixelsHeight;
			var uvLeft = rect.left / textureWidth;
			var uvBottom = rect.top / textureHeight;
			var uvWidth = rect.width / textureWidth;
			var uvHeight = rect.height / textureHeight;

			var character:BMFontLabelCharacter = {
				charCode: charCode,
				posRect: new Rectangle(position.x, position.y, rect.width, rect.height),
				uvRect: new Rectangle(uvLeft, uvBottom, uvWidth, uvHeight),
				line: lineNumber,
				xOffset: xOffset,
				yOffset: yOffset,
				stringPosition: i
			};
			currentLine.chars.push(character);

			// update kerning
			nextFontPositionX += fontDef.xAdvance + kerningAmount;
			previousCharCode = charCode;

			currentLine.length = nextFontPositionX;
			longestLine = Std.int(Math.max(longestLine, nextFontPositionX));
		}

		// Get content size
		this._contentSize.width = longestLine;
		this._contentSize.height = totalHeight;

		// update character position
		this.updateCharacterPositions();
	}

	private function updateCharacterPositions():Void {
		var alignmentOffset = 0.0;

		for (line in this._lines) {
			if (this._alignment == TextAlignment.TextAlignmentRight) {
				alignmentOffset = this._contentSize.width - line.length;

			} else if (this._alignment == TextAlignment.TextAlignmentCenter) {
				alignmentOffset = 0.5 * (this._contentSize.width - line.length);
			}

			for (char in line.chars) {
				var xOffset = char.xOffset;
				char.posRect.x = xOffset + alignmentOffset;
			}
		}
	}

}
