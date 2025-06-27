package deltarune.game;

import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteContainer;

using StringTools;

class Writer extends FlxSpriteContainer
{
	public var awaitingEvent:Bool = false;
	public var lineIndex:Int = 0;
	public var instructionIndex:Int = 0;
	public var canSkip:Bool = true;
	public var autoContinue:Bool = false;
	public var fullOffsetType:WritingOffset = NONE;
	public var typingOffsetType:WritingOffset = NONE;

	/**
	 *  A list of typing, dialog, event or cutscene instructions
	 */
	public var instructions:Array<WriterInstruction> = [];

	public var usedCharacters:FlxTypedGroup<Character>;

	/**
	 * Characters not currently in use
	 */
	public var heldCharacters:FlxTypedGroup<Character>;

	public var writtenText(default, null):String;

	/**
	 * Accessor for `writer.instructions[writer.instructionIndex]`
	 */
	public var currentInstruction(get, never):WriterInstruction;

	function get_currentInstruction():WriterInstruction
	{
		return if (instructionIndex >= instructions.length || instructionIndex < 0) null; else instructions[instructionIndex];
	}

	/**
	 *  The amount of time passed executing the current instruction, pauses when complete
	 *
	 *  If setting the value returns -1.0, the current instruction could not be accessed
	 */
	public var instructionTime(get, set):Float;

	function get_instructionTime():Float
	{
		return currentInstruction?.time ?? -1.0;
	}

	function set_instructionTime(time:Float):Float
	{
		if (currentInstruction != null)
		{
			return currentInstruction.time = time;
		}
		return -1.0;
	}

	/**
	 *  How much of the current instruction has been performed from 0 to 1, -1 means it cant report/access the amount
	 */
	public var instructionProgress(get, set):Float;

	function get_instructionProgress():Float
	{
		return currentInstruction?.progress ?? -1.0;
	}

	function set_instructionProgress(progress:Float):Float
	{
		if (currentInstruction != null)
		{
			return currentInstruction.progress = progress;
		}
		return -1.0;
	}

	public function new(X:Float, Y:Float)
	{
		super(X, Y);
	}

	override public function update(elapsed:Float)
	{
		currentInstruction.update(elapsed);

		super.update(elapsed);
	}

	public function addText(text:String, silent:Bool = false)
	{
		for (char in 0...text.length)
		{
			var character = heldCharacters.getFirstAlive();
			if (character == null)
			{
				character = new Character();
				usedCharacters.add(character);
				add(character);
			}
			else
			{
				heldCharacters.remove(character);
				usedCharacters.add(character);
				add(character);
			}
			character.setChar(text.charAt(char));
		}
	}

	public function setText(text:String, silent:Bool = false)
	{
		for (char in 0...text.length) {}
	}

	public function clearText()
	{
		for (char in usedCharacters)
		{
			remove(char);
			usedCharacters.remove(char);
			heldCharacters.add(char);
		}
	}

	public function setFont(font:String) {}

	public function tryContinue():Bool
	{
		return true;
	}

	public function trySkip():Bool
	{
		return !canSkip;
	}
}

class WriterInstruction
{
	public var data:Dynamic;
	public var instructionData:Map<String, Dynamic> = [];
	public var type:String;
	public var time:Float = 0;
	public var progress:Float = -1;
	public var writer:Writer;
	public var dialog:Dynamic;
	public var canSkip:Bool;
	public var skipOver:Bool;
	public var autoContinue:Bool;

	public function new(data:Dynamic)
	{
		this.data = data;
		type = data.type;

		switch (type.toLowerCase())
		{
			case "write":
				canSkip = skipOver = data?.skippable ?? true;
				skipOver = data?.skipsOver ?? skipOver;
				autoContinue = data?.autoContinue ?? false;
			case "rewrite":
				autoContinue = data?.autoContinue ?? true;
			case "color":
				canSkip = skipOver = true;
				autoContinue = true;
			case "erase":
				canSkip = skipOver = data?.skippable ?? true;
				skipOver = data?.skipsOver ?? skipOver;
				autoContinue = data?.autoContinue ?? false;
			case "effect":
				canSkip = skipOver = true;
				autoContinue = true;
			case "pause":
				canSkip = skipOver = data?.skippable ?? false;
				skipOver = data?.skipsOver ?? skipOver;
				autoContinue = data?.autoContinue ?? true;
			case "portrait":
				canSkip = skipOver = true;
				autoContinue = true;
			case "sound":
				canSkip = skipOver = true;
				autoContinue = true;
			case "style":
				canSkip = skipOver = true;
				autoContinue = true;
			case "event":
				canSkip = skipOver = false;
				autoContinue = true;
			case "font":
				canSkip = skipOver = true;
				autoContinue = true;
			case "sprchar":
				canSkip = skipOver = data?.skippable ?? true;
				skipOver = data?.skipsOver ?? skipOver;
				autoContinue = data?.autoContinue ?? true;
			case "move":
				FlxG.log.warn("Chapter 3 and 4 dialog features ["+type.toLowerCase()+"] have not been implemented yet!"); // DAMN YOU TENNA!
			case "minidialog":
				// figure this out later lol
		}
	}

	public function update(elapsed:Float)
	{
		switch (type.toLowerCase())
		{
			case "write":
				/**
				 *	Writes characters to the writer at a specified rate (default: 30 cps)
				 *	Using syntax like `${}` will let you access certain properties such as the player or character's name
				 *	By default all text is erased when progressed, for timed writing with pauses over several instructions
				 *	auto-erase should be disabled
				 *	The text will also pause at line breaks by default, this behavior can also be disabled
				 *	Setting the rate to -1 or lower will instantly type all characters
				 *	Creating the UT/DT asterix/mini character icon: "*\tDialog here."
				 */
				time += elapsed;
			case "rewrite":
				/**
				 *	Replaces all current text with new text
				 *	(e.g. used in flowey's 'tutorial'
				 *	"RUN. INTO. THE. BULLETS!" -> "RUN. INTO. THE. friendliness pellets.")
				 */
			case "color":
				/**
				 *	Lets you change the color of text written or apply a gradient
				 *	Currently gradients use shaders so dont go typing an entire textbox of gradient characters pls
				 */
			case "erase":
				/**
				 *	Erases all current text
				 */
			case "effect":
				/**
				 *	Applies/Removes an effect either to:
				 *	 -	New text written
				 *	 -	Previous text in range
				 *	 -	Entire writer (independent from per character effect)
				 */
			case "pause":
				/**
				 *	Simply creates a pause
				 *	While possible, its not recommended to put a pause at the end of a sequence
				 */
			case "portrait":
				/**
				 *  Switch the current portrait
				 *  The UT/DR style only has 1 portrait (mini dialog is handled differently)
				 *  but custom styles can specify multiple portraits
				 *  and use this instruction to switch the currently selected portrait(s) (which ones animate on type) 
				 */
			case "sound":
				/**
				 *  Changes/Disables the typing sound
				 *  Unlike UT/DR, multiple sounds are supported and can either be random, or sequenced
				 */
			case "style":
				/**
				 *  switch dialog/writer style 
				 *  default styles are Light World (Box/No Box), and Dark World (Box/No Box),
				 *  but the styling system can allow you to replicate dialog from most 2D RPG games
				 */
			case "event":
				/**
				 *  Starts a labeled writer event which suspends the writer (optionally hiding it)
				 *  and waits until a response where it then resumes
				 */
			case "font":
				/**
				 *	Change the current font
				 */
			case "sprchar":
				/**
				 *	Adds a sprite as a character, animated sprites can optionally be tied to typing (like Sweet, Cap'n, Cakes)
				 */
			case "move":
				/**
				 *  Chapter 3 + 4 dialog feature, yet to be implemented (used in tenna's dialog after he types with a large animated image)
				 */
			case "minidialog":
				/**
				 *	Creates a miniature piece of dialog (optionally with a portrait and font)
				 */
		}
	}

	public function trySkip(skippingOver:Bool):Bool
	{
		return canSkip;
	}
}

class Character extends FlxSprite
{
	public var char:String = "";
	public var isImage:Bool = false;

	public function setChar(char:String)
	{
		this.char = char;
		if (char == "" || char.isSpace(0))
		{
			visible = false;
		}
	}
}

enum WritingOffset
{
	NONE;
	WAVE;
	SHAKE;
}
