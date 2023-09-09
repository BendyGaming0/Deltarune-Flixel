package states;

import flixel.util.FlxTimer;
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
		FlxG.sound.music.stop();
		new FlxTimer().start(2, function(_) {
			FlxG.switchState(new MenuState());
		});
    }
}