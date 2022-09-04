package flixel.input.gamepad.mapping;
/*
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.PS3ID;

class PS3Mapping extends FlxGamepadMapping
{
	#if FLX_JOYSTICK_API
	static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 21;
	static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 22;

	static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 23;
	static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 24;

	static inline var LEFT_TRIGGER_FAKE:Int = 25;
	static inline var RIGHT_TRIGGER_FAKE:Int = 26;
	#end

	override function initValues():Void
	{
		//leftStick = PS3ID.LEFT_ANALOG_STICK;
		//rightStick = PS3ID.RIGHT_ANALOG_STICK;
		supportsMotion = false;
		supportsPointer = false; //not sure...
	}

	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case PS3ID.X_BUTTON: A;
			case PS3ID.CIRCLE_BUTTON: B;
			case PS3ID.SQUARE_BUTTON: X;
			case PS3ID.TRIANGLE_BUTTON: Y;
			case PS3ID.SELECT_BUTTON: BACK;
			case PS3ID.PS_BUTTON: GUIDE;
			case PS3ID.START_BUTTON: START;
			case PS3ID.LEFT_ANALOGUE_BUTTON: LEFT_STICK_CLICK;
			case PS3ID.RIGHT_ANALOGUE_BUTTON: RIGHT_STICK_CLICK;
			case PS3ID.L1_BUTTON: LEFT_SHOULDER;
			case PS3ID.R1_BUTTON: RIGHT_SHOULDER;
			case PS3ID.L2_BUTTON: LEFT_TRIGGER;
			case PS3ID.R2_BUTTON: RIGHT_TRIGGER;
			case PS3ID.DPAD_DOWN: DPAD_DOWN;
			case PS3ID.DPAD_UP: DPAD_UP;
			case PS3ID.DPAD_LEFT: DPAD_LEFT;
			case PS3ID.DPAD_RIGHT: DPAD_RIGHT;
			case id if (id == leftStick.rawUp): LEFT_STICK_DIGITAL_UP;
			case id if (id == leftStick.rawDown): LEFT_STICK_DIGITAL_DOWN;
			case id if (id == leftStick.rawLeft): LEFT_STICK_DIGITAL_LEFT;
			case id if (id == leftStick.rawRight): LEFT_STICK_DIGITAL_RIGHT;
			case id if (id == rightStick.rawUp): RIGHT_STICK_DIGITAL_UP;
			case id if (id == rightStick.rawDown): RIGHT_STICK_DIGITAL_DOWN;
			case id if (id == rightStick.rawLeft): RIGHT_STICK_DIGITAL_LEFT;
			case id if (id == rightStick.rawRight): RIGHT_STICK_DIGITAL_RIGHT;
			case _: NONE;
		}
	}

	override public function getRawID(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: PS3ID.X_BUTTON;
			case B: PS3ID.CIRCLE_BUTTON;
			case X: PS3ID.SQUARE_BUTTON;
			case Y: PS3ID.TRIANGLE_BUTTON;
			case BACK: PS3ID.SELECT_BUTTON;
			case GUIDE: PS3ID.PS_BUTTON;
			case START: PS3ID.START_BUTTON;
			case LEFT_STICK_CLICK: PS3ID.LEFT_ANALOGUE_BUTTON;
			case RIGHT_STICK_CLICK: PS3ID.RIGHT_ANALOGUE_BUTTON;
			case LEFT_SHOULDER: PS3ID.L1_BUTTON;
			case RIGHT_SHOULDER: PS3ID.R1_BUTTON;
			case DPAD_UP: PS3ID.DPAD_UP;
			case DPAD_DOWN: PS3ID.DPAD_DOWN;
			case DPAD_LEFT: PS3ID.DPAD_LEFT;
			case DPAD_RIGHT: PS3ID.DPAD_RIGHT;
			case LEFT_TRIGGER: PS3ID.L2_BUTTON;
			case RIGHT_TRIGGER: PS3ID.R2_BUTTON;/* uh oh, unsupported stuff
			case LEFT_STICK_DIGITAL_UP: PS3ID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: PS3ID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: PS3ID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: PS3ID.LEFT_ANALOG_STICK.rawRight;
			case RIGHT_STICK_DIGITAL_UP: PS3ID.RIGHT_ANALOG_STICK.rawUp;
			case RIGHT_STICK_DIGITAL_DOWN: PS3ID.RIGHT_ANALOG_STICK.rawDown;
			case RIGHT_STICK_DIGITAL_LEFT: PS3ID.RIGHT_ANALOG_STICK.rawLeft;
			case RIGHT_STICK_DIGITAL_RIGHT: PS3ID.RIGHT_ANALOG_STICK.rawRight;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	override function getInputLabel(id:FlxGamepadInputID)
	{
		return switch (id)
		{
			case A: "x";
			case B: "circle";
			case X: "square";
			case Y: "triangle";
			case BACK: "share";
			case GUIDE: "ps";
			case START: "options";
			case LEFT_SHOULDER: "l1";
			case RIGHT_SHOULDER: "r1";
			case LEFT_TRIGGER: "l2";
			case RIGHT_TRIGGER: "r2";
			case _: super.getInputLabel(id);
		}
	}
	
	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int
	{
		// Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
		return if (axisID == leftStick.x) LEFT_ANALOG_STICK_FAKE_X; else if (axisID == leftStick.y) LEFT_ANALOG_STICK_FAKE_Y; else if (axisID == rightStick.x)
			RIGHT_ANALOG_STICK_FAKE_X;
		else if (axisID == rightStick.y)
			RIGHT_ANALOG_STICK_FAKE_Y;
		else if (axisID == PS3ID.L2)
			LEFT_TRIGGER_FAKE;
		else if (axisID == PS3ID.R2)
			RIGHT_TRIGGER_FAKE;
		else
			axisID;
	}
	#end
}
*/