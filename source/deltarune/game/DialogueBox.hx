package deltarune.game;

import deltarune.data.BasicJSONTypes;
import flixel.group.FlxSpriteContainer;

/**
 * Dialogue display and controller.
 * For more complex, unconventional typed text, you may want to use `Writer`
 */
class DialogueBox extends FlxSpriteContainer
{
	var writer:Writer; // the "text" from DialogueStyle
	var currentStyle:DialogueStyle;

	public function new()
	{
		super();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function setStyle(style:DialogueStyle) {}
}

// A small selection of UT/DR dialogue portraits use multiple sprites, if you didnt know.
class Portrait extends FlxSpriteContainer {}

typedef DialogueStyle =
{
	spriteOrder:Array<String>,
	basicSprites:Array<DialogueStyleSpriteData>,
	portraits:Array<DialogueStylePortraitData>,
	text:DialogueStyleTextData
}

typedef DialogueStyleMember =
{
	label:String,
	position:JSON2DPoint,
	?scale:JSON2DPoint
}

typedef DialogueStyleSpriteData =
{
	> DialogueStyleMember,
	image:String,
	?animation:Array<DSSAnimationData>
}

typedef DSSAnimationData =
{
	name:String
}

typedef DialogueStylePortraitData =
{
	> DialogueStyleMember,
	positionAlignment:String, // LEFT,RIGHT,TOP,BOTTOM,CENTER or a mix of two of these with a hyphen
	?isDefault:Bool,
	?textPositionOffset:JSON2DPoint,
	?textWidthOffset:Float
}

typedef DialogueStyleTextData =
{
	> DialogueStyleMember,
	defaultFont:String,
	?monoSpacing:Float,
	lineSpacing:Float,
	tabSpacing:Float,
}
