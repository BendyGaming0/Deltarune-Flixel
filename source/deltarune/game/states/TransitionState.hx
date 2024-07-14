package deltarune.game.states;

import deltarune.game.State;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxG;

class TransitionState extends State
{
    override public function create()
    {
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.4);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.4);
		FlxG.autoPause = false;
		FlxG.sound.music.stop();
		new FlxTimer().start(1, function(_) {
			FlxG.switchState(() -> new MenuState());
		});
    }
}