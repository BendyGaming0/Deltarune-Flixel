package states.substates;

import tools.PathGenerator;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSubState;
import sys.io.File;
import states.MenuState;

class Credits extends FlxSubState
{
	var debugMode:FlxButton;
	var coolCredits:FlxText;
	var pressEsc:FlxText;

    var returning:Bool;

	var timeAfterPress:Float;
    var maxScrollPower:Float = 100;
    var scroll:Float;

    override public function create()
    {
        super.create();

		returning = false;

		var coolText = File.getContent(Sys.getCwd() + '/assets/data/credits.txt');

        coolCredits = new FlxText(0, 520);
		coolCredits.text = coolText;
        if (coolCredits.text == null || coolCredits.text == '') {
            coolCredits.text = 
			"Toby Fox - Lead Developer Of Deltarune
Temmie Chang - Main Artist Of Deltarune
Deltarune Chapter 2 Team
-
Helped With The Development
The Spriter's Resource - Sprite Rips
HaxeFlixel Demos - Shader Code For Title Screen
Bendy Gaming - Created The Port"; }
		coolCredits.setFormat(PathGenerator.getFont("8bitoperator_jve"), 32, FlxColor.WHITE, CENTER);
		coolCredits.antialiasing = false;

        coolCredits.screenCenter(X);

		pressEsc = new FlxText(8, 440, 0, "Press ESC/Back to go back");
		pressEsc.setFormat(PathGenerator.getFont("8bitoperator_jve"), 32, FlxColor.WHITE, LEFT);
		pressEsc.antialiasing = false;
		pressEsc.setBorderStyle(OUTLINE, 0xFF000000, 2, 1);
        pressEsc.alpha = 0;

        add(coolCredits);
        add(pressEsc);

		if (!Main.args.contains('debugmode')) {
			debugMode = new FlxButton(0, -75, "Debug Mode", function() {
				Main.args.push('debugmode');
				close();
				FlxG.switchState(new MenuState());
			});
			debugMode.screenCenter(X);
			add(debugMode);
		}

		scroll = 0;

		FlxTween.tween(pressEsc, {alpha: 1}, 2);
		FlxTween.tween(MenuState.instance.playButton, {alpha: 0}, 1);
		FlxTween.tween(MenuState.instance.credsButton, {alpha: 0}, 1);
		FlxTween.tween(MenuState.instance.optButton, {alpha: 0}, 1);

		if (Main.args.contains('debugmode'))
		{
			FlxTween.tween(MenuState.instance.dialougeEditButton, {alpha: 0}, 1);
			FlxTween.tween(MenuState.instance.charEditButton, {alpha: 0}, 1);
			FlxTween.tween(MenuState.instance.battleEditButton, {alpha: 0}, 1);
			FlxTween.tween(MenuState.instance.chapterEditButton, {alpha: 0}, 1);
		}

        bgColor = 0x00000000;
    }

	override public function update(elapsed:Float)
    {
		timeAfterPress += elapsed;

        if (timeAfterPress > 1.5 && !returning) {
			scroll += (maxScrollPower - scroll) * elapsed;
		    FlxG.camera.scroll.y += scroll * elapsed;
        }

        if (!returning) {
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
				FlxG.camera.scroll.y -= 200 * elapsed;
			}
			if (Controls.down.pressed)
			{
				timeAfterPress = 0;
				scroll = 0;
				FlxG.camera.scroll.y += 200 * elapsed;
			}

            if (((coolCredits.y + coolCredits.height) - 400) < FlxG.camera.scroll.y)
                FlxG.camera.scroll.y = ((coolCredits.y + coolCredits.height) - 400);

			if (FlxG.camera.scroll.y < -100 && !Main.args.contains('debugmode'))
				FlxG.camera.scroll.y = -100;

			if (FlxG.camera.scroll.y < 0 && Main.args.contains('debugmode'))
				FlxG.camera.scroll.y = 0;
        }

		pressEsc.y = FlxG.camera.scroll.y + 440;

		if (debugMode != null)
			debugMode.y = -75 - FlxG.camera.scroll.y;

        super.update(elapsed);
    }
}