package states;

import flixel.FlxG;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;

class TransitionState extends FlxTransitionableState
{
    override public function create()
    {
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.6);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.6);
		FlxG.autoPause = false;
		FlxG.switchState(new MenuState());
    }
}