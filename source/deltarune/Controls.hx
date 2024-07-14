package deltarune;

import deltarune.assets.GameAssets;
import flixel.input.gamepad.mapping.PS3Mapping;
import flixel.util.FlxTimer;
import openfl.display.Bitmap;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

import deltarune.assets.Paths;

using StringTools;

@:dox(hide)
typedef FlxKeys = Array<FlxKey>;

@:dox(hide)
typedef FlxGamepadButtons = Array<FlxGamepadInputID>;

// To-Do add text to each room to add here when unplugging your controller like undertale on XBOX
class Controls
{
	public static var primary(default, never):DigitalButton = new DigitalButton([Z, ENTER], [A]);
	public static var secondary(default, never):DigitalButton = new DigitalButton([X, SHIFT], [X, LEFT_SHOULDER, LEFT_STICK_CLICK]);
	public static var tetritary(default, never):DigitalButton = new DigitalButton([C, CONTROL], [Y, RIGHT_SHOULDER]);
	public static var back(default, never):DigitalButton = new DigitalButton([BACKSPACE], [B]);

	public static var left(default, never):DigitalButton = new DigitalButton([A, LEFT], [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT]);
	public static var down(default, never):DigitalButton = new DigitalButton([S, DOWN], [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN]);
	public static var up(default, never):DigitalButton = new DigitalButton([W, UP], [DPAD_UP, LEFT_STICK_DIGITAL_UP]);
	public static var right(default, never):DigitalButton = new DigitalButton([D, RIGHT], [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]);

	static var activeToast:Bitmap;
	static var inactiveToast:Bitmap;

	public static function remapExtendedControllers()
	{
		@:privateAccess
		for (i in 0...FlxG.gamepads._gamepads.length)
		{
			if (FlxG.gamepads._gamepads[i] != null) {
				remapController(FlxG.gamepads._gamepads[i]);
			}
		}
	}

    public static function addControllerToast()
    {
		activeToast = new Bitmap(GameAssets.bitmap(Paths.getImage('controllerConnected')));
		inactiveToast = new Bitmap(GameAssets.bitmap(Paths.getImage('controllerRemoved')));
		activeToast.x = FlxG.width - 80;
		activeToast.y = FlxG.height;
		inactiveToast.x = FlxG.width - 80;
		inactiveToast.y = FlxG.height;
		FlxG.gamepads.deviceConnected.add(controllerConnectToast);
		FlxG.gamepads.deviceConnected.add(remapController);
		FlxG.console.registerFunction("getAllRawButtonIds", function() {
			var gamepad = FlxG.gamepads.firstActive;
			if (gamepad == null) return "[]";
			var pressedIds:Array<Int> = [];
			@:privateAccess {
				for (button in gamepad.buttons)
				{
					if (button != null && button.pressed)
					{
						pressedIds.push(button.ID);
					}
				}
			}
			return pressedIds.toString();
		});
		FlxG.gamepads.deviceDisconnected.add(controllerRemoveToast);
	}

	public static function remapController(gamepad:FlxGamepad):Void
	{
		if (gamepad.detectedModel == UNKNOWN && gamepad.id != -1) {
			if (gamepad.name.toLowerCase().contains("ps3"))
			{
				FlxG.log.notice('PS3 (${gamepad.name}) connected and remapped as ID : ${gamepad.id}');
				gamepad.mapping = new PS3Mapping(gamepad.attachment);
			} else {
				FlxG.log.notice('Unknown device (${gamepad.name}) connected as ID : ${gamepad.id}');
			}
		}
		else if (gamepad.id != -1)
		{
			FlxG.log.notice('${gamepad.model} (${gamepad.name}) connected as ID : ${gamepad.id}');
		}
	}

	public static function controllerConnectToast(_:FlxGamepad)
	{
		FlxG.addChildBelowMouse(activeToast);
		trace('controller connected!');
		FlxTween.tween(activeToast, {y: FlxG.height - 64}, 0.5, {
			ease: FlxEase.circOut, 
			onComplete: function(__)
			{
				FlxTimer.wait(0.5, function() {
					FlxTween.tween(activeToast, {y: FlxG.height}, 0.5, {
						ease: FlxEase.circIn,
						onComplete: function(___)
						{
							FlxG.removeChild(activeToast);}});
				});
			}
		});
		return;
	}

	public static function controllerRemoveToast(_:FlxGamepad)
	{
		FlxG.addChildBelowMouse(inactiveToast);
		trace('controller removed :(');
		FlxTween.tween(inactiveToast, {y: FlxG.height - 64}, 0.5, {
			ease: FlxEase.circOut, 
			onComplete: function(__)
			{
				FlxTimer.wait(0.5, function() {
					FlxTween.tween(inactiveToast, {y: FlxG.height}, 0.5, {
						ease: FlxEase.circIn,
						onComplete: function(___)
						{
							FlxG.removeChild(inactiveToast);
						}
					});
				});
			}
		});
		return;
	}
}

class DigitalButton
{
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	public var justReleased(get, never):Bool;

	function get_pressed()
	{
		return FlxG.keys.anyPressed(keys) || getController().anyPressed(buttons);
	}

	function get_justPressed()
	{
		return FlxG.keys.anyJustPressed(keys) || getController().anyJustPressed(buttons);
	}

	function get_justReleased()
	{
		return FlxG.keys.anyJustReleased(keys) || getController().anyJustReleased(buttons);
	}

    var keys:FlxKeys;
	var buttons:FlxGamepadButtons;
    var player:Int = 1;

	public function new(keybindings:FlxKeys, buttonss:FlxGamepadButtons)
    {
        keys = keybindings;
        buttons = buttonss;
    }

	public function changeControls(keybindings:FlxKeys, buttonss:FlxGamepadButtons)
	{
		keys = keybindings;
		buttons = buttonss;
	}

    function getController()
    {
        if (FlxG.gamepads.firstActive != null)
            return FlxG.gamepads.firstActive;
		return new FlxGamepad(player, FlxG.gamepads); //no returning null >:(
    }
}