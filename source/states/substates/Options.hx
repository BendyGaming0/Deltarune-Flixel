package states.substates;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import tools.PathGenerator;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.util.FlxSave;
import states.MenuState;

class Options extends FlxSubState
{
	var returning:Bool;
	var entering:Bool;

	public static var generalData:Dynamic =
	{
		fps: 30,
		show_fps: false
	};
	public static var currentData:Dynamic =
	{
		play_time: 0.0,
		name: 'None',
		vessel_name: 'None'
	};

	public static var curSave:FlxSave;

	public static function initialize()
	{
		if (FlxG.save.data.general != null)
		{
			generalData = FlxG.save.data.general;
			Main.framerate = (generalData.fps is Int) ? generalData.fps : 30;
		}
		else
		{
			FlxG.save.data.general = generalData;
			FlxG.save.flush();
		}

		curSave = new FlxSave();
		curSave.bind('default_save_1', 'BendyGaming0/Deltarune');

		if (curSave.data.general != null)
		{
			currentData = curSave.data.general;
		}
		else
		{
			curSave.data.general = currentData;
			curSave.flush();
		}
	}

	public static function copySaveToSave(copyFrom:FlxSave, copyTo:FlxSave):Bool
	{
		try {
			var fields:Array<String> = Reflect.fields(copyFrom.data);

			copyTo.erase();
			for (field in fields)
			{
				Reflect.setProperty(copyTo, field, Reflect.getProperty(copyFrom, field));
			}
			copyTo.flush();

			return true;
		} catch (e) {
			trace('failed to copy save data, cloned data may be corrupt or empty');
			return false;
		}
	}

	public static function setGeneralData(field:String, value:Dynamic, ?flush:Bool = true)
	{
		trace('setting $field to $value');
		Reflect.setProperty(generalData, field, value);
		if (Reflect.getProperty(generalData, field) == value) {trace('success!');}
		FlxG.save.data.general = generalData;
		if (flush) {FlxG.save.flush();}
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

		if (Main.args.contains('debugmode'))
		{
			FlxTween.tween(MenuState.instance.dialougeEditButton, {alpha: 0}, 0.5);
			FlxTween.tween(MenuState.instance.charEditButton, {alpha: 0}, 0.5);
			FlxTween.tween(MenuState.instance.battleEditButton, {alpha: 0}, 0.5);
			FlxTween.tween(MenuState.instance.chapterEditButton, {alpha: 0}, 0.5);
		}
		
		new FlxTimer().start(0.5, postCreate);

		var showfpsopt = new Option(options.length, 'FPS', generalData.fps, 'fps', 'int', {
			change: 5,
			min: 25,
			max: 240,
			change_func: function(value, change) {
				Main.framerate = (value is Int) ? value : 30;
			},
			current: false
		});
		options.push(showfpsopt);
		add(showfpsopt);

		var showfpsopt = new Option(options.length, 'Show Fps?', generalData.show_fps, 'show_fps', 'bool', {current: false});
		options.push(showfpsopt);
		add(showfpsopt);

		if (Main.args.contains('debugmode')) {
			var battleBox = new Option(options.length, 'Test - Battle Box', generalData.show_fps, 'show_fps', 'none', {current: false,
				change_func: function(value, change)
				{
					FlxG.switchState(new editors.BattleBoxTestState());
				}});
			options.push(battleBox);
			add(battleBox);
		}

		bgColor = 0x00000000;
		changeIndex();
	}

	public function postCreate(_)
	{
		entering = false;
		FlxTween.tween(FlxG.camera.scroll, {x: 640}, 1, {ease: FlxEase.circInOut});
	}

	override public function update(elapsed:Float)
	{
		if (!returning && !entering) {
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
			index = options.length-1;
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
		super((FlxG.width*2) - (320 + 10), (index * 40) + 10, 320, text);
		setFormat(PathGenerator.getFont("8bitoperator_jve"), 32, FlxColor.WHITE, RIGHT);
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
		switch(type)
		{
			case 'int':
				trace('cant select int');
			case 'float':
				trace('cant select float');
			case 'bool':
				if (value == true) {value = false;} else {value = true;}
				if (properties.current) {trace('oops');} else {Options.setGeneralData(field, value);}
			default:
				trace('invalid');
		}
	}

	override public function update(elapsed:Float)
	{
		switch(type)
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
		switch(type)
		{
			case 'int':
				if (value == null || !(value is Int)) {value = 0;}
				value += change * Std.int(properties.change);
				if (value < properties.min)
				{value = Std.int(properties.min);}
				if (value > properties.max)
				{value = Std.int(properties.max);}
				if (properties.current) {trace('oops');} else {Options.setGeneralData(field, value);}
			case 'float':
				trace('not complete');
			case 'bool':
				if (value == true) {value = false;} else {value = true;}
				if (properties.current) {trace('oops');} else {Options.setGeneralData(field, value);}
			default:
				trace('invalid');
		}

		if (properties.change_func != null) {properties.change_func(value, change);}
	}
}

typedef OptionConfig = 
{
	var ?change:Float;
	var ?change_func: Dynamic -> Int -> Void ;
	var ?min:Float;
	var ?max:Float;
	var ?current:Bool;
}