package deltarune.game;

import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.game.states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import openfl.Assets;
import openfl.display.BitmapData;

typedef DialogueStructure =
{
	var style:String;
	var dialogue:Array<DialogueLine>;
}

typedef DialogueLine =
{
	var portrait:String;
	var text:String;
	var speed:Float;
	var pausespeed:Float;
	var autocontinue:Bool;
	var skippable:Bool;
}

typedef DialogueFile = OneOfTwo<DialogueStructure, String>;

class LegacyDialogueBox extends FlxSpriteContainer
{
	public var activated(default, set):Bool;

	public var finishedCallback:() -> Void;
	public var dialogueProgressedCallback:(Int) -> Void;

	// sprite order
	var background:FlxSprite;
	var portrait:FlxSprite;
	var astrix:FlxText;
	var typeText:FlxTypeText;

	var shadowPow:Int = 1;

	var niceDialogue:DialogueStructure;

	var dialogueIndex:Int;

	var linefinished:Bool;

	var disableControls:Bool = false;

	function set_activated(value:Bool)
	{
		if (typeText != null)
		{
			for (sound in typeText.sounds)
				sound.volume = value ? 1 : 0;
		}
		activated = value;
		return value;
	}

	var defaultfile:DialogueStructure = {
		style: "darkworld",
		dialogue: [
			{
				portrait: "none",
				text: "Dialogue failed to load, please check the path or dialogue file for issues",
				speed: 1,
				pausespeed: 1,
				autocontinue: false,
				skippable: true
			},
		]
	};

	public function new(X:Float = 0, Y:Float = 0, dialogue:DialogueFile)
	{
		super();
		constructor(dialogue);
	}

	public function reconstruct(dialogue:DialogueFile)
	{
		remove(background);
		background.destroy();
		remove(portrait);
		portrait.destroy();
		remove(astrix);
		astrix.destroy();
		remove(typeText);
		typeText.destroy();
		constructor(dialogue);
	}

	function constructor(dialogue:DialogueFile)
	{
		if ((dialogue is String))
		{
			var jsonstr:String = dialogue;
			if (GameAssets.exists(dialogue))
				jsonstr = GameAssets.text(dialogue);
			try
			{
				niceDialogue = haxe.Json.parse(jsonstr);
			}
			catch (e:Any)
			{
				FlxG.log.warn("Failed to parse/load Dialogue");
				niceDialogue = defaultfile;
			}
		}
		else
			niceDialogue = dialogue;

		activated = false;
		dialogueIndex = 0;
		linefinished = false;

		background = new FlxSprite(0, 0, GameAssets.bitmap('images/${niceDialogue.style}Box.png'));
		if (niceDialogue.style == "darkworld")
		{
			background.offset.x = 8;
			background.offset.y = 8;
		}
		background.scale.x = 2;
		background.scale.y = 2;
		background.antialiasing = false;
		background.updateHitbox();

		add(background);

		portrait = new FlxSprite(0, 0);
		portrait.scale.x = 2;
		portrait.scale.y = 2;
		portrait.antialiasing = false;
		portrait.updateHitbox();

		add(portrait);

		astrix = new FlxText(24, 26, 48, "*");
		astrix.setFormat('', 32, FlxColor.WHITE, LEFT);
		@:privateAccess
		astrix._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		astrix.antialiasing = false;
		astrix.setBorderStyle(SHADOW_XY(shadowPow, shadowPow), 0xFF171769, 1, 1);

		add(astrix);

		typeText = new FlxTypeText(52, 24, 496, getCurrentLine().text); // x, y, width
		typeText.setFormat('', 32, FlxColor.WHITE, LEFT);
		@:privateAccess
		typeText._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		typeText.antialiasing = false;
		typeText.start(getCurrentLine().speed / 30, true, false, [], dialogueLineFinished);
		typeText.setBorderStyle(SHADOW_XY(shadowPow, shadowPow), 0xFF171769, 1, 1);

		add(typeText);

		dialogueIndex = -1;
		continueDialogue();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.R && Game.developerMode && !disableControls)
		{
			activated = true;
			dialogueIndex = -1;
			continueDialogue();
		}

		if (PlayState.instance != null)
		{
			if (!activated)
			{
				if (PlayState.instance.player.controlArray.contains('dialogue'))
					PlayState.instance.player.controlArray.remove('dialogue');
				return;
			}
			else if (!PlayState.instance.player.controlArray.contains('dialogue'))
			{
				PlayState.instance.player.controlArray.push('dialogue');
			}
		}

		var justContinued:Bool = false;

		if ((Controls.primary.justPressed || Controls.tetritary.pressed) && linefinished && !disableControls)
		{
			continueDialogue();
			justContinued = true;
		}

		if (((Controls.primary.justPressed && !justContinued) || Controls.secondary.pressed || Controls.tetritary.pressed)
			&& !disableControls
			&& !linefinished
			&& getCurrentLine().skippable)
		{
			typeText.skip();
		}
	}

	function position(start:Float)
	{
		return start + getCurrentLine().portrait == "none" ? 0 : 100;
	}

	function positionSprite(sprite:FlxSprite, xv:Float = null, yv:Float = null)
	{
		if (xv != null)
			sprite.x = xv + x - offset.x;
		if (yv != null)
			sprite.y = yv + y - offset.y;
	}

	function getSpritePosition(sprite:FlxSprite)
	{
		return new FlxPoint(sprite.x, sprite.y).subtract(x - offset.x, y - offset.y);
	}

	public function dialogueLineFinished()
	{
		linefinished = true;
		if (getCurrentLine().autocontinue && !disableControls)
			continueDialogue();
	}

	public function continueDialogue(?reset:Bool = false)
	{
		linefinished = false;

		if (dialogueIndex + 1 >= niceDialogue.dialogue.length && !reset)
		{
			activated = false;
			if (finishedCallback != null)
				finishedCallback();
		}
		else
		{
			if (!reset)
				dialogueIndex++;
			if (dialogueProgressedCallback != null)
				dialogueProgressedCallback(dialogueIndex);

			updatePortrait();

			typeText.resetText(getCurrentLine().text);
			typeText.start(getCurrentLine().speed / 30, true, false, [], dialogueLineFinished);
		}
	}

	function updatePortrait()
	{
		if ((getCurrentLine().portrait == "none" || getCurrentLine().portrait == "")
			&& !GameAssets.exists(Paths.getPortrait(getCurrentLine().portrait)))
		{
			portrait.visible = false;
			astrix.offset.x = 0;
			typeText.offset.x = 0;
			typeText.fieldWidth = 496;
		}
		else
		{
			portrait.visible = true;
			portrait.loadGraphic(GameAssets.bitmap(Paths.getPortrait(getCurrentLine().portrait)));
			portrait.updateHitbox();
			positionSprite(portrait, ((100 - portrait.width) / 2) + 24, (160 - portrait.height) / 2);
			astrix.offset.x = -(portrait.width + getSpritePosition(portrait).x);
			typeText.offset.x = -(portrait.width + getSpritePosition(portrait).x);
			typeText.fieldWidth = 400;
		}

		if (GameAssets.exists(Paths.getTextSound(getCurrentLine().portrait)))
		{
			typeText.sounds = [
				new FlxSound().loadEmbedded(GameAssets.sound(Paths.getTextSound(getCurrentLine().portrait)))
			];
		}
		else
		{
			typeText.sounds = [new FlxSound().loadEmbedded(GameAssets.sound(Paths.getTextSound()))];
		}

		activated = activated;
	}

	override public function draw()
	{
		if (activated)
		{
			super.draw();
		}
	}

	public inline function getCurrentLine()
	{
		return niceDialogue.dialogue[dialogueIndex];
	}
}
