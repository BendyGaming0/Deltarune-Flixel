package deltarune.game;

import flixel.addons.transition.FlxTransitionableState;

class State extends FlxTransitionableState
{
	override public function create()
	{
		// init the game if it hasnt already been
		Game.initialize();

		super.create();
	}
}
