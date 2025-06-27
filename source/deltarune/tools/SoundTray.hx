package deltarune.tools;

import flixel.system.ui.FlxSoundTray;

class SoundTray extends FlxSoundTray
{
	override public function new()
	{
		super();
		removeChildren();
	}
}
