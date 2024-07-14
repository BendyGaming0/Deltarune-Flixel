package;

import deltarune.assets.SysAssetSystem;
import deltarune.assets.OpenFLAssetSystem;
import deltarune.assets.GameAssets;
import deltarune.GameFps;
import deltarune.Game;
import deltarune.ConsoleBorder;
import deltarune.Controls;

import openfl.Lib;
import openfl.events.Event;
import openfl.display.Sprite;

import flixel.system.FlxSplash;
import flixel.math.FlxMath;

class Main extends Sprite
{
	public static var gamewidth:Int = 640;
	public static var gameheight:Int = 480;

	public static var framerate(get, set):Float;

	public static function set_framerate(value:Float)
		return openfl.Lib.current.stage.frameRate = value;

	public static function get_framerate()
		return openfl.Lib.current.stage.frameRate;
	
	public static var screenRatio:ScreenRatio = FOUR_THREE;

	//event listener stuff was made by other people
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

		stage.addEventListener(Event.RESIZE, fixResize);

		setupGame();
	}

	public function setupGame()
	{
		if (!Game.consoleArguments.contains('noopenflassets'))
			GameAssets.assetSystems.push(new OpenFLAssetSystem('assets'));
		
		#if sys
		GameAssets.assetSystems.push(new SysAssetSystem(Sys.getCwd() + '/assets')); //higher priority, as it includes more things
		#end
		
		addChild(Game.border = new ConsoleBorder());
		addChild(new Game(gamewidth, gameheight, () -> new FlxSplash(() -> new deltarune.game.states.IntroState()), 30, 30, false));
		addChild(Game.framerateDisplay = new GameFps());
		Controls.addControllerToast();
	}


	function fixResize(e:Event)
	{
		var curRatio = stage.stageWidth / stage.stageHeight;
		var r4by3 = 4 / 3;
		var r16by9 = 16 / 9;
		var clipTo = FlxMath.bound(Math.round(FlxMath.remapToRange(curRatio, r4by3, r16by9, 0, 1)), 0, 1);

		var newwidth = 640;
		var newheight = 480;

		switch (clipTo)
		{
			case 0: //4:3
				var segSize:Int = Math.ceil(Math.max(stage.stageWidth / 4, stage.stageHeight / 3));
				screenRatio = FOUR_THREE;
				newwidth = segSize * 4;
				newheight = segSize * 3;
			case 1: // 16:9
				var segSize:Int = Math.ceil(Math.max(stage.stageWidth / 16, stage.stageHeight / 9));
				screenRatio = SIXTEEN_NINE;
				newwidth = segSize * 16;
				newheight = segSize * 9;
		}

		if (!Lib.application.window.fullscreen)
		{
			stage.removeEventListener(Event.RESIZE, fixResize);
			Lib.application.window.resize(newwidth, newheight);
			stage.addEventListener(Event.RESIZE, fixResize);
		}
	}
}

enum ScreenRatio
{
	FOUR_THREE;
	SIXTEEN_NINE;
}