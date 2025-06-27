package deltarune.game.states.substates;

import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.game.SubState;
import deltarune.game.states.MenuState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
#if sys
import sys.io.File;
#end

class Credits extends SubState
{
	var debugMode:FlxButton;
	var coolCredits:FlxText;
	var pressEsc:FlxText;

	var returning:Bool;

	var timeAfterPress:Float;
	var maxScrollPower:Float = 60;
	var scroll:Float;

	override public function create()
	{
		super.create();

		var markupRules = [
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.YELLOW), "%y%"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GRAY), "%gry%"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "%r%")
		];

		returning = false;

		var coolText = GameAssets.text('data/credits/Chapter 1.txt');

		coolCredits = new FlxText(8, 520, 224, "");
		coolCredits.setFormat('', 18, FlxColor.WHITE, LEFT);
		@:privateAccess
		coolCredits._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		coolCredits.antialiasing = false;
		if (coolText != '')
		{
			coolCredits.applyMarkup(coolText, markupRules);
		}
		else
		{
			coolCredits.applyMarkup("The Spriter's Resource - Sprite Rips
HaxeFlixel Demos - Shader Code For Title Screen
Bendy Gaming - Created The Port", markupRules);
		}

		pressEsc = new FlxText(8, 440, 0, "Press ESC/Back to go back");
		pressEsc.setFormat('', 18, FlxColor.WHITE, LEFT);
		@:privateAccess
		pressEsc._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		pressEsc.antialiasing = false;
		pressEsc.setBorderStyle(OUTLINE, 0xFF000000, 2, 1);
		pressEsc.alpha = 0;

		add(coolCredits);
		add(pressEsc);

		if (!Game.developerMode)
		{
			debugMode = new FlxButton(0, -75, "Debug Mode", function()
			{
				Game.developerMode = true;
				close();
				FlxG.switchState(() -> new MenuState());
			});
			debugMode.screenCenter(X);
			add(debugMode);
		}

		scroll = 0;

		FlxTween.tween(pressEsc, {alpha: 1}, 2);
		FlxTween.tween(MenuState.instance.playButton, {alpha: 0}, 1);
		FlxTween.tween(MenuState.instance.credsButton, {alpha: 0}, 1);
		FlxTween.tween(MenuState.instance.optButton, {alpha: 0}, 1);

		if (Game.developerMode)
		{
			FlxTween.tween(MenuState.instance.dialogueEditButton, {alpha: 0}, 1);
			FlxTween.tween(MenuState.instance.charEditButton, {alpha: 0}, 1);
			FlxTween.tween(MenuState.instance.battleEditButton, {alpha: 0}, 1);
			FlxTween.tween(MenuState.instance.chapterEditButton, {alpha: 0}, 1);
		}

		bgColor = 0x00000000;
	}

	override public function update(elapsed:Float)
	{
		timeAfterPress += elapsed;

		if (timeAfterPress > 1.5 && !returning)
		{
			scroll += (maxScrollPower - scroll) * elapsed;
			FlxG.camera.scroll.y += scroll * elapsed;
		}

		if (!returning)
		{
			if (Controls.back.justPressed || FlxG.keys.justPressed.ESCAPE)
			{
				returning = true;
				FlxTween.tween(FlxG.camera.scroll, {y: 0}, 1, {ease: FlxEase.circInOut, onComplete: MenuState.instance.exitCredits});
				FlxTween.tween(pressEsc, {alpha: 0}, 1);
			}
			if (Controls.up.pressed)
			{
				timeAfterPress = 0;
				scroll = 0;
				FlxG.camera.scroll.y -= 300 * elapsed;
			}
			if (Controls.down.pressed)
			{
				timeAfterPress = 0;
				scroll = 0;
				FlxG.camera.scroll.y += 300 * elapsed;
			}

			if (((coolCredits.y + coolCredits.height) - 400) < FlxG.camera.scroll.y)
				FlxG.camera.scroll.y = ((coolCredits.y + coolCredits.height) - 400);

			if (FlxG.camera.scroll.y < -100 && !Game.developerMode)
				FlxG.camera.scroll.y = -100;

			if (FlxG.camera.scroll.y < 0 && Game.developerMode)
				FlxG.camera.scroll.y = 0;
		}

		pressEsc.y = FlxG.camera.scroll.y + 440;

		if (debugMode != null)
			debugMode.y = -75 - FlxG.camera.scroll.y;

		super.update(elapsed);
	}
}
