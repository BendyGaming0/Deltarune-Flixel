package deltarune.game.states;

import deltarune.game.State;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.NextState;

class TransitionState extends State
{
	public var nextState:NextState;

	public function new(?nextState:NextState) {
		if (nextState == null)
			nextState = (() -> new ChapterSelectState());
		this.nextState = nextState;
		super();
	}

	override public function create()
	{
		super.create();

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.4);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.4);

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		new FlxTimer().start(0.5, function(_)
		{
			FlxG.switchState(nextState);
		});
	}
}
