package deltarune;

import flixel.util.typeLimit.NextState.InitialState;
import flixel.system.debug.log.LogStyle;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.FlxGame;
import flixel.FlxG;

import deltarune.assets.SysAssetSystem;
import deltarune.assets.OpenFLAssetSystem;
import deltarune.assets.GameAssets;
import deltarune.tools.LocalSave;
import deltarune.tools.CustomScaleMode;

import deltarune.game.states.substates.Options;

class Game extends FlxGame
{
	public static var consoleArguments:Array<String>;
	public static var enviromentVariables:Map<String, String>;
	public static var developerMode(default, set):Bool = false;
	public static var initialized:Bool = false;

	public static var globalSave:LocalSave;
	public static var chapterSave:LocalSave;

	public static var framerateDisplay:GameFps;
	public static var border:ConsoleBorder;

	public static function initialize():Void
	{
		if (initialized)
			return;

		FlxG.scaleMode = new CustomScaleMode();

		Controls.remapExtendedControllers();

		LogStyle.WARNING.openConsole = developerMode;
		LogStyle.ERROR.openConsole = developerMode;

		FlxTilemap.defaultFramePadding = 4;
		FlxObject.SEPARATE_BIAS = 8;

		FlxG.console.registerFunction('switchBorderIdTo', Game.border.switchToId);
		FlxG.console.registerFunction('switchBorderTo', Game.border.switchTo);
		FlxG.console.registerClass(Game);
		
		Game.border.switchTo();

		globalSave = new LocalSave();
		globalSave.bind('_default', 'savedata/global');

		chapterSave = new LocalSave();
		chapterSave.bind('placeholder_save', 'savedata');

		Options.initialize();
	}

	/*
	 * inline function that checks if value a is null, if so b is return, else a is returned
	 */
	public static inline function nullSwitch<T>(a:T, b:T):T
		return a!=null?a:b;

	public static function set_developerMode(value:Bool):Bool {
		LogStyle.WARNING.openConsole = value;
		LogStyle.ERROR.openConsole = value;
		return FlxG.log.redirectTraces = developerMode = value;
	}

	public function new(gameWidth = 0, gameHeight = 0, ?initialState:InitialState, updateFramerate = 60, drawFramerate = 60, skipSplash = false, startFullscreen = false)
	{
		super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);

		if (consoleArguments.contains("debugmode")) {
			developerMode = true;
		}
	}

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