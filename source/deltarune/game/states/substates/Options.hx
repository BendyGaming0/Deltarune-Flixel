package deltarune.game.states.substates;

import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.game.SubState;
import deltarune.game.states.MenuState;
import deltarune.tools.LocalSave;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;

class Options extends SubState
{
	var returning:Bool;
	var entering:Bool;

	public static var generalData:Dynamic = {
		fps: 30,
		show_fps: false,
		show_memory: false,
		auto_run: false,
		music_volume: 1.0,
		sound_volume: 1.0,
	};

	public static var currentData:Dynamic = {
		play_time: 0.0,
		name: 'None',
		vessel_name: 'None',
		room_name: "001",
		room_x: 0,
		room_y: 0
	};

	public static var defaultData(default, never):Dynamic = {
		play_time: 0.0,
		name: 'EMPTY', // create some check for any saves to switch this out for kris or another name
		vessel_name: 'Vessel',
		room_name: "001",
		room_x: 0,
		room_y: 0
	};

	public static var save_destination:String;
	public static var save_id:Int;

	public static function initialize()
	{
		if (Game.globalSave.data.general != null)
		{
			generalData = Game.globalSave.data.general;
			FlxG.drawFramerate = FlxG.updateFramerate = (generalData.fps is Int) ? generalData.fps : 30;
		}
		else
		{
			Game.globalSave.data.general = generalData;
			Game.globalSave.flush();
		}

		if (Game.chapterSave.data.general == null)
		{
			Game.chapterSave.data.general = defaultData;
		}

		currentData = Game.chapterSave.data.general;
	}

	/*
	 * load all data from another save and change save dest/id save
	 */
	public static function loadNewSave(target_save_destination:String = null, target_save_id:Int = null)
	{
		Game.chapterSave.bind('${Game.nullSwitch(target_save_destination, save_destination)}_${Game.nullSwitch(target_save_id, save_id)}', 'savedata');

		if (Game.chapterSave.data.general == null)
		{
			Game.chapterSave.data.general = defaultData;
		}

		currentData = Game.chapterSave.data.general;
	}

	/*
	 * save all data on the current save
	 */
	public static function saveCurrentSave()
	{
		Game.chapterSave.bind('${save_destination}_${save_id}', 'savedata');
		Game.chapterSave.data.general = currentData;
		Game.chapterSave.flush();
	}

	/*
	 * quickly grabs the save data from another destination and ID, not for writing
	 * returns default data is no save is found
	 */
	public static function grabSaveData(data:String, target_save_destination:String = null, target_save_id:Int = null):Dynamic
	{
		var temp_save = new LocalSave();
		temp_save.bind('${Game.nullSwitch(target_save_destination, save_destination)}_${Game.nullSwitch(target_save_id, save_id)}');

		if (temp_save.data.general == null)
			return NoSuccess.NoSaveData;

		return Reflect.field(temp_save.data.general, data);
	}

	/*
	 * silently saves some data into the current save
	 * returns data saved
	 */
	public static function plopDataIntoSave(data:Dynamic, field:String)
	{
		Reflect.setField(Game.chapterSave.data.general, field, data);
		Game.chapterSave.flush(); // all the currently active data is in "currentData" not the save object
		return data;
	}

	/*
	 * changes save location without modifying current data or target data
	 */
	public static function selectSaveDestination(target_destination:String, target_id:Int)
	{
		save_destination = target_destination;
		save_id = target_id;
	}

	/*
	 * convenience function (selectSaveDestination(), saveCurrentSave(), selectSaveDestination())
	 */
	public static function saveToOtherSave(revert:Bool = false, target_destination:String, save_id:Int)
	{
		var prevSaveDest = save_destination;
		var prevSaveId = save_id;

		selectSaveDestination(save_destination, save_id);
		saveCurrentSave();

		if (revert)
			selectSaveDestination(prevSaveDest, prevSaveId);
	}

	public static function copySaveToSave(copyFrom:FlxSave, copyTo:FlxSave):Bool
	{
		try
		{
			var fields:Array<String> = Reflect.fields(copyFrom.data);

			copyTo.erase();
			for (field in fields)
			{
				Reflect.setProperty(copyTo, field, Reflect.getProperty(copyFrom, field));
			}
			copyTo.flush();

			return true;
		}
		catch (e)
		{
			trace('failed to copy save data, cloned data may be corrupt or empty');
			return false;
		}
	}

	public static function setGeneralData(field:String, value:Dynamic, ?flush:Bool = true)
	{
		trace('setting $field to $value');
		Reflect.setProperty(generalData, field, value);
		if (Reflect.getProperty(generalData, field) == value)
		{
			trace('success!');
		}
		Game.globalSave.data.general = generalData;
		if (flush)
		{
			Game.globalSave.flush();
		}
	}

	var options:Array<Option> = [];

	static var index:Int = 0;

	override public function create()
	{
		super.create();

		returning = false;
		entering = true;

		FlxTween.tween(MenuState.instance.playButton, {alpha: 0}, 0.5);
		FlxTween.tween(MenuState.instance.credsButton, {alpha: 0}, 0.5);
		FlxTween.tween(MenuState.instance.optButton, {alpha: 0}, 0.5);

		if (Game.developerMode)
		{
			FlxTween.tween(MenuState.instance.dialogueEditButton, {alpha: 0}, 0.5);
			FlxTween.tween(MenuState.instance.charEditButton, {alpha: 0}, 0.5);
			FlxTween.tween(MenuState.instance.battleEditButton, {alpha: 0}, 0.5);
			FlxTween.tween(MenuState.instance.chapterEditButton, {alpha: 0}, 0.5);
		}

		new FlxTimer().start(0.5, postCreate);

		var maxFpsOption = new Option(options.length, 'FPS', generalData.fps, 'fps', 'int', {
			change: 5,
			min: 30,
			max: 500, // the fastest monitors dont go past 500hz, also, do you really need to play DELTARUNE at 500 FPS?
			change_func: function(value, change)
			{
				FlxG.updateFramerate = FlxG.drawFramerate = (value is Int) ? value : 30;
			},
			current: false
		});
		options.push(maxFpsOption);
		add(maxFpsOption);

		var showFramerateOption = new Option(options.length, 'Show Fps?', generalData.show_fps, 'show_fps', 'bool', {current: false});
		options.push(showFramerateOption);
		add(showFramerateOption);

		var showMemOption = new Option(options.length, 'Show Memory?', generalData.show_memory, 'show_memory', 'bool', {current: false});
		options.push(showMemOption);
		add(showMemOption);

		var widescreenOption = new Option(options.length, '16:9 Widescreen Mode', generalData.widescreen, 'widescreen', 'bool', {current: false});
		options.push(widescreenOption);
		add(widescreenOption);

		if (Game.developerMode)
		{
			var battleBox = new Option(options.length, 'Test - Battle Box', generalData.show_fps, 'show_fps', 'none', {
				current: false,
				change_func: function(value, change)
				{
					FlxG.switchState(() -> new deltarune.editors.BattleBoxTestState());
				}
			});
			options.push(battleBox);
			add(battleBox);
		}

		bgColor = 0x00000000;
		changeIndex();
	}

	public function postCreate(_)
	{
		entering = false;
		FlxTween.tween(FlxG.camera.scroll, {x: 640}, 1, {ease: FlxEase.quadInOut});
	}

	override public function update(elapsed:Float)
	{
		if (!returning && !entering)
		{
			if (Controls.back.justPressed || FlxG.keys.justPressed.ESCAPE)
			{
				returning = true;
				FlxTween.tween(FlxG.camera.scroll, {x: 0}, 1, {ease: FlxEase.circInOut, onComplete: MenuState.instance.exitCredits});
			}

			if (Controls.left.justPressed)
				options[index].change(-1);
			if (Controls.right.justPressed)
				options[index].change(1);

			if (Controls.up.justPressed)
				changeIndex(-1);
			if (Controls.down.justPressed)
				changeIndex(1);

			if (Controls.primary.justPressed)
				options[index].select();
		}

		for (opt in options)
		{
			opt.alpha = 0.75;
			if (opt.index == index)
			{
				opt.alpha = 1;
			}
		}

		super.update(elapsed);
	}

	function changeIndex(chng:Int = 0)
	{
		index += chng;
		if (index < 0)
			index = options.length - 1;
		if (index >= options.length)
			index = 0;
	}
}

class Option extends FlxText
{
	public var index:Int;

	public var optLabel:String;

	public var value:Dynamic;

	var field:String;

	var type:String;

	var properties:OptionConfig;

	public function new(index:Int, text:String, value:Dynamic, field:String, type:String, ?properties:OptionConfig)
	{
		super((FlxG.width * 2) - (320 + 10), (index * 40) + 10, 320, text);
		setFormat('', 32, FlxColor.WHITE, RIGHT);
		_defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		antialiasing = false;
		this.properties = properties;
		this.index = index;
		this.value = value;
		this.field = field;
		this.type = type;
		optLabel = text;
	}

	public function select()
	{
		switch (type)
		{
			case 'int':
				trace('cant select int');
			case 'float':
				trace('cant select float');
			case 'bool':
				if (value == true)
				{
					value = false;
				}
				else
				{
					value = true;
				}
				if (properties.current)
				{
					trace('oops');
				}
				else
				{
					Options.setGeneralData(field, value);
				}
			default:
				trace('invalid');
		}
	}

	override public function update(elapsed:Float)
	{
		switch (type)
		{
			case 'int':
				text = '< ' + value + ' > - ' + optLabel;
			case 'float':
				text = '< ' + value + ' > - ' + optLabel;
			case 'bool':
				text = '< ' + (value ? 'Yes' : 'No') + ' > - ' + optLabel;
			default:
				text = optLabel;
		}
		super.update(elapsed);
	}

	public function change(change:Int)
	{
		switch (type)
		{
			case 'int':
				if (value == null || !(value is Int))
				{
					value = 0;
				}
				value += change * Std.int(properties.change);
				if (value < properties.min)
				{
					value = Std.int(properties.min);
				}
				if (value > properties.max)
				{
					value = Std.int(properties.max);
				}
				if (properties.current)
				{
					trace('oops');
				}
				else
				{
					Options.setGeneralData(field, value);
				}
			case 'float':
				trace('not complete');
			case 'bool':
				if (value == true)
				{
					value = false;
				}
				else
				{
					value = true;
				}
				if (properties.current)
				{
					trace('oops');
				}
				else
				{
					Options.setGeneralData(field, value);
				}
			default:
				trace('invalid');
		}

		if (properties.change_func != null)
		{
			properties.change_func(value, change);
		}
	}
}

typedef OptionConfig =
{
	var ?change:Float;
	var ?change_func:Dynamic->Int->Void;
	var ?min:Float;
	var ?max:Float;
	var ?current:Bool;
}

enum NoSuccess
{
	GenericFailure;
	NoSaveData;
	NoData;
}
