package states;

import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import tools.PathGenerator;
import flixel.addons.transition.FlxTransitionableState;
import shaders.PulsatingGhostShader.PulsatingGhostEffect;

class IntroState extends FlxTransitionableState
{
	var background:FlxSprite;
	var intro_shader:PulsatingGhostEffect;

	var playButton:FlxButton;
	var leaving:Bool = false;

	override public function create()
	{
		MenuState.initialize();

		FlxG.sound.playMusic(PathGenerator.getMusic('anotherhim'), 0.8, true);

	    background = new FlxSprite().loadGraphic('assets/images/intro_cutscene/intro_background.png');

		background.scale.x = 2;
		background.scale.y = 2;

		background.antialiasing = false;

		background.updateHitbox();
		background.screenCenter(XY);

		intro_shader = new PulsatingGhostEffect();

		var text:Array<String> = sys.io.File.getContent(Sys.getCwd() + '/assets/data/shader_data/intro_pulse.txt').split('\n');

		intro_shader.size = Std.parseFloat(text[0]);
		intro_shader.power = Std.parseFloat(text[1]);
		intro_shader.count = Std.parseInt(text[2]);
		intro_shader.speed = Std.parseFloat(text[3]);

		background.shader = intro_shader.shader;

		add(background);

		playButton = new FlxButton(0, 225, "BEGIN", clickPlay);
		playButton.screenCenter(XY);

        add(playButton);
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        intro_shader.update(elapsed);
    }

	function clickPlay()
	{
		if (leaving)
            return;

		FlxG.switchState(new TransitionState());
        leaving = true;
	}
}