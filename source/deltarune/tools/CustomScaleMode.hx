package deltarune.tools;

import flixel.FlxG;
import flixel.system.scaleModes.BaseScaleMode;

class CustomScaleMode extends BaseScaleMode
{
	// to-do, FORCE INTEGER SCALING (cause it looks bad otherwise)!!
	override function updateGameSize(Width:Int, Height:Int):Void
	{
		var ratio:Float = FlxG.width / FlxG.height;
		var realRatio:Float = Width / Height;

		var scaleY:Bool = realRatio < ratio;

		if (scaleY)
		{
			gameSize.x = Width;
			gameSize.y = Math.floor(gameSize.x / ratio);
		}
		else
		{
			gameSize.y = Height;
			gameSize.x = Math.floor(gameSize.y * ratio);
		}

		if (Main.screenRatio == SIXTEEN_NINE)
			gameSize.scale(8 / 9);
	}
}
