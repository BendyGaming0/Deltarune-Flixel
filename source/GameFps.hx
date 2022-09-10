package;

import states.substates.Options;
import tools.PathGenerator;
import openfl.text.TextFormat;
import openfl.display.FPS;

class GameFps extends FPS
{
    public function new()
    {
        super(10, 8, 0xFFFFFFFF);
		var format = new TextFormat(PathGenerator.getFont('8bitoperator_jve'), 16, 0xFFFFFFFF);
		setTextFormat(format);
    }

    public override function __enterFrame(delta:Float)
    {
        super.__enterFrame(delta);
        if (!Options.generalData.show_fps)
            text = '';
    }
}