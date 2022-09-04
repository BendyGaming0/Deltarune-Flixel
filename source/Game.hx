import flixel.FlxG;
import flixel.FlxGame;

class Game extends FlxGame
{
	@:allow(flixel.FlxG)
	override function onResize(_):Void
	{
		var width:Int = FlxG.stage.stageWidth;
		var height:Int = FlxG.stage.stageHeight;

        //if (Main.screenRatio == SIXTEEN_NINE)
        //{
		//	width = Math.round(width * 0.75);
		//	height = Math.round(height * 0.75);
        //}

		#if !flash
		if (FlxG.renderTile)
			FlxG.bitmap.onContext();
		#end

		resizeGame(width, height);
	}
}