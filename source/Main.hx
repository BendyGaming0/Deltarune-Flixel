package;

import openfl.Lib;
import openfl.events.Event;
import openfl.display.FPS;
import openfl.display.Sprite;

import flixel.FlxGame;
import flixel.system.FlxSplash;
import flixel.math.FlxMath;

class Main extends Sprite
{
	/**
	 * arguments passed through the command line
	 */
	public static var args:Array<String>; 
	public static var gamewidth:Int = 640;
	public static var gameheight:Int = 480;

	public static var fps:FPS;
	public static var border:ConsoleBorder;
	public static var screenRatio:ScreenRatio = FOUR_THREE;

	//event listener stuff was made by other people
	public function new()
	{
		args = Sys.args();
		for (arg in args)
		{
			trace('command line argument:' + arg);
		}

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
		border = new ConsoleBorder();
		addChild(border);
		FlxSplash.nextState = TransitionState;
		// "Game" is just a slighly modified version of FlxGame to let the console borders work
		addChild(new Game(gamewidth, gameheight, FlxSplash, -1, 30, 30, false));
		//Controls.addControllerToast();
	}

	var skipNext:Bool = false;

	function fixResize(e:Event)
	{
		if (skipNext)
		{
			skipNext = false;
			return;
		}

		skipNext=true;
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
				trace('4:3');
			case 1: // 16:9
				var segSize:Int = Math.ceil(Math.max(stage.stageWidth / 16, stage.stageHeight / 9));
				screenRatio = SIXTEEN_NINE;
				newwidth = segSize * 16;
				newheight = segSize * 9;
				trace('16:9');
		}

		if (!Lib.application.window.fullscreen)
			Lib.application.window.resize(newwidth, newheight);
	}
}

enum ScreenRatio
{
	FOUR_THREE;
	SIXTEEN_NINE;
}