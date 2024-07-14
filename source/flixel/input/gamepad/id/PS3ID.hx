package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * Button IDs for PlayStation 3 controllers. There are many issues with it
 */
class PS3ID
{
	// digital
	public static inline var TRIANGLE_BUTTON:Int = 10; // 10
	public static inline var CIRCLE_BUTTON:Int = 13; // 13
	public static inline var X_BUTTON:Int = 14; // 14
	public static inline var SQUARE_BUTTON:Int = 12; // 12
	public static inline var L1:Int = 18; // 18
	public static inline var R1:Int = 19; // 19
	public static inline var L2:Int = 17; // 17, 3 for analog
	public static inline var R2:Int = 20; // 20
	public static inline var SELECT_BUTTON:Int = 5; // 5
	public static inline var START_BUTTON:Int = 4; // 4
	public static inline var PS_BUTTON:Int = 9; // 9
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 15; // 15
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 16; // 16
	public static inline var DPAD_UP:Int = 40;
	public static inline var DPAD_DOWN:Int = 41;
	public static inline var DPAD_LEFT:Int = 42;
	public static inline var DPAD_RIGHT:Int = 43;
	// analouge
	public static inline var LEFT_ANALOGUE_X:Int = 0; // 0
	public static inline var LEFT_ANALOGUE_Y:Int = 1; // 1
	public static inline var RIGHT_ANALOGUE_X:Int = 2; // 2
	public static inline var RIGHT_ANALOGUE_Y:Int = 50; // ??

	public static inline var L2_ANALOG:Int = 3;
	public static inline var R2_ANALOG:Int = 44;

	public static inline var INVALID:Int = -1;

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(LEFT_ANALOGUE_X, LEFT_ANALOGUE_Y, {
		up: 32,
		down: 33,
		left: 34,
		right: 35
	});

	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(45, 46, {
		up: 47,
		down: 48,
		left: 49,
		right: 50
	});
	//public static inline var TRIANGLE_BUTTON_PRESSURE:Int = 16;
	//public static inline var CIRCLE_BUTTON_PRESSURE:Int = 17;
	//public static inline var X_BUTTON_PRESSURE:Int = 18;
	//public static inline var SQUARE_BUTTON_PRESSURE:Int = 19;
}

class PS3IDLegacy
{
	public static inline var TRIANGLE_BUTTON:Int = 12;
	public static inline var CIRCLE_BUTTON:Int = 13;
	public static inline var X_BUTTON:Int = 14;
	public static inline var SQUARE_BUTTON:Int = 15;
	public static inline var L1_BUTTON:Int = 10;
	public static inline var R1_BUTTON:Int = 11;
	public static inline var L2_BUTTON:Int = 8;
	public static inline var R2_BUTTON:Int = 9;
	public static inline var SELECT_BUTTON:Int = 0;
	public static inline var START_BUTTON:Int = 3;
	public static inline var PS_BUTTON:Int = 16;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 1;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 2;
	public static inline var DPAD_UP:Int = 4;
	public static inline var DPAD_DOWN:Int = 6;
	public static inline var DPAD_LEFT:Int = 7;
	public static inline var DPAD_RIGHT:Int = 5;

	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var TRIANGLE_BUTTON_PRESSURE:Int = 16;
	public static inline var CIRCLE_BUTTON_PRESSURE:Int = 17;
	public static inline var X_BUTTON_PRESSURE:Int = 18;
	public static inline var SQUARE_BUTTON_PRESSURE:Int = 19;
}