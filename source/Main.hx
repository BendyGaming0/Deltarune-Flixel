package;

import deltarune.ConsoleBorder;
import deltarune.Controls;
import deltarune.Game;
import deltarune.GameFps;
import deltarune.assets.GameAssets;
import deltarune.assets.OpenFLAssetSystem;
import deltarune.assets.SysAssetSystem;
import flixel.math.FlxMath;
import flixel.system.FlxSplash;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	public static var gamewidth:Int = 640;
	public static var gameheight:Int = 480;

	public static var framerate(get, set):Float;

	public static function set_framerate(value:Float)
		return openfl.Lib.current.stage.frameRate = value;

	public static function get_framerate()
		return openfl.Lib.current.stage.frameRate;

	// event listener stuff was made by other people
	public function new()
	{
		#if sys
		Game.consoleArguments = Sys.args();
		Game.enviromentVariables = Sys.environment();
		#else
		Game.consoleArguments = [];
		Game.enviromentVariables = new Map<String, String>();
		#end

		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public function setupGame()
	{
		if (!Game.consoleArguments.contains('noopenflassets'))
			GameAssets.assetSystems.push(new OpenFLAssetSystem('openfl', 'assets'));

		#if sys
		GameAssets.assetSystems.push(new SysAssetSystem('default', Sys.getCwd() + '/assets')); // higher priority, as it includes more things by always being up to date
		#end

		addChild(Game.border = new ConsoleBorder());
		addChild(new Game(gamewidth, gameheight, () -> new deltarune.game.states.ChapterSelectState(), 30, 30, true));
		addChild(Game.framerateDisplay = new GameFps());
		Controls.addControllerToast();
	}
}
