package editors;

import flixel.FlxSubState;
import DeltaDialougeBox;

class DialougeTestSState extends FlxSubState
{
	var boxFile:DialougeStructure;
    var box:DeltaDialougeBox;

	override public function new(data:DialougeStructure)
    {
        super();
        boxFile = copyDat(data);
    }

	function copyDat(dat:DialougeStructure)
	{
        return {
            style: dat.style,
            dialouge: dat.dialouge.copy()
        };
    }

    override function create()
    {
        super.create();
        bgColor = 0x80000000;
		box = new DeltaDialougeBox(0, 0, boxFile);
		box.y = 300;
		box.screenCenter(X);
		box.activated = true;
        box.finishedCallback = function() {close();};
        add(box);
    }
}