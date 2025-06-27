package deltarune.editors;

import deltarune.game.LegacyDialogueBox;
import flixel.FlxSubState;

class DialogueTestSState extends FlxSubState
{
	var boxFile:DialogueStructure;
	var box:LegacyDialogueBox;

	override public function new(data:DialogueStructure)
	{
		super();
		boxFile = copyDat(data);
	}

	function copyDat(dat:DialogueStructure)
	{
		return {
			style: dat.style,
			dialogue: dat.dialogue.copy()
		};
	}

	override function create()
	{
		super.create();
		bgColor = 0x80000000;
		box = new LegacyDialogueBox(0, 0, boxFile);
		box.y = 300;
		box.screenCenter(X);
		box.activated = true;
		box.finishedCallback = function()
		{
			close();
		};
		add(box);
	}
}
