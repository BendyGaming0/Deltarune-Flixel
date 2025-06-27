package deltarune.game.states;

import deltarune.game.State;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class TransitionState extends State
{
	override public function create()
	{
		super.create();

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.4);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.4);

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		new FlxTimer().start(1, function(_)
		{
			FlxG.switchState(() -> new MenuState());
		});
	}
}
