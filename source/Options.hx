package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import PathGenerator;
import flixel.text.FlxText;
import flixel.FlxSubState;
import sys.io.File;

class Options extends FlxSubState
{
    var returning:Bool;

    override public function create()
    {
        super.create();

		returning = false;

		FlxTween.tween(MenuState.instance.playButton, {alpha: 0}, 1);
		FlxTween.tween(MenuState.instance.credsButton, {alpha: 0}, 1);
		new FlxTimer().start(2, postCreate);
		FlxTween.tween(FlxG.camera.scroll, {x: 640}, 1, {ease: FlxEase.circInOut});

        bgColor = 0x00000000;
    }

	public function postCreate(_)
	{
		//do stuff
	}

	override public function update(elapsed:Float)
    {
        if (!returning) {
            if (FlxG.keys.justPressed.ESCAPE)
            {
                returning = true;
				FlxTween.tween(FlxG.camera.scroll, {x: 0}, 1, {ease: FlxEase.circInOut, onComplete: MenuState.instance.exitCredits});
			}
		}

        super.update(elapsed);
    }
}